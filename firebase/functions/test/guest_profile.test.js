"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  authenticatedAnonymousUid,
  migrateGuestProfile,
} = require("../guest_profile");

test("accepts only an anonymous caller token", async () => {
  const request = {get: () => "Bearer guest-token"};
  const admin = {
    auth: () => ({
      verifyIdToken: async () => ({
        uid: "guest-1",
        firebase: {sign_in_provider: "anonymous"},
      }),
    }),
  };
  assert.equal(
    await authenticatedAnonymousUid({admin, request}),
    "guest-1",
  );
});

test("moves guest device state to the registered profile", async () => {
  const documents = new Map([
    ["user/guest-1", {
      isGuest: true,
      fcmTokens: ["guest-token"],
      favoriteServices: [{path: "service/one"}],
      pushNotificationsEnabled: true,
      created_time: {millis: 1},
    }],
    ["user/phone-1", {
      fcmTokens: ["account-token"],
      favoriteServices: [{path: "service/two"}],
    }],
  ]);
  const writes = [];
  const reference = (path) => ({path});
  const admin = {
    firestore: Object.assign(() => ({
      collection: (name) => ({doc: (id) => reference(`${name}/${id}`)}),
      runTransaction: async (callback) => callback({
        get: async (ref) => ({
          exists: documents.has(ref.path),
          data: () => documents.get(ref.path),
        }),
        set: (ref, data) => writes.push({path: ref.path, data}),
      }),
    }), {
      FieldValue: {
        serverTimestamp: () => "server-time",
        delete: () => "delete-field",
      },
    }),
  };

  assert.equal(await migrateGuestProfile({
    admin,
    guestUid: "guest-1",
    targetUid: "phone-1",
  }), true);
  const targetWrite = writes.find((write) => write.path === "user/phone-1");
  assert.deepEqual(targetWrite.data.fcmTokens, [
    "account-token",
    "guest-token",
  ]);
  assert.equal(targetWrite.data.isGuest, false);
  assert.equal(targetWrite.data.favoriteServices.length, 2);
});
