"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  identityBackfill,
} = require("../user_identity_sync");

const admin = {
  firestore: {
    Timestamp: {fromMillis: (millis) => ({millis})},
    FieldValue: {serverTimestamp: () => ({serverTimestamp: true})},
  },
};

test("backfills identity fields missing from a sparse push-token profile", () => {
  const updates = identityBackfill(admin, {
    uid: "phone_79990000000",
    phoneNumber: "+79990000000",
    email: null,
    metadata: {creationTime: "2026-08-31T08:00:00.000Z"},
  }, {fcmTokens: ["token"]});

  assert.equal(updates.uid, "phone_79990000000");
  assert.equal(updates.phone_number, "+79990000000");
  assert.deepEqual(updates.created_time, {
    millis: Date.parse("2026-08-31T08:00:00.000Z"),
  });
  assert.equal(updates.isGuest, false);
  assert.deepEqual(updates.registeredAt, {serverTimestamp: true});
});

test("does not overwrite an existing Firestore identity", () => {
  const updates = identityBackfill(admin, {
    uid: "user-1",
    phoneNumber: "+79990000000",
    email: "new@example.com",
    metadata: {creationTime: "2026-08-31T08:00:00.000Z"},
  }, {
    uid: "user-1",
    phone_number: "+78880000000",
    email: "saved@example.com",
    created_time: {millis: 1},
    isGuest: false,
    registeredAt: {millis: 1},
  });
  assert.deepEqual(updates, {});
});

test("marks an anonymous Firebase profile as a guest", () => {
  const updates = identityBackfill(admin, {
    uid: "anonymous-1",
    phoneNumber: null,
    email: null,
    providerData: [],
    metadata: {creationTime: "2026-08-31T08:00:00.000Z"},
  }, {});

  assert.equal(updates.isGuest, true);
  assert.deepEqual(updates.guestCreatedAt, {
    millis: Date.parse("2026-08-31T08:00:00.000Z"),
  });
});
