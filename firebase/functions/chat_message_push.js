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

function chatNotificationTag(chatId) {
  return `trusty_chat_${String(chatId || "").trim()}`;
}

function isPushEnabled(user) {
  return !user || user.pushNotificationsEnabled !== false;
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
  if (!isPushEnabled(recipient)) {
    console.log("Chat push skipped: recipient disabled notifications", {chatId});
    return null;
  }
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
        tag: chatNotificationTag(chatId),
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

  if (response.successCount > 0) {
    const deliveredAt = admin.firestore.FieldValue.serverTimestamp();
    await admin.firestore().runTransaction(async (transaction) => {
      const latestChat = await transaction.get(chatSnapshot.ref);
      transaction.update(snapshot.ref, {
        delivered: true,
        delivered_time: deliveredAt,
      });
      if (latestChat.data()?.last_message_id === snapshot.id) {
        transaction.update(chatSnapshot.ref, {
          last_message_status: "delivered",
          last_message_delivered: true,
          last_message_read: false,
        });
      }
    });
  }

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
  chatNotificationTag,
  dispatchChatMessagePush,
  isPushEnabled,
  messageBody,
  resolveRecipient,
};
