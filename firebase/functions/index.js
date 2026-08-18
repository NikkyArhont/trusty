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
const {
  buildPublicMasterProfile,
  isMasterProfile,
} = require("./public_master_profile");
admin.initializeApp();

const telegramPhoneAuthHandlers = createTelegramPhoneAuthHandlers({admin});

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

    await publicReference.set({
      ...buildPublicMasterProfile(user),
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
    const [usersSnapshot, servicesCountSnapshot] = await Promise.all([
      firestore.collection("user").get(),
      firestore.collection("service").count().get(),
    ]);

    const onlineUsers = usersSnapshot.docs.filter((doc) => {
      const tokens = doc.data().fcmTokens;
      return Array.isArray(tokens) && tokens.some((token) => token);
    }).length;

    response.json({
      usersTotal: usersSnapshot.size,
      usersOnline: onlineUsers,
      servicesTotal: servicesCountSnapshot.data().count || 0,
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

      const publicProfile = buildPublicMasterProfile(
        masterSnapshot.data() || {},
      );
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
