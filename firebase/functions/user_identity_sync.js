"use strict";

const ADMIN_PHONE = "+79183633636";
const APPLY_CONFIRMATION = "REPAIR_USER_IDENTITIES";

function timestampForAuthUser(admin, user) {
  const millis = Date.parse(user.metadata && user.metadata.creationTime);
  return Number.isFinite(millis) ?
    admin.firestore.Timestamp.fromMillis(millis) :
    admin.firestore.FieldValue.serverTimestamp();
}

function isAnonymousAuthUser(user) {
  return !String(user.phoneNumber || "").trim() &&
    !String(user.email || "").trim() &&
    (!Array.isArray(user.providerData) || user.providerData.length === 0);
}

function identityBackfill(admin, user, profile) {
  const updates = {};
  const isGuest = isAnonymousAuthUser(user);
  if (!String(profile.uid || "").trim()) updates.uid = user.uid;
  const phone = String(user.phoneNumber || "").trim();
  if (!String(profile.phone_number || "").trim() && phone) {
    updates.phone_number = phone;
  }
  const email = String(user.email || "").trim();
  if (!String(profile.email || "").trim() && email) updates.email = email;
  if (!profile.created_time) {
    updates.created_time = timestampForAuthUser(admin, user);
  }
  if (profile.isGuest !== isGuest) updates.isGuest = isGuest;
  if (isGuest && !profile.guestCreatedAt) {
    updates.guestCreatedAt = timestampForAuthUser(admin, user);
  }
  if (!isGuest && !profile.registeredAt) {
    updates.registeredAt = admin.firestore.FieldValue.serverTimestamp();
  }
  return updates;
}

async function ensureAuthUserProfile({admin, user}) {
  const userRef = admin.firestore().collection("user").doc(user.uid);
  const snapshot = await userRef.get();
  const updates = identityBackfill(
    admin,
    user,
    snapshot.exists ? snapshot.data() || {} : {},
  );
  if (Object.keys(updates).length > 0) {
    await userRef.set(updates, {merge: true});
  }
  return updates;
}

async function repairUserIdentities({admin, apply = false}) {
  const snapshot = await admin.firestore().collection("user").get();
  const changes = [];
  const skippedAuthUsers = [];

  for (const document of snapshot.docs) {
    let authUser;
    try {
      authUser = await admin.auth().getUser(document.id);
    } catch (error) {
      if (error && error.code === "auth/user-not-found") {
        skippedAuthUsers.push(document.id);
        continue;
      }
      throw error;
    }
    const updates = identityBackfill(admin, authUser, document.data() || {});
    const fields = Object.keys(updates);
    if (fields.length === 0) continue;
    changes.push({
      userId: document.id,
      phoneNumber: updates.phone_number || null,
      fields,
      reference: document.ref,
      updates,
    });
  }

  if (apply) {
    for (let index = 0; index < changes.length; index += 500) {
      const batch = admin.firestore().batch();
      for (const change of changes.slice(index, index + 500)) {
        batch.set(change.reference, change.updates, {merge: true});
      }
      await batch.commit();
    }
  }

  return {
    scannedCount: snapshot.size,
    changedCount: changes.length,
    skippedAuthUserCount: skippedAuthUsers.length,
    skippedAuthUsers,
    changes: changes.map(({userId, phoneNumber, fields}) => ({
      userId,
      phoneNumber,
      fields,
    })),
  };
}

function setCors(response) {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
}

function createRepairUserIdentitiesHandler({admin}) {
  return async (request, response) => {
    setCors(response);
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      response.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const header = String(request.get("Authorization") || "");
      const token = header.startsWith("Bearer ") ? header.substring(7) : "";
      if (!token) {
        response.status(401).json({error: "Unauthorized"});
        return;
      }
      const decoded = await admin.auth().verifyIdToken(token);
      const caller = await admin.auth().getUser(decoded.uid);
      if (caller.phoneNumber !== ADMIN_PHONE) {
        response.status(403).json({error: "Forbidden"});
        return;
      }

      const body = typeof request.body === "string" ?
        JSON.parse(request.body || "{}") : (request.body || {});
      const apply = body.confirmation === APPLY_CONFIRMATION;
      const result = await repairUserIdentities({admin, apply});
      console.log("User identity repair", {
        apply,
        scannedCount: result.scannedCount,
        changedCount: result.changedCount,
        skippedAuthUserCount: result.skippedAuthUserCount,
      });
      response.status(200).json({...result, applied: apply});
    } catch (error) {
      console.error("repairUserIdentities failed", error);
      response.status(500).json({error: "User identity repair failed"});
    }
  };
}

module.exports = {
  ADMIN_PHONE,
  APPLY_CONFIRMATION,
  createRepairUserIdentitiesHandler,
  ensureAuthUserProfile,
  identityBackfill,
  isAnonymousAuthUser,
  repairUserIdentities,
  timestampForAuthUser,
};
