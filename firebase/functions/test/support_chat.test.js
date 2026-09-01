"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  SUPPORT_NAME,
  SUPPORT_PHOTO,
  SUPPORT_PHONE,
  bearerToken,
  createEnsureAdminSupportChatHandler,
  createEnsureSupportChatHandler,
} = require("../support_chat");

function responseRecorder() {
  return {
    statusCode: 200,
    body: null,
    set() {},
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(body) {
      this.body = body;
    },
    send(body) {
      this.body = body;
    },
  };
}

test("extracts only a bearer authorization token", () => {
  assert.equal(bearerToken({get: () => "Bearer token-123"}), "token-123");
  assert.equal(bearerToken({get: () => "Basic token-123"}), "");
});

test("creates one deterministic support chat with the official identity", async () => {
  const writes = [];
  const clientRef = {
    path: "user/client-uid",
    get: async () => ({
      exists: true,
      data: () => ({display_name: "Анна", phone_number: "+70000000000"}),
    }),
  };
  const supportRef = {path: "user/support-uid"};
  const chatRef = {
    get: async () => ({exists: false}),
    set: async (data, options) => writes.push({data, options}),
  };
  const admin = {
    auth: () => ({
      verifyIdToken: async () => ({uid: "client-uid"}),
      getUser: async () => ({uid: "client-uid", phoneNumber: "+70000000000"}),
      getUserByPhoneNumber: async (phone) => {
        assert.equal(phone, SUPPORT_PHONE);
        return {uid: "support-uid"};
      },
    }),
    firestore: Object.assign(
      () => ({
        doc: (path) => (path === clientRef.path ? clientRef : supportRef),
        collection: () => ({doc: () => chatRef}),
      }),
      {FieldValue: {serverTimestamp: () => "server-time"}},
    ),
  };
  const request = {
    method: "POST",
    get: () => "Bearer valid-token",
  };
  const response = responseRecorder();

  await createEnsureSupportChatHandler({admin})(request, response);

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.body, {chatId: "support_client-uid"});
  assert.equal(writes.length, 1);
  assert.equal(writes[0].data.context, "support");
  assert.equal(writes[0].data.masterName, SUPPORT_NAME);
  assert.equal(writes[0].data.masterPhoto, SUPPORT_PHOTO);
  assert.deepEqual(writes[0].data.participantIds, ["client-uid", "support-uid"]);
  assert.deepEqual(writes[0].options, {merge: true});
});

test("lets only the support admin start a chat with a user", async () => {
  const writes = [];
  const refs = {
    "user/client-uid": {
      path: "user/client-uid",
      get: async () => ({
        exists: true,
        data: () => ({display_name: "Анна", phone_number: "+70000000000"}),
      }),
    },
    "user/support-uid": {path: "user/support-uid"},
  };
  const chatRef = {
    get: async () => ({exists: false}),
    set: async (data, options) => writes.push({data, options}),
  };
  const admin = {
    auth: () => ({
      verifyIdToken: async () => ({uid: "support-uid"}),
      getUser: async (uid) => uid === "support-uid" ?
        {uid, phoneNumber: SUPPORT_PHONE} :
        {uid, phoneNumber: "+70000000000"},
    }),
    firestore: Object.assign(
      () => ({
        doc: (path) => refs[path],
        collection: () => ({doc: () => chatRef}),
      }),
      {FieldValue: {serverTimestamp: () => "server-time"}},
    ),
  };
  const request = {
    method: "POST",
    body: {userId: "client-uid"},
    get: () => "Bearer valid-token",
  };
  const response = responseRecorder();

  await createEnsureAdminSupportChatHandler({admin})(request, response);

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.body, {chatId: "support_client-uid"});
  assert.deepEqual(writes[0].data.participantIds, ["client-uid", "support-uid"]);
});

test("rejects support-chat creation by a regular user", async () => {
  const admin = {
    auth: () => ({
      verifyIdToken: async () => ({uid: "regular-uid"}),
      getUser: async () => ({uid: "regular-uid", phoneNumber: "+70000000000"}),
    }),
  };
  const request = {
    method: "POST",
    body: {userId: "client-uid"},
    get: () => "Bearer valid-token",
  };
  const response = responseRecorder();

  await createEnsureAdminSupportChatHandler({admin})(request, response);

  assert.equal(response.statusCode, 403);
  assert.deepEqual(response.body, {error: "Forbidden"});
});
