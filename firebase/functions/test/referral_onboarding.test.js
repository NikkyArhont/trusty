"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  isMasterProfile,
  safeMasterCard,
} = require("../referral_onboarding");

test("recognizes only a completed or populated master profile", () => {
  assert.equal(isMasterProfile({masterData: {profileCompleted: true}}), true);
  assert.equal(isMasterProfile({
    masterData: {title: "Студия", mainPhoto: "https://photo"},
  }), true);
  assert.equal(isMasterProfile({masterData: {title: "Студия"}}), false);
});

test("returns only safe master card fields", () => {
  assert.deepEqual(safeMasterCard("master-1", {
    display_name: "Анна",
    phone_number: "+79990000000",
    masterData: {title: "Массаж", mainPhoto: "https://master-photo"},
  }), {
    uid: "master-1",
    displayName: "Анна",
    masterTitle: "Массаж",
    photoUrl: "https://master-photo",
  });
});
