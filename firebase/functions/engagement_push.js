const FIVE_DAYS_MS = 5 * 24 * 60 * 60 * 1000;
const TWO_HOURS_MS = 2 * 60 * 60 * 1000;
const MAX_SEND_BATCH = 500;

function nonEmpty(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function isMasterUser(user) {
  const masterData = user.masterData || {};
  return user.masterMode === true ||
    masterData.onboardingCompleted === true ||
    masterData.profileCompleted === true ||
    nonEmpty(masterData.title) ||
    nonEmpty(masterData.descrip) ||
    nonEmpty(masterData.initCat) ||
    nonEmpty(masterData.mainPhoto);
}

function isMasterProfileCompleted(user) {
  const masterData = user.masterData || {};
  if (masterData.profileCompleted === true) {
    return true;
  }
  return nonEmpty(masterData.title) &&
    nonEmpty(masterData.descrip) &&
    nonEmpty(masterData.initCat) &&
    nonEmpty(masterData.mainPhoto) &&
    nonEmpty(masterData.mainAdres && masterData.mainAdres.title);
}

function engagementMessage({user, hasServices = false}) {
  if (!isMasterUser(user)) {
    return {
      kind: "client",
      title: "Загляните в Сарафан",
      body: "Возможно, появились услуги, которые вас заинтересуют.",
    };
  }

  if (!isMasterProfileCompleted(user)) {
    return {
      kind: "master_profile_incomplete",
      title: "Завершите профиль",
      body: "Заполните профиль и опубликуйте свою первую услугу.",
    };
  }

  if (!hasServices) {
    return {
      kind: "master_without_services",
      title: "Опубликуйте первую услугу",
      body: "Возможно, пользователи уже ищут именно вас.",
    };
  }

  return {
    kind: "master_with_services",
    title: "Взгляните на услуги других",
    body: "Возможно, вам стоит обновить оформление своих услуг.",
  };
}

function validTokens(user) {
  if (!Array.isArray(user.fcmTokens)) {
    return [];
  }
  return [...new Set(user.fcmTokens.filter(nonEmpty))];
}

function timestampMillis(value) {
  if (!value) return null;
  if (typeof value.toMillis === "function") return value.toMillis();
  if (value instanceof Date) return value.getTime();
  if (typeof value === "number") return value;
  return null;
}

function isDueForPlanning(user, nowMillis) {
  if (validTokens(user).length === 0 || user.engagementPushDueAt) {
    return false;
  }
  const lastSentMillis = timestampMillis(user.engagementPushLastSentAt);
  return lastSentMillis === null || nowMillis - lastSentMillis >= FIVE_DAYS_MS;
}

function moscowDateKey(value) {
  const millis = timestampMillis(value);
  if (millis === null) return null;
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Europe/Moscow",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date(millis));
}

function hasSharePromptToday(user, now) {
  const today = moscowDateKey(now);
  return moscowDateKey(user.sharePromptDueAt) === today ||
    moscowDateKey(user.sharePromptPushSentAt) === today;
}

function nextMoscowWindow(now, random = Math.random) {
  const moscowParts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Europe/Moscow",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(now);
  const value = (type) => moscowParts.find((part) => part.type === type).value;
  const windowStart = Date.parse(
    `${value("year")}-${value("month")}-${value("day")}T13:00:00.000Z`,
  );
  const randomOffset = Math.floor(random() * TWO_HOURS_MS);
  return new Date(windowStart + randomOffset);
}

async function planEngagementPushes({admin, now = new Date(), random}) {
  const firestore = admin.firestore();
  const usersSnapshot = await firestore.collection("user").get();
  let batch = firestore.batch();
  let batchSize = 0;
  let planned = 0;

  for (const userDocument of usersSnapshot.docs) {
    const user = userDocument.data() || {};
    if (!isDueForPlanning(user, now.getTime()) ||
        hasSharePromptToday(user, now)) continue;

    batch.set(userDocument.ref, {
      engagementPushDueAt: admin.firestore.Timestamp.fromDate(
        nextMoscowWindow(now, random),
      ),
    }, {merge: true});
    batchSize += 1;
    planned += 1;

    if (batchSize === 450) {
      await batch.commit();
      batch = firestore.batch();
      batchSize = 0;
    }
  }

  if (batchSize > 0) await batch.commit();
  console.log(`Planned ${planned} engagement pushes`);
  return planned;
}

async function masterHasServices(firestore, userReference) {
  const snapshot = await firestore
    .collection("service")
    .where("owner", "==", userReference)
    .limit(1)
    .get();
  return !snapshot.empty;
}

async function claimDuePush({admin, userDocument, now}) {
  const firestore = admin.firestore();
  return firestore.runTransaction(async (transaction) => {
    const freshSnapshot = await transaction.get(userDocument.ref);
    if (!freshSnapshot.exists) return null;
    const user = freshSnapshot.data() || {};
    const dueMillis = timestampMillis(user.engagementPushDueAt);
    if (dueMillis === null || dueMillis > now.getTime()) return null;

    transaction.set(userDocument.ref, {
      engagementPushDueAt: admin.firestore.FieldValue.delete(),
      engagementPushLastSentAt: admin.firestore.Timestamp.fromDate(now),
    }, {merge: true});
    return user;
  });
}

async function sendUserEngagementPush({admin, userDocument, user}) {
  const tokens = validTokens(user);
  if (tokens.length === 0) return {sent: 0, failed: 0};

  const firestore = admin.firestore();
  const master = isMasterUser(user);
  const hasServices = master && isMasterProfileCompleted(user)
    ? await masterHasServices(firestore, userDocument.ref)
    : false;
  const message = engagementMessage({user, hasServices});
  let sent = 0;
  let failed = 0;
  const invalidTokens = [];

  for (let index = 0; index < tokens.length; index += MAX_SEND_BATCH) {
    const tokenBatch = tokens.slice(index, index + MAX_SEND_BATCH);
    const response = await admin.messaging().sendEachForMulticast({
      tokens: tokenBatch,
      notification: {title: message.title, body: message.body},
      data: {type: "engagement", engagementKind: message.kind},
      android: {
        priority: "normal",
        notification: {channelId: "trusty_messages", sound: "default"},
      },
      apns: {payload: {aps: {sound: "default"}}},
    });
    sent += response.successCount;
    failed += response.failureCount;
    response.responses.forEach((result, responseIndex) => {
      const code = result.error && result.error.code;
      if (code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token") {
        invalidTokens.push(tokenBatch[responseIndex]);
      }
    });
  }

  if (invalidTokens.length > 0) {
    await userDocument.ref.update({
      fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
    });
  }
  return {sent, failed};
}

async function dispatchDueEngagementPushes({admin, now = new Date()}) {
  const firestore = admin.firestore();
  let sent = 0;
  let failed = 0;
  let processed = 0;

  while (true) {
    const dueSnapshot = await firestore
      .collection("user")
      .where("engagementPushDueAt", "<=", now)
      .limit(100)
      .get();
    if (dueSnapshot.empty) break;

    for (const userDocument of dueSnapshot.docs) {
      const user = await claimDuePush({admin, userDocument, now});
      if (!user) continue;
      const result = await sendUserEngagementPush({
        admin,
        userDocument,
        user,
      });
      sent += result.sent;
      failed += result.failed;
      processed += 1;
    }
  }

  console.log(`Processed ${processed} users: ${sent} sent, ${failed} failed`);
  return {processed, sent, failed};
}

module.exports = {
  FIVE_DAYS_MS,
  dispatchDueEngagementPushes,
  engagementMessage,
  hasSharePromptToday,
  isDueForPlanning,
  isMasterProfileCompleted,
  isMasterUser,
  nextMoscowWindow,
  planEngagementPushes,
};
