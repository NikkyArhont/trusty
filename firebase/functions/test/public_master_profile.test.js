const test = require("node:test");
const assert = require("node:assert/strict");
const crypto = require("crypto");
const {
  buildPublicMasterProfile,
  isMasterProfile,
  normalizePhone,
} = require("../public_master_profile");

test("normalizes Russian contact numbers consistently", () => {
  assert.equal(normalizePhone("+7 (918) 123-45-67"), "79181234567");
  assert.equal(normalizePhone("8 918 123 45 67"), "79181234567");
  assert.equal(normalizePhone("9181234567"), "79181234567");
});

test("builds a public profile without exposing the phone number", () => {
  const profile = buildPublicMasterProfile({
    phone_number: "+7 (918) 123-45-67",
    display_name: "Анна",
    masterData: {descrip: "Мастер", initCat: "beauty"},
  });
  assert.equal(profile.title, "Анна");
  assert.equal(
    profile.contactPhoneHash,
    crypto.createHash("sha256").update("79181234567").digest("hex"),
  );
  assert.equal(Object.hasOwn(profile, "phone_number"), false);
});

test("keeps completed master profiles public after switching modes", () => {
  assert.equal(isMasterProfile({masterMode: false, masterData: {}}), false);
  assert.equal(isMasterProfile({
    masterMode: false,
    masterData: {profileCompleted: true},
  }), true);
});
