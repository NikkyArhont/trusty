const test = require("node:test");
const assert = require("node:assert/strict");
const {
  FIVE_DAYS_MS,
  engagementMessage,
  hasSharePromptToday,
  isDueForPlanning,
  isMasterProfileCompleted,
  isMasterUser,
  nextMoscowWindow,
} = require("../engagement_push");

const tokens = {fcmTokens: ["token"]};
const completedMasterData = {
  title: "Анна",
  descrip: "Парикмахер",
  initCat: "beauty",
  mainPhoto: "https://example.com/photo.jpg",
  mainAdres: {title: "Москва"},
};

test("uses a privacy-safe message for an anonymous guest", () => {
  const message = engagementMessage({user: {isGuest: true}});
  assert.equal(message.kind, "guest");
  assert.equal(message.body.includes("знакомых вам людей"), true);
});

test("recognizes a master even after switching back to client mode", () => {
  assert.equal(isMasterUser({masterMode: false, masterData: {title: "Анна"}}), true);
  assert.equal(isMasterUser({masterMode: false, masterData: {}}), false);
});

test("accepts explicit or fully populated master profile completion", () => {
  assert.equal(isMasterProfileCompleted({
    masterData: {profileCompleted: true},
  }), true);
  assert.equal(isMasterProfileCompleted({masterData: completedMasterData}), true);
  assert.equal(isMasterProfileCompleted({
    masterData: {...completedMasterData, mainPhoto: ""},
  }), false);
});

test("selects engagement text for every user state", () => {
  assert.equal(engagementMessage({user: {}}).kind, "client");
  assert.equal(engagementMessage({
    user: {masterMode: true},
  }).kind, "master_profile_incomplete");
  assert.equal(engagementMessage({
    user: {masterData: completedMasterData},
  }).kind, "master_without_services");
  assert.equal(engagementMessage({
    user: {masterData: completedMasterData},
    hasServices: true,
  }).kind, "master_with_services");
});

test("plans only token owners whose five-day interval elapsed", () => {
  const now = Date.UTC(2026, 7, 13, 12);
  assert.equal(isDueForPlanning(tokens, now), true);
  assert.equal(isDueForPlanning({
    ...tokens,
    pushNotificationsEnabled: false,
  }, now), false);
  assert.equal(isDueForPlanning({}, now), false);
  assert.equal(isDueForPlanning({
    ...tokens,
    engagementPushDueAt: new Date(now),
  }, now), false);
  assert.equal(isDueForPlanning({
    ...tokens,
    engagementPushLastSentAt: new Date(now - FIVE_DAYS_MS + 1),
  }, now), false);
  assert.equal(isDueForPlanning({
    ...tokens,
    engagementPushLastSentAt: new Date(now - FIVE_DAYS_MS),
  }, now), true);
});

test("assigns a time inside today's 16:00-18:00 Moscow window", () => {
  const now = new Date("2026-08-13T12:50:00.000Z");
  assert.equal(
    nextMoscowWindow(now, () => 0).toISOString(),
    "2026-08-13T13:00:00.000Z",
  );
  assert.equal(
    nextMoscowWindow(now, () => 0.999999).toISOString(),
    "2026-08-13T14:59:59.992Z",
  );
});

test("detects a share prompt already assigned for the Moscow day", () => {
  const now = new Date("2026-08-13T12:00:00.000Z");
  assert.equal(hasSharePromptToday({
    sharePromptDueAt: new Date("2026-08-13T14:00:00.000Z"),
  }, now), true);
  assert.equal(hasSharePromptToday({
    sharePromptPushSentAt: new Date("2026-08-12T14:00:00.000Z"),
  }, now), false);
});
