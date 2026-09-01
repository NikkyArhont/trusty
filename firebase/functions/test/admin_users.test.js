"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  buildAdminUser,
  isMasterComplete,
  isMasterStarted,
  serializeService,
} = require("../admin_users");

function document(id, data) {
  return {id, data: () => data};
}

test("distinguishes an unfinished master from a complete profile", () => {
  const started = {masterData: {onboardingCompleted: true}};
  const complete = {
    masterData: {
      title: "Мастер",
      descrip: "Описание",
      initCat: "beauty",
      mainPhoto: "photo",
      mainAdres: {title: "Краснодар"},
    },
  };
  assert.equal(isMasterStarted(started), true);
  assert.equal(isMasterComplete(started), false);
  assert.equal(isMasterComplete(complete), true);
});

test("builds admin stages without exposing push tokens", () => {
  const user = buildAdminUser(document("user-1", {
    display_name: "Анна",
    clientProfileCompleted: true,
    mainLoc: {title: "Краснодар"},
    fcmTokens: ["private-token"],
    pushNotificationsEnabled: false,
    masterData: {onboardingCompleted: true},
  }), []);
  assert.equal(user.registrationComplete, true);
  assert.equal(user.hasActiveDevice, true);
  assert.equal(user.pushNotificationsEnabled, false);
  assert.equal(user.isGuest, false);
  assert.equal(user.masterStarted, true);
  assert.equal(user.masterComplete, false);
  assert.equal(JSON.stringify(user).includes("private-token"), false);
});

test("serializes service status, image and moderation reason", () => {
  const service = serializeService(document("service-1", {
    title: "Стрижка",
    price: 1500,
    status: "denied",
    image: [["image-url"]],
    moderation: {reason: "Исправьте описание"},
  }));
  assert.equal(service.status, "denied");
  assert.equal(service.image, "image-url");
  assert.equal(service.moderationReason, "Исправьте описание");
});
