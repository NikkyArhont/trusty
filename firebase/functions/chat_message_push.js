"use strict";

function referencePath(reference) {
  return reference && typeof reference.path === "string"
    ? reference.path
    : "";
}

function resolveRecipient(chat, senderReference) {
  const senderPath = referencePath(senderReference);
  const clientPath = referencePath(chat && chat.client);
  const masterPath = referencePath(chat && chat.master);

  if (senderPath && senderPath === clientPath) {
    return {
      recipient: chat.master,
      senderName: String(chat.clientName || "Клиент").trim() || "Клиент",
    };
  }
  if (senderPath && senderPath === masterPath) {
    return {
      recipient: chat.client,
      senderName: String(chat.masterName || "Мастер").trim() || "Мастер",
    };
  }
  return null;
}

function messageBody(message) {
  if (message && message.type === "image") return "Фото";
  const text = String((message && message.text) || "").trim();
  return text ? text.substring(0, 180) : "Новое сообщение";
}

async function dispatchChatMessagePush({admin, snapshot, params}) {
  if (!snapshot || !snapshot.exists) return null;

  const message = snapshot.data() || {};
  // Messages connected with an appointment already create their own richer
  // notification document and must not generate a duplicate chat push.
  if (message.record) return null;

  const chatId = String((params && params.chatId) || "").trim();
  if (!chatId) return null;

  const chatSnapshot = await admin.firestore().collection("chats").doc(chatId).get();
  if (!chatSnapshot.exists) {
    console.log("Chat push skipped: chat not found", {chatId});
    return null;
  }

  const resolved = resolveRecipient(chatSnapshot.data() || {}, message.sender);
  if (!resolved || !resolved.recipient) {
    console.log("Chat push skipped: sender is not a chat participant", {chatId});
    return null;
  }

  const recipientSnapshot = await resolved.recipient.get();
  if (!recipientSnapshot.exists) {
    console.log("Chat push skipped: recipient not found", {chatId});
    return null;
  }

  const recipient = recipientSnapshot.data() || {};
  const tokens = Array.isArray(recipient.fcmTokens)
    ? [...new Set(recipient.fcmTokens.filter(
      (token) => typeof token === "string" && token.trim(),
    ))]
    : [];
  if (tokens.length === 0) {
    console.log("Chat push skipped: recipient has no FCM tokens", {
      chatId,
      recipientId: recipientSnapshot.id,
    });
    return null;
  }

  const response = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: {
      title: resolved.senderName,
      body: messageBody(message),
    },
    data: {
      type: "chat_message",
      chatId,
      messageId: snapshot.id,
    },
    android: {
      priority: "high",
      notification: {
        channelId: "trusty_messages",
        sound: "default",
      },
    },
    apns: {
      headers: {"apns-priority": "10"},
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
  });

  const invalidTokens = [];
  const errors = [];
  response.responses.forEach((result, index) => {
    if (result.success) return;
    const code = result.error && result.error.code;
    errors.push(code || "unknown");
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      invalidTokens.push(tokens[index]);
    }
  });

  if (invalidTokens.length > 0) {
    await resolved.recipient.update({
      fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
    });
  }

  console.log("Chat push dispatched", {
    chatId,
    recipientId: recipientSnapshot.id,
    successCount: response.successCount,
    failureCount: response.failureCount,
    errors,
  });
  return null;
}

module.exports = {
  dispatchChatMessagePush,
  messageBody,
  resolveRecipient,
};
