const functions = require("firebase-functions");
const {
  onDocumentCreated,
  onDocumentWritten,
} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const {
  TEST_PHONE_NUMBERS,
  createPhoneAuthHandlers,
  normalizeRussianPhone,
} = require("./sms_phone_auth");
const {createModerationCallback} = require("./moderation_callback");
const {
  createServiceModerationDispatcher,
} = require("./service_moderation_dispatch");
const {
  createReportModerationDispatcher,
} = require("./report_moderation_dispatch");
const {
  createReportModerationCallback,
} = require("./report_moderation_callback");
const {createDeleteAccountHandler} = require("./account_deletion");
const {
  createTelegramPhoneAuthHandlers,
} = require("./telegram_phone_auth");
const {
  dispatchDueEngagementPushes,
  planEngagementPushes,
} = require("./engagement_push");
const {
  dispatchDueSharePrompts,
  markSharePromptEligible,
  planSharePrompts,
} = require("./share_prompt");
const {dispatchChatMessagePush} = require("./chat_message_push");
const {createReferralOnboardingHandler} = require("./referral_onboarding");
const {
  createEnsureAdminSupportChatHandler,
  createEnsureSupportChatHandler,
} = require("./support_chat");
const {createGetAdminUsersHandler} = require("./admin_users");
const {
  createAnnounceAppUpdateHandler,
} = require("./app_update_push");
const {
  createRepairUserIdentitiesHandler,
  ensureAuthUserProfile,
} = require("./user_identity_sync");
const {
  buildPublicMasterProfile,
  isMasterProfile,
  normalizePhone: normalizePublicProfilePhone,
} = require("./public_master_profile");
admin.initializeApp();

exports.ensureSupportChat = functions
  .runWith({timeoutSeconds: 20})
  .https.onRequest(createEnsureSupportChatHandler({admin}));

exports.ensureAdminSupportChat = functions
  .runWith({timeoutSeconds: 20})
  .https.onRequest(createEnsureAdminSupportChatHandler({admin}));

exports.getAdminUsers = functions
  .runWith({timeoutSeconds: 30, memory: "512MB"})
  .https.onRequest(createGetAdminUsersHandler({admin}));

exports.announceAppUpdate = functions
  .runWith({timeoutSeconds: 120, memory: "512MB"})
  .https.onRequest(createAnnounceAppUpdateHandler({admin}));

exports.repairUserIdentities = functions
  .runWith({timeoutSeconds: 120, memory: "512MB"})
  .https.onRequest(createRepairUserIdentitiesHandler({admin}));

exports.onAuthUserCreatedEnsureProfile = functions.auth.user()
  .onCreate((user) => ensureAuthUserProfile({admin, user}));

const telegramPhoneAuthHandlers = createTelegramPhoneAuthHandlers({admin});
const referralOnboardingHandler = createReferralOnboardingHandler({
  admin,
  normalizePhone: normalizeRussianPhone,
});

exports.referralOnboarding = functions
  .runWith({timeoutSeconds: 20})
  .https.onRequest(referralOnboardingHandler);

exports.createTelegramPhoneAuth = functions
  .runWith({timeoutSeconds: 20})
  .https.onRequest(telegramPhoneAuthHandlers.createTelegramPhoneAuth);

exports.checkTelegramPhoneAuth = functions
  .runWith({timeoutSeconds: 20})
  .https.onRequest(telegramPhoneAuthHandlers.checkTelegramPhoneAuth);

exports.planEngagementPushes = onSchedule(
  {
    schedule: "50 15 * * *",
    timeZone: "Europe/Moscow",
    region: "europe-west1",
    timeoutSeconds: 300,
  },
  () => planEngagementPushes({admin}),
);

exports.dispatchEngagementPushes = onSchedule(
  {
    schedule: "* 16-17 * * *",
    timeZone: "Europe/Moscow",
    region: "europe-west1",
    timeoutSeconds: 300,
  },
  () => dispatchDueEngagementPushes({admin}),
);

exports.planSharePrompts = onSchedule(
  {
    schedule: "45 15 * * *",
    timeZone: "Europe/Moscow",
    region: "europe-west1",
    timeoutSeconds: 300,
  },
  () => planSharePrompts({admin}),
);

exports.dispatchSharePrompts = onSchedule(
  {
    schedule: "* 16-17 * * *",
    timeZone: "Europe/Moscow",
    region: "europe-west1",
    timeoutSeconds: 300,
  },
  () => dispatchDueSharePrompts({admin}),
);

exports.onFirstServiceCreatedForSharePrompt = onDocumentCreated(
  {
    document: "service/{serviceId}",
    region: "europe-west1",
    timeoutSeconds: 30,
    retry: true,
  },
  async (event) => {
    const service = event.data && event.data.data();
    return markSharePromptEligible({
      admin,
      userReference: service && service.owner,
      reason: "first_service",
    });
  },
);

exports.onChatMessageCreated = onDocumentCreated(
  {
    document: "chats/{chatId}/messages/{messageId}",
    region: "europe-west1",
    timeoutSeconds: 30,
    retry: false,
  },
  async (event) => dispatchChatMessagePush({
    admin,
    snapshot: event.data,
    params: event.params,
  }),
);

exports.onFirstCompletedRecordForSharePrompt = onDocumentWritten(
  {
    document: "records/{recordId}",
    region: "europe-west1",
    timeoutSeconds: 30,
    retry: true,
  },
  async (event) => {
    if (!event.data || !event.data.after.exists) return null;
    const before = event.data.before.exists ? event.data.before.data() : {};
    const after = event.data.after.data() || {};
    if (before.status === "complite" || after.status !== "complite") {
      return null;
    }
    return markSharePromptEligible({
      admin,
      userReference: after.master,
      reason: "first_completed_record",
    });
  },
);

exports.onUserWrittenSyncPublicMasterProfile = onDocumentWritten(
  {
    document: "user/{userId}",
    region: "europe-west1",
    timeoutSeconds: 30,
    retry: true,
  },
  async (event) => {
    const publicReference = admin.firestore()
      .collection("publicMasterProfiles")
      .doc(event.params.userId);
    if (!event.data || !event.data.after.exists) {
      await publicReference.delete().catch((error) => {
        if (error.code !== 5) throw error;
      });
      return;
    }

    const user = event.data.after.data() || {};
    if (!isMasterProfile(user)) {
      await publicReference.delete().catch((error) => {
        if (error.code !== 5) throw error;
      });
      return;
    }

    let authPhone = "";
    if (!normalizePublicProfilePhone(user.phone_number)) {
      try {
        const authUser = await admin.auth().getUser(event.params.userId);
        authPhone = authUser.phoneNumber || "";
      } catch (error) {
        console.warn("Could not load master phone from Firebase Auth", {
          userId: event.params.userId,
          code: error && error.code,
        });
      }
    }

    await publicReference.set({
      ...buildPublicMasterProfile(user, authPhone),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  },
);

function normalizePhone(phone) {
  return normalizeRussianPhone(phone);
}

const temporarySmsCodeLength = 4;

function temporarySmsCodeForPhone(phone) {
  const digits = phone.replace(/\D/g, "");
  return digits
    .slice(-temporarySmsCodeLength)
    .padStart(temporarySmsCodeLength, "0");
}

exports.createTemporaryPhoneAuthToken = functions.https.onRequest(
  async (request, response) => {
    response.set("Access-Control-Allow-Origin", "*");
    response.set("Access-Control-Allow-Headers", "Content-Type");
    response.set("Access-Control-Allow-Methods", "POST, OPTIONS");

    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }

    if (request.method !== "POST") {
      response.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const phone = normalizePhone(request.body && request.body.phone);
      const code = String((request.body && request.body.code) || "").trim();

      if (!phone) {
        response.status(400).json({error: "Invalid phone"});
        return;
      }

      if (!TEST_PHONE_NUMBERS.has(phone)) {
        response.status(403).json({error: "Legacy auth is disabled"});
        return;
      }

      if (code !== temporarySmsCodeForPhone(phone)) {
        response.status(401).json({error: "Invalid code"});
        return;
      }

      const digits = phone.replace(/\D/g, "");
      let userRecord;

      try {
        userRecord = await admin.auth().getUserByPhoneNumber(phone);
      } catch (error) {
        if (error.code !== "auth/user-not-found") {
          console.error("getUserByPhoneNumber failed", error);
          response.status(500).json({error: "Auth lookup failed"});
          return;
        }
      }

      if (!userRecord) {
        try {
          userRecord = await admin.auth().createUser({
            uid: `phone_${digits}`,
            phoneNumber: phone,
          });
        } catch (error) {
          console.error("createUser failed", error);
          response.status(500).json({error: "Auth user creation failed"});
          return;
        }
      }

      const token = await admin.auth().createCustomToken(userRecord.uid, {
        temporaryPhoneAuth: true,
      });

      response.json({token});
    } catch (error) {
      console.error("createTemporaryPhoneAuthToken failed", error);
      response.status(500).json({
        error: "Temporary auth failed",
        details: error && error.message ? error.message : String(error),
      });
    }
  },
);

const phoneAuthHandlers = createPhoneAuthHandlers({admin});

exports.requestPhoneAuthCode = functions
  .runWith({
    timeoutSeconds: 20,
    secrets: [
      "SMSAERO_EMAIL",
      "SMSAERO_API_KEY",
      "SMSAERO_SIGN",
      "SMS_AUTH_HMAC_SECRET",
    ],
  })
  .https.onRequest(phoneAuthHandlers.requestPhoneAuthCode);

exports.verifyPhoneAuthCode = functions
  .runWith({
    timeoutSeconds: 20,
    secrets: ["SMS_AUTH_HMAC_SECRET"],
  })
  .https.onRequest(phoneAuthHandlers.verifyPhoneAuthCode);

exports.moderationCallback = functions
  .runWith({
    timeoutSeconds: 20,
    secrets: ["MODERATION_WEBHOOK_TOKEN"],
  })
  .https.onRequest(
    createModerationCallback({
      admin,
      getExpectedToken: () => process.env.MODERATION_WEBHOOK_TOKEN,
    }),
  );

exports.onServiceAwaitingModeration = onDocumentWritten(
  {
    document: "service/{serviceId}",
    region: "europe-west1",
    timeoutSeconds: 30,
    retry: true,
    secrets: ["API_SECRET_TOKEN"],
  },
  async (event) => {
    if (!event.data) {
      return null;
    }
    return createServiceModerationDispatcher({
      admin,
      getApiSecret: () => process.env.API_SECRET_TOKEN,
    })(event.data, {params: event.params});
  },
);

exports.onReportCreated = onDocumentCreated(
  {
    document: "reports/{reportId}",
    region: "europe-west1",
    timeoutSeconds: 30,
    retry: true,
    secrets: ["API_SECRET_TOKEN"],
  },
  async (event) => createReportModerationDispatcher({
    admin,
    getApiSecret: () => process.env.API_SECRET_TOKEN,
  })(event.data, {params: event.params}),
);

exports.reportModerationCallback = functions
  .runWith({
    timeoutSeconds: 20,
    secrets: ["MODERATION_WEBHOOK_TOKEN"],
  })
  .https.onRequest(
    createReportModerationCallback({
      admin,
      getExpectedToken: () => process.env.MODERATION_WEBHOOK_TOKEN,
    }),
  );

exports.deleteAccount = functions
  .runWith({timeoutSeconds: 60})
  .https.onRequest(createDeleteAccountHandler({admin}));

exports.getAdminStats = functions.https.onRequest(async (request, response) => {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  response.set("Access-Control-Allow-Methods", "GET, OPTIONS");

  if (request.method === "OPTIONS") {
    response.status(204).send("");
    return;
  }

  try {
    const authHeader = request.get("Authorization") || "";
    const idToken = authHeader.startsWith("Bearer ")
      ? authHeader.substring(7)
      : "";

    if (!idToken) {
      response.status(401).json({error: "Unauthorized"});
      return;
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const authUser = await admin.auth().getUser(decodedToken.uid);
    if (authUser.phoneNumber !== "+79183633636") {
      response.status(403).json({error: "Forbidden"});
      return;
    }

    const firestore = admin.firestore();
    const [usersSnapshot, servicesSnapshot] = await Promise.all([
      firestore.collection("user").get(),
      firestore.collection("service").get(),
    ]);

    const onlineUsers = usersSnapshot.docs.filter((doc) => {
      const user = doc.data();
      const tokens = user.fcmTokens;
      return user.pushNotificationsEnabled !== false &&
        Array.isArray(tokens) && tokens.some((token) => token);
    }).length;

    const cityName = (value) => {
      const title = value && typeof value.title === "string"
        ? value.title.trim()
        : "";
      return title || "Город не указан";
    };
    const cityRows = new Map();
    const rowFor = (name) => {
      if (!cityRows.has(name)) {
        cityRows.set(name, {
          city: name,
          users: 0,
          masters: 0,
          services: 0,
          incompleteProfiles: 0,
          completedProfilesWithoutCity: 0,
          activeUsersWithoutCity: 0,
        });
      }
      return cityRows.get(name);
    };

    const masterCitiesByUserId = new Map();
    let mastersTotal = 0;
    for (const document of usersSnapshot.docs) {
      const user = document.data();
      const masterData = user.masterData || {};
      const isMaster = masterData.profileCompleted === true ||
        masterData.onboardingCompleted === true ||
        (typeof masterData.title === "string" && masterData.title.trim()) ||
        (typeof masterData.mainPhoto === "string" && masterData.mainPhoto.trim());
      const masterCity = cityName(masterData.mainAdres);
      const userCity = cityName(user.mainLoc);
      const effectiveUserCity = userCity === "Город не указан"
        ? masterCity
        : userCity;

      // Older registrations did not persist mainLoc. For masters, their
      // profile city is the safest city-level fallback for the same person.
      rowFor(effectiveUserCity).users += 1;
      if (effectiveUserCity === "Город не указан") {
        const displayName = typeof user.display_name === "string"
          ? user.display_name.trim()
          : "";
        const profileCompleted = user.clientProfileCompleted === true ||
          displayName.length > 0;
        if (profileCompleted) {
          rowFor(effectiveUserCity).completedProfilesWithoutCity += 1;
        } else {
          rowFor(effectiveUserCity).incompleteProfiles += 1;
        }
        const tokens = user.fcmTokens;
        if (user.pushNotificationsEnabled !== false &&
            Array.isArray(tokens) && tokens.some((token) => token)) {
          rowFor(effectiveUserCity).activeUsersWithoutCity += 1;
        }
      }
      if (isMaster) {
        mastersTotal += 1;
        masterCitiesByUserId.set(document.id, masterCity);
        rowFor(masterCity).masters += 1;
      }
    }

    for (const document of servicesSnapshot.docs) {
      const service = document.data();
      const ownerId = service.owner && typeof service.owner.id === "string"
        ? service.owner.id
        : "";
      // service.place may contain a street/address. Statistics are grouped
      // strictly by the city selected in the owner's master profile.
      const serviceCity = masterCitiesByUserId.get(ownerId) ||
        "Город не указан";
      rowFor(serviceCity).services += 1;
    }

    const cities = Array.from(cityRows.values()).sort((left, right) => {
      const leftTotal = left.users + left.masters + left.services;
      const rightTotal = right.users + right.masters + right.services;
      if (leftTotal !== rightTotal) return rightTotal - leftTotal;
      return left.city.localeCompare(right.city, "ru");
    });

    response.json({
      usersTotal: usersSnapshot.size,
      mastersTotal,
      usersOnline: onlineUsers,
      servicesTotal: servicesSnapshot.size,
      cities,
    });
  } catch (error) {
    console.error("getAdminStats failed", error);
    response.status(500).json({
      error: "Admin stats failed",
      details: error && error.message ? error.message : String(error),
    });
  }
});

exports.getPublicMasterProfile = functions.https.onRequest(
  async (request, response) => {
    response.set("Access-Control-Allow-Origin", "*");
    response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    response.set("Access-Control-Allow-Methods", "GET, OPTIONS");

    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "GET") {
      response.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const authHeader = request.get("Authorization") || "";
      const idToken = authHeader.startsWith("Bearer ")
        ? authHeader.substring(7)
        : "";
      if (!idToken) {
        response.status(401).json({error: "Unauthorized"});
        return;
      }
      await admin.auth().verifyIdToken(idToken);

      const masterId = String(request.query.masterId || "").trim();
      if (!/^[A-Za-z0-9_-]{1,128}$/.test(masterId)) {
        response.status(400).json({error: "Invalid master id"});
        return;
      }

      const masterSnapshot = await admin
        .firestore()
        .collection("user")
        .doc(masterId)
        .get();
      if (!masterSnapshot.exists) {
        response.status(404).json({error: "Master not found"});
        return;
      }

      const master = masterSnapshot.data() || {};
      let authPhone = "";
      if (!normalizePublicProfilePhone(master.phone_number)) {
        try {
          const authUser = await admin.auth().getUser(masterId);
          authPhone = authUser.phoneNumber || "";
        } catch (error) {
          console.warn("Could not load master phone from Firebase Auth", {
            masterId,
            code: error && error.code,
          });
        }
      }
      const publicProfile = buildPublicMasterProfile(master, authPhone);
      await admin.firestore()
        .collection("publicMasterProfiles")
        .doc(masterId)
        .set({
          ...publicProfile,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      response.json(publicProfile);
    } catch (error) {
      console.error("getPublicMasterProfile failed", error);
      response.status(500).json({error: "Public master profile failed"});
    }
  },
);

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("user/" + user.uid);
  await firestore.collection("user").doc(user.uid).delete();
});

exports.onNotificationCreated = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snapshot) => {
    const notification = snapshot.data();
    // Chat messages are sent by onChatMessageCreated. Older app versions may
    // still create this document, so ignore it here to prevent duplicate push.
    if (notification.type === "chat_message") {
      return null;
    }
    const userRef = notification.user;

    if (!userRef || typeof userRef.get !== "function") {
      console.log("Notification has no user reference");
      return null;
    }

    const userSnapshot = await userRef.get();
    if (!userSnapshot.exists) {
      console.log("Notification user not found");
      return null;
    }

    const user = userSnapshot.data() || {};
    if (user.pushNotificationsEnabled === false) {
      console.log("Notification skipped: user disabled push notifications");
      return null;
    }
    const tokens = Array.isArray(user.fcmTokens)
      ? user.fcmTokens.filter((token) => typeof token === "string" && token)
      : [];

    if (tokens.length === 0) {
      console.log("Notification user has no FCM tokens");
      return null;
    }

    const title = notification.title || "Trusty";
    const body = notification.body || "Новое уведомление";
    const type = notification.type || "notification";

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {title, body},
      data: {
        type: String(type),
        notificationId: snapshot.id,
        chatId: notification.chat ? notification.chat.id : "",
        recordId: notification.record ? notification.record.id : "",
        serviceId: notification.service ? notification.service.id : "",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "trusty_messages",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    });

    const invalidTokens = [];
    response.responses.forEach((result, index) => {
      const code = result.error && result.error.code;
      if (
        code === "messaging/registration-token-not-registered" ||
        code === "messaging/invalid-registration-token"
      ) {
        invalidTokens.push(tokens[index]);
      }
    });

    if (invalidTokens.length > 0) {
      await userRef.update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
      });
    }

    return null;
  });
