const test = require("node:test");
const assert = require("node:assert/strict");
const {
  FOUR_DAYS_MS,
  hasEngagementPushToday,
  nextMoscowWindow,
  sharePromptEligible,
  shouldPlanSharePrompt,
} = require("../share_prompt");

test("becomes eligible after four days or an explicit milestone", () => {
  const now = Date.UTC(2026, 7, 13, 12);
  assert.equal(sharePromptEligible({
    created_time: new Date(now - FOUR_DAYS_MS + 1),
  }, now), false);
  assert.equal(sharePromptEligible({
    created_time: new Date(now - FOUR_DAYS_MS),
  }, now), true);
  assert.equal(sharePromptEligible({sharePromptEligibleAt: new Date()}, now), true);
});

test("repeats after four days but never while another prompt is pending", () => {
  const now = Date.UTC(2026, 7, 13, 12);
  const eligible = {
    fcmTokens: ["token"],
    created_time: new Date(now - FOUR_DAYS_MS),
  };
  assert.equal(shouldPlanSharePrompt(eligible, now), true);
  assert.equal(shouldPlanSharePrompt({
    ...eligible,
    sharePromptPushSentAt: new Date(now - FOUR_DAYS_MS),
  }, now), true);
  assert.equal(shouldPlanSharePrompt({
    ...eligible,
    sharePromptShownAt: new Date(now - FOUR_DAYS_MS + 1),
  }, now), false);
  assert.equal(shouldPlanSharePrompt({...eligible, sharePromptDueAt: new Date()}, now), false);
  assert.equal(shouldPlanSharePrompt({created_time: eligible.created_time}, now), false);
});

test("does not plan a share prompt on an engagement push day in Moscow", () => {
  const now = new Date("2026-08-13T12:00:00.000Z");
  assert.equal(hasEngagementPushToday({
    engagementPushDueAt: new Date("2026-08-13T14:00:00.000Z"),
  }, now), true);
  assert.equal(hasEngagementPushToday({
    engagementPushLastSentAt: new Date("2026-08-12T14:00:00.000Z"),
  }, now), false);
});

test("uses the 16:00-18:00 Moscow delivery window", () => {
  const now = new Date("2026-08-13T12:00:00.000Z");
  assert.equal(
    nextMoscowWindow(now, () => 0).toISOString(),
    "2026-08-13T13:00:00.000Z",
  );
  assert.equal(
    nextMoscowWindow(now, () => 0.999999).toISOString(),
    "2026-08-13T14:59:59.992Z",
  );
});
