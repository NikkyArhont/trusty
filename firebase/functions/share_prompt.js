const FOUR_DAYS_MS = 4 * 24 * 60 * 60 * 1000;
const TWO_HOURS_MS = 2 * 60 * 60 * 1000;
const MAX_SEND_BATCH = 500;

function nonEmpty(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function timestampMillis(value) {
  if (!value) return null;
  if (typeof value.toMillis === "function") return value.toMillis();
  if (value instanceof Date) return value.getTime();
  if (typeof value === "number") return value;
  return null;
}

function validTokens(user) {
  if (user.pushNotificationsEnabled === false) return [];
  if (!Array.isArray(user.fcmTokens)) return [];
  return [...new Set(user.fcmTokens.filter(nonEmpty))];
}

function latestTimestampMillis(...values) {
  const timestamps = values
    .map(timestampMillis)
    .filter((value) => value !== null);
  return timestamps.length === 0 ? null : Math.max(...timestamps);
}

function sharePromptEligible(user, nowMillis) {
  const lastPromptMillis = latestTimestampMillis(
    user.sharePromptPushSentAt,
    user.sharePromptShownAt,
    user.sharePromptSharedAt,
  );
  const milestoneMillis = timestampMillis(user.sharePromptEligibleAt);
  if (milestoneMillis !== null &&
      (lastPromptMillis === null || milestoneMillis > lastPromptMillis)) {
    return true;
  }
  if (lastPromptMillis !== null) {
    return nowMillis - lastPromptMillis >= FOUR_DAYS_MS;
  }
  const createdMillis = timestampMillis(user.created_time);
  return createdMillis !== null && nowMillis - createdMillis >= FOUR_DAYS_MS;
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

function hasEngagementPushToday(user, now) {
  const today = moscowDateKey(now);
  return moscowDateKey(user.engagementPushDueAt) === today ||
    moscowDateKey(user.engagementPushLastSentAt) === today;
}

function shouldPlanSharePrompt(user, nowMillis) {
  return user.isGuest !== true &&
    !user.migratedToUid &&
    !user.sharePromptDueAt &&
    validTokens(user).length > 0 &&
    sharePromptEligible(user, nowMillis) &&
    !hasEngagementPushToday(user, new Date(nowMillis));
}

function nextMoscowWindow(now, random = Math.random) {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Europe/Moscow",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(now);
  const value = (type) => parts.find((part) => part.type === type).value;
  const start = Date.parse(
    `${value("year")}-${value("month")}-${value("day")}T13:00:00.000Z`,
  );
  return new Date(start + Math.floor(random() * TWO_HOURS_MS));
}

async function sharePromptPushEnabled(firestore) {
  const snapshot = await firestore
    .collection("appConfig")
    .doc("sharePrompt")
    .get();
  return snapshot.exists && snapshot.data().pushEnabled === true;
}

async function markSharePromptEligible({admin, userReference, reason}) {
  if (!userReference || typeof userReference.get !== "function") return false;
  const firestore = admin.firestore();
  return firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(userReference);
    if (!snapshot.exists) return false;
    const user = snapshot.data() || {};
    if (reason === "first_service" && user.firstServiceInviteShownAt) {
      return false;
    }
    if (user.sharePromptEligibleAt) return false;
    transaction.set(userReference, {
      sharePromptEligibleAt: admin.firestore.FieldValue.serverTimestamp(),
      sharePromptReason: reason,
    }, {merge: true});
    return true;
  });
}

async function planSharePrompts({admin, now = new Date(), random}) {
  const firestore = admin.firestore();
  if (!await sharePromptPushEnabled(firestore)) {
    console.log("Share prompt push planning is disabled");
    return 0;
  }
  const users = await firestore.collection("user").get();
  let batch = firestore.batch();
  let batchSize = 0;
  let planned = 0;

  for (const document of users.docs) {
    const user = document.data() || {};
    if (!shouldPlanSharePrompt(user, now.getTime())) continue;
    const update = {
      sharePromptDueAt: admin.firestore.Timestamp.fromDate(
        nextMoscowWindow(now, random),
      ),
    };
    if (!user.sharePromptEligibleAt) {
      update.sharePromptEligibleAt = admin.firestore.Timestamp.fromDate(now);
      update.sharePromptReason = "registration_four_days";
    }
    batch.set(document.ref, update, {merge: true});
    batchSize += 1;
    planned += 1;
    if (batchSize === 450) {
      await batch.commit();
      batch = firestore.batch();
      batchSize = 0;
    }
  }

  if (batchSize > 0) await batch.commit();
  console.log(`Planned ${planned} share prompts`);
  return planned;
}

async function claimDueSharePrompt({admin, userDocument, now}) {
  const firestore = admin.firestore();
  return firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(userDocument.ref);
    if (!snapshot.exists) return null;
    const user = snapshot.data() || {};
    const dueMillis = timestampMillis(user.sharePromptDueAt);
    if (dueMillis === null || dueMillis > now.getTime()) {
      return null;
    }
    transaction.set(userDocument.ref, {
      sharePromptDueAt: admin.firestore.FieldValue.delete(),
      sharePromptPushSentAt: admin.firestore.Timestamp.fromDate(now),
    }, {merge: true});
    return user;
  });
}

async function sendSharePromptPush({admin, userDocument, user}) {
  const tokens = validTokens(user);
  if (tokens.length === 0) return {sent: 0, failed: 0};
  let sent = 0;
  let failed = 0;
  const invalidTokens = [];

  for (let index = 0; index < tokens.length; index += MAX_SEND_BATCH) {
    const tokenBatch = tokens.slice(index, index + MAX_SEND_BATCH);
    const response = await admin.messaging().sendEachForMulticast({
      tokens: tokenBatch,
      notification: {
        title: "Помогите Сарафану расти",
        body: "Поделитесь приложением с друзьями — вместе мы создаём сеть проверенных мастеров.",
      },
      data: {type: "share_prompt"},
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

async function dispatchDueSharePrompts({admin, now = new Date()}) {
  const firestore = admin.firestore();
  if (!await sharePromptPushEnabled(firestore)) {
    console.log("Share prompt push dispatch is disabled");
    return {processed: 0, sent: 0, failed: 0};
  }
  let processed = 0;
  let sent = 0;
  let failed = 0;

  while (true) {
    const due = await firestore.collection("user")
      .where("sharePromptDueAt", "<=", now)
      .limit(100)
      .get();
    if (due.empty) break;
    for (const document of due.docs) {
      const user = await claimDueSharePrompt({admin, userDocument: document, now});
      if (!user) continue;
      const result = await sendSharePromptPush({
        admin,
        userDocument: document,
        user,
      });
      processed += 1;
      sent += result.sent;
      failed += result.failed;
    }
  }

  console.log(`Processed ${processed} share prompts: ${sent} sent, ${failed} failed`);
  return {processed, sent, failed};
}

module.exports = {
  FOUR_DAYS_MS,
  dispatchDueSharePrompts,
  hasEngagementPushToday,
  markSharePromptEligible,
  nextMoscowWindow,
  planSharePrompts,
  sharePromptEligible,
  shouldPlanSharePrompt,
};
