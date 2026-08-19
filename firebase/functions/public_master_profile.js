const crypto = require("crypto");

function nonEmpty(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function normalizePhone(value) {
  const digits = String(value || "").replace(/\D/g, "");
  if (/^8\d{10}$/.test(digits)) return `7${digits.substring(1)}`;
  if (/^\d{10}$/.test(digits)) return `7${digits}`;
  return digits;
}

function isMasterProfile(user) {
  const masterData = user.masterData || {};
  return user.masterMode === true ||
    masterData.onboardingCompleted === true ||
    masterData.profileCompleted === true ||
    nonEmpty(masterData.title) ||
    nonEmpty(masterData.descrip) ||
    nonEmpty(masterData.initCat) ||
    nonEmpty(masterData.mainPhoto);
}

function buildPublicMasterProfile(user, fallbackPhone = "") {
  const masterData = user.masterData || {};
  const normalizedPhone = normalizePhone(user.phone_number) ||
    normalizePhone(fallbackPhone);
  return {
    title: String(masterData.title || user.display_name || "").trim(),
    description: String(masterData.descrip || "").trim(),
    photo: String(masterData.mainPhoto || user.photo_url || "").trim(),
    categoryKey: String(masterData.initCat || "").trim(),
    contactPhoneHash: normalizedPhone
      ? crypto.createHash("sha256").update(normalizedPhone).digest("hex")
      : "",
  };
}

module.exports = {
  buildPublicMasterProfile,
  isMasterProfile,
  normalizePhone,
};
