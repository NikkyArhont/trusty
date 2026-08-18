const axios = require("axios");

const DEFAULT_REPORT_BOT_URL =
  "https://us-central1-trusty-kzh1sb.cloudfunctions.net/api/reports";

function timestampToIso(value) {
  if (value && typeof value.toDate === "function") {
    return value.toDate().toISOString();
  }
  if (value instanceof Date) {
    return value.toISOString();
  }
  return typeof value === "string" ? value : "";
}

function profileName(user, fallback = "") {
  return String(
    user?.masterData?.title ||
      user?.display_name ||
      fallback ||
      "Пользователь",
  ).trim();
}

async function readUser(reference, fallbackName) {
  if (!reference || typeof reference.get !== "function") {
    return {
      id: reference?.id || "",
      name: fallbackName || "Пользователь",
      phone: "",
    };
  }

  const snapshot = await reference.get();
  const user = snapshot.exists ? snapshot.data() || {} : {};
  return {
    id: reference.id || String(user.uid || ""),
    name: profileName(user, fallbackName),
    phone: String(user.phone_number || "").trim(),
  };
}

function participantName(chat, reference) {
  if (!reference) {
    return "Пользователь";
  }
  if (chat.client?.path === reference.path) {
    return String(chat.clientName || "Клиент").trim();
  }
  if (chat.master?.path === reference.path) {
    return String(chat.masterName || "Мастер").trim();
  }
  return "Пользователь";
}

async function readMessages(chatReference, chat) {
  const snapshot = await chatReference
    .collection("messages")
    .orderBy("created_time", "desc")
    .limit(30)
    .get();

  return snapshot.docs
    .map((document) => {
      const message = document.data() || {};
      const text = String(
        message.text ||
          (message.type === "image" ? "[Изображение]" : ""),
      ).trim();
      return {
        createdAt: timestampToIso(message.created_time),
        senderName: participantName(chat, message.sender),
        text,
      };
    })
    .reverse();
}

async function buildReportPayload({reportId, report}) {
  const chatSnapshot = await report.chat.get();
  if (!chatSnapshot.exists) {
    throw new Error("Report chat was not found");
  }
  const chat = chatSnapshot.data() || {};
  const [reporter, reportedUser, messages] = await Promise.all([
    readUser(report.reporter, participantName(chat, report.reporter)),
    readUser(report.reportedUser, participantName(chat, report.reportedUser)),
    readMessages(report.chat, chat),
  ]);

  return {
    reportId,
    reason: String(report.reason || "").trim(),
    details: String(report.details || "").trim(),
    reporter,
    reportedUser,
    chat: {
      id: report.chat.id,
      messages,
    },
    createdAt: timestampToIso(report.createdAt),
  };
}

function createReportModerationDispatcher({
  admin,
  httpClient = axios,
  getApiSecret,
  botUrl = DEFAULT_REPORT_BOT_URL,
}) {
  return async (snapshot, context) => {
    if (!snapshot?.exists) {
      return null;
    }

    const report = snapshot.data() || {};
    if (report.status !== "pending") {
      return null;
    }

    const apiSecret = getApiSecret();
    if (!apiSecret) {
      throw new Error("API_SECRET_TOKEN is not configured");
    }

    const reportId = context.params.reportId;
    const attemptedAt = admin.firestore.FieldValue.serverTimestamp();

    try {
      const payload = await buildReportPayload({reportId, report});
      await httpClient.post(botUrl, payload, {
        headers: {
          Authorization: `Bearer ${apiSecret}`,
          "Content-Type": "application/json",
        },
        timeout: 20000,
      });

      await snapshot.ref.set({
        moderationDispatch: {
          status: "sent",
          sentAt: attemptedAt,
          lastError: null,
          attempts: admin.firestore.FieldValue.increment(1),
        },
      }, {merge: true});
      return null;
    } catch (error) {
      const statusCode = error.response?.status || null;
      if (statusCode === 409) {
        await snapshot.ref.set({
          moderationDispatch: {
            status: "sent",
            sentAt: attemptedAt,
            duplicate: true,
            lastError: null,
            attempts: admin.firestore.FieldValue.increment(1),
          },
        }, {merge: true});
        return null;
      }

      const message = error.message || String(error);
      await snapshot.ref.set({
        moderationDispatch: {
          status: "failed",
          lastAttemptAt: attemptedAt,
          lastError: message.slice(0, 500),
          statusCode,
          attempts: admin.firestore.FieldValue.increment(1),
        },
      }, {merge: true});

      if (!statusCode || statusCode >= 500) {
        throw error;
      }
      console.error("Report bot rejected the complaint", {
        reportId,
        statusCode,
        message,
      });
      return null;
    }
  };
}

module.exports = {
  DEFAULT_REPORT_BOT_URL,
  buildReportPayload,
  createReportModerationDispatcher,
  profileName,
  timestampToIso,
};
