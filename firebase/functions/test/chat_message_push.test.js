"use strict";

const assert = require("node:assert/strict");
const test = require("node:test");

const {
  chatNotificationTag,
  isPushEnabled,
  messageBody,
  resolveRecipient,
} = require("../chat_message_push");

const reference = (path) => ({path});

test("selects the master when the client sends a message", () => {
  const master = reference("user/master");
  const result = resolveRecipient({
    client: reference("user/client"),
    master,
    clientName: "Анна",
  }, reference("user/client"));

  assert.equal(result.recipient, master);
  assert.equal(result.senderName, "Анна");
});

test("selects the client when the master sends a message", () => {
  const client = reference("user/client");
  const result = resolveRecipient({
    client,
    master: reference("user/master"),
    masterName: "Иван",
  }, reference("user/master"));

  assert.equal(result.recipient, client);
  assert.equal(result.senderName, "Иван");
});

test("rejects a sender outside the chat", () => {
  assert.equal(resolveRecipient({
    client: reference("user/client"),
    master: reference("user/master"),
  }, reference("user/other")), null);
});

test("builds a safe body for text and image messages", () => {
  assert.equal(messageBody({type: "image"}), "Фото");
  assert.equal(messageBody({type: "text", text: " Привет "}), "Привет");
  assert.equal(messageBody({type: "text", text: ""}), "Новое сообщение");
});

test("uses a stable Android notification tag for each chat", () => {
  assert.equal(
    chatNotificationTag("support_phone_79181209565"),
    "trusty_chat_support_phone_79181209565",
  );
});

test("honors the recipient push preference", () => {
  assert.equal(isPushEnabled({}), true);
  assert.equal(isPushEnabled({pushNotificationsEnabled: true}), true);
  assert.equal(isPushEnabled({pushNotificationsEnabled: false}), false);
});
