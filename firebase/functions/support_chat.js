"use strict";

const SUPPORT_PHONE = "+79183633636";
const SUPPORT_NAME = "Служба поддержки Сарафана";
const SUPPORT_PHOTO =
  "https://trusty-kzh1sb.web.app/assets/app-icon.png";

function bearerToken(request) {
  const header = String(request.get("Authorization") || "");
  return header.startsWith("Bearer ") ? header.substring(7) : "";
}

function setCors(response) {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
}

async function ensureSupportChat({admin, clientAuth, supportAuth}) {
  const firestore = admin.firestore();
  const clientRef = firestore.doc(`user/${clientAuth.uid}`);
  const supportRef = firestore.doc(`user/${supportAuth.uid}`);
  const clientSnapshot = await clientRef.get();
  if (!clientSnapshot.exists) {
    const error = new Error("User profile not found");
    error.code = "profile-not-found";
    throw error;
  }

  const client = clientSnapshot.data() || {};
  const chatId = `support_${clientAuth.uid}`;
  const chatRef = firestore.collection("chats").doc(chatId);
  const existing = await chatRef.get();
  const now = admin.firestore.FieldValue.serverTimestamp();
  const data = {
    client: clientRef,
    master: supportRef,
    participants: [clientRef, supportRef],
    participantIds: [clientAuth.uid, supportAuth.uid],
    clientName: String(client.display_name || clientAuth.phoneNumber || "Пользователь"),
    clientPhoto: String(client.photo_url || ""),
    clientPhone: String(client.phone_number || clientAuth.phoneNumber || ""),
    masterName: SUPPORT_NAME,
    masterPhoto: SUPPORT_PHOTO,
    context: "support",
    supportStatus: "open",
  };
  if (!existing.exists) {
    data.created_time = now;
    data.updated_time = now;
  }
  await chatRef.set(data, {merge: true});
  return chatId;
}

function createEnsureSupportChatHandler({admin}) {
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
      const token = bearerToken(request);
      if (!token) {
        response.status(401).json({error: "Unauthorized"});
        return;
      }

      const decoded = await admin.auth().verifyIdToken(token);
      const [clientAuth, supportAuth] = await Promise.all([
        admin.auth().getUser(decoded.uid),
        admin.auth().getUserByPhoneNumber(SUPPORT_PHONE),
      ]);
      if (clientAuth.uid === supportAuth.uid) {
        response.status(400).json({error: "Support account cannot contact itself"});
        return;
      }

      const clientRef = admin.firestore().doc(`user/${clientAuth.uid}`);
      const clientSnapshot = await clientRef.get();
      if (!clientSnapshot.exists || clientSnapshot.data().isBlocked === true) {
        response.status(403).json({error: "Forbidden"});
        return;
      }

      const chatId = await ensureSupportChat({admin, clientAuth, supportAuth});
      response.status(200).json({chatId});
    } catch (error) {
      console.error("ensureSupportChat failed", error);
      response.status(500).json({error: "Support chat failed"});
    }
  };
}

function createEnsureAdminSupportChatHandler({admin}) {
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
      const token = bearerToken(request);
      if (!token) {
        response.status(401).json({error: "Unauthorized"});
        return;
      }

      const decoded = await admin.auth().verifyIdToken(token);
      const supportAuth = await admin.auth().getUser(decoded.uid);
      if (supportAuth.phoneNumber !== SUPPORT_PHONE) {
        response.status(403).json({error: "Forbidden"});
        return;
      }

      const rawBody = typeof request.body === "string" ?
        JSON.parse(request.body || "{}") :
        (request.body || {});
      const userId = String(rawBody.userId || "").trim();
      if (!userId || userId.length > 128 || !/^[A-Za-z0-9:_-]+$/.test(userId)) {
        response.status(400).json({error: "Invalid userId"});
        return;
      }
      if (userId === supportAuth.uid) {
        response.status(400).json({error: "Support account cannot contact itself"});
        return;
      }

      const clientAuth = await admin.auth().getUser(userId);
      const chatId = await ensureSupportChat({admin, clientAuth, supportAuth});
      response.status(200).json({chatId});
    } catch (error) {
      console.error("ensureAdminSupportChat failed", error);
      if (error && error.code === "profile-not-found") {
        response.status(404).json({error: "User profile not found"});
        return;
      }
      response.status(500).json({error: "Support chat failed"});
    }
  };
}

module.exports = {
  SUPPORT_NAME,
  SUPPORT_PHOTO,
  SUPPORT_PHONE,
  bearerToken,
  createEnsureAdminSupportChatHandler,
  createEnsureSupportChatHandler,
  ensureSupportChat,
};
