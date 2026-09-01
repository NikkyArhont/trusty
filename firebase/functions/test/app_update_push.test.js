"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  CONFIRMATION,
  chunks,
  collectRecipients,
  createAnnounceAppUpdateHandler,
} = require("../app_update_push");

function responseRecorder() {
  return {
    statusCode: null,
    body: null,
    set() {},
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(body) {
      this.body = body;
      return this;
    },
    send(body) {
      this.body = body;
      return this;
    },
  };
}

test("collects unique tokens only from users with push enabled", () => {
  const ref = (id) => ({id, update: async () => {}});
  const recipients = collectRecipients({docs: [
    {ref: ref("one"), data: () => ({fcmTokens: ["a", "b"]})},
    {ref: ref("two"), data: () => ({fcmTokens: ["b", "c"]})},
    {ref: ref("off"), data: () => ({
      pushNotificationsEnabled: false,
      fcmTokens: ["d"],
    })},
  ]});
  assert.deepEqual([...recipients.keys()], ["a", "b", "c"]);
  assert.equal(recipients.get("b").length, 2);
});

test("splits multicast recipients into FCM-sized batches", () => {
  assert.deepEqual(chunks([1, 2, 3, 4, 5], 2), [[1, 2], [3, 4], [5]]);
});

test("rejects update announcement without explicit confirmation", async () => {
  const admin = {
    auth: () => ({
      verifyIdToken: async () => ({uid: "admin"}),
      getUser: async () => ({phoneNumber: "+79183633636"}),
    }),
  };
  const request = {
    method: "POST",
    body: {},
    get: () => "Bearer token",
  };
  const response = responseRecorder();
  await createAnnounceAppUpdateHandler({admin})(request, response);
  assert.equal(response.statusCode, 400);
  assert.equal(response.body.error, "Confirmation required");
});

test("requires the support administrator account", async () => {
  const admin = {
    auth: () => ({
      verifyIdToken: async () => ({uid: "regular"}),
      getUser: async () => ({phoneNumber: "+79990000000"}),
    }),
  };
  const request = {
    method: "POST",
    body: {confirmation: CONFIRMATION},
    get: () => "Bearer token",
  };
  const response = responseRecorder();
  await createAnnounceAppUpdateHandler({admin})(request, response);
  assert.equal(response.statusCode, 403);
});
