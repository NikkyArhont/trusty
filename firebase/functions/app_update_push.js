"use strict";

const ADMIN_PHONE = "+79183633636";
const CONFIRMATION = "SEND_APP_UPDATE_PUSH";
const INVALID_TOKEN_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

function setCors(response) {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
}

function collectRecipients(usersSnapshot) {
  const recipients = new Map();
  for (const document of usersSnapshot.docs) {
    const user = document.data() || {};
    if (user.pushNotificationsEnabled === false) continue;
    const tokens = Array.isArray(user.fcmTokens) ? user.fcmTokens : [];
    for (const value of tokens) {
      const token = typeof value === "string" ? value.trim() : "";
      if (!token) continue;
      if (!recipients.has(token)) recipients.set(token, []);
      recipients.get(token).push(document.ref);
    }
  }
  return recipients;
}

function chunks(values, size = 500) {
  const result = [];
  for (let index = 0; index < values.length; index += size) {
    result.push(values.slice(index, index + size));
  }
  return result;
}

async function dispatchAppUpdatePush({admin}) {
  const usersSnapshot = await admin.firestore().collection("user").get();
  const recipients = collectRecipients(usersSnapshot);
  const tokens = [...recipients.keys()];
  let successCount = 0;
  let failureCount = 0;
  const invalidTokens = new Set();

  for (const tokenChunk of chunks(tokens)) {
    const result = await admin.messaging().sendEachForMulticast({
      tokens: tokenChunk,
      notification: {
        title: "Доступна новая версия",
        body: "Обновите Сарафан в магазине приложений.",
      },
      data: {type: "app_update"},
      android: {
        priority: "high",
        notification: {
          channelId: "trusty_messages",
          sound: "default",
        },
      },
      apns: {payload: {aps: {sound: "default"}}},
    });
    successCount += result.successCount;
    failureCount += result.failureCount;
    result.responses.forEach((response, index) => {
      const code = response.error && response.error.code;
      if (!response.success && INVALID_TOKEN_CODES.has(code)) {
        invalidTokens.add(tokenChunk[index]);
      }
    });
  }

  const removals = [];
  for (const token of invalidTokens) {
    for (const userRef of recipients.get(token) || []) {
      removals.push(userRef.update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(token),
      }));
    }
  }
  await Promise.all(removals);

  return {
    recipientCount: tokens.length,
    successCount,
    failureCount,
    invalidTokenCount: invalidTokens.size,
  };
}

function createAnnounceAppUpdateHandler({admin}) {
  return async (request, response) => {
    setCors(response);
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      response.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const header = String(request.get("Authorization") || "");
      const token = header.startsWith("Bearer ") ? header.substring(7) : "";
      if (!token) {
        response.status(401).json({error: "Unauthorized"});
        return;
      }
      const decoded = await admin.auth().verifyIdToken(token);
      const authUser = await admin.auth().getUser(decoded.uid);
      if (authUser.phoneNumber !== ADMIN_PHONE) {
        response.status(403).json({error: "Forbidden"});
        return;
      }

      const body = typeof request.body === "string" ?
        JSON.parse(request.body || "{}") : (request.body || {});
      if (body.confirmation !== CONFIRMATION) {
        response.status(400).json({error: "Confirmation required"});
        return;
      }

      const result = await dispatchAppUpdatePush({admin});
      console.log("App update push announced", result);
      response.status(200).json(result);
    } catch (error) {
      console.error("announceAppUpdate failed", error);
      response.status(500).json({error: "App update announcement failed"});
    }
  };
}

module.exports = {
  ADMIN_PHONE,
  CONFIRMATION,
  chunks,
  collectRecipients,
  createAnnounceAppUpdateHandler,
  dispatchAppUpdatePush,
};
