"use strict";

async function authenticatedAnonymousUid({admin, request}) {
  const header = String(request.get("Authorization") || "");
  const token = header.startsWith("Bearer ") ? header.substring(7) : "";
  if (!token) return null;
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    const provider = decoded.firebase && decoded.firebase.sign_in_provider;
    return provider === "anonymous" ? decoded.uid : null;
  } catch (_) {
    return null;
  }
}

async function migrateGuestProfile({admin, guestUid, targetUid}) {
  if (!guestUid || !targetUid || guestUid === targetUid) return false;
  const firestore = admin.firestore();
  const guestRef = firestore.collection("user").doc(guestUid);
  const targetRef = firestore.collection("user").doc(targetUid);

  return firestore.runTransaction(async (transaction) => {
    const [guestSnapshot, targetSnapshot] = await Promise.all([
      transaction.get(guestRef),
      transaction.get(targetRef),
    ]);
    if (!guestSnapshot.exists) return false;

    const guest = guestSnapshot.data() || {};
    const target = targetSnapshot.exists ? targetSnapshot.data() || {} : {};
    const guestTokens = Array.isArray(guest.fcmTokens) ? guest.fcmTokens : [];
    const targetTokens = Array.isArray(target.fcmTokens) ? target.fcmTokens : [];
    const tokens = [...new Set([...targetTokens, ...guestTokens].filter(
      (token) => typeof token === "string" && token.trim(),
    ))];
    const guestFavorites = Array.isArray(guest.favoriteServices) ?
      guest.favoriteServices : [];
    const targetFavorites = Array.isArray(target.favoriteServices) ?
      target.favoriteServices : [];
    const favorites = [...new Map(
      [...targetFavorites, ...guestFavorites].map((reference) => [
        reference && reference.path ? reference.path : String(reference),
        reference,
      ]),
    ).values()].filter(Boolean);

    const targetUpdate = {
      isGuest: false,
      registeredAt: target.registeredAt ||
        admin.firestore.FieldValue.serverTimestamp(),
      guestOriginUid: target.guestOriginUid || guestUid,
      guestMigratedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (tokens.length > 0) targetUpdate.fcmTokens = tokens;
    if (favorites.length > 0) targetUpdate.favoriteServices = favorites;
    if (target.pushNotificationsEnabled === undefined &&
        guest.pushNotificationsEnabled !== undefined) {
      targetUpdate.pushNotificationsEnabled = guest.pushNotificationsEnabled;
    }
    if (!target.created_time && guest.created_time) {
      targetUpdate.created_time = guest.created_time;
    }
    if ((!target.mainLoc || !String(target.mainLoc.title || "").trim()) &&
        guest.mainLoc && String(guest.mainLoc.title || "").trim()) {
      targetUpdate.mainLoc = guest.mainLoc;
    }
    if (Number(guest.guestOpenCount || 0) > 0) {
      targetUpdate.preRegistrationOpenCount =
        Number(guest.guestOpenCount || 0);
    }

    transaction.set(targetRef, targetUpdate, {merge: true});
    transaction.set(guestRef, {
      migratedToUid: targetUid,
      guestMigratedAt: admin.firestore.FieldValue.serverTimestamp(),
      fcmTokens: admin.firestore.FieldValue.delete(),
      engagementPushDueAt: admin.firestore.FieldValue.delete(),
      sharePromptDueAt: admin.firestore.FieldValue.delete(),
    }, {merge: true});
    return true;
  });
}

module.exports = {
  authenticatedAnonymousUid,
  migrateGuestProfile,
};
