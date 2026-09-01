"use strict";

function jsonError(response, status, error) {
  response.status(status).json({error});
}

function isMasterProfile(user) {
  const master = user.masterData || {};
  return Boolean(master.profileCompleted === true ||
    (typeof master.title === "string" && master.title.trim() &&
      typeof master.mainPhoto === "string" && master.mainPhoto.trim()));
}

function safeMasterCard(uid, user) {
  const master = user.masterData || {};
  return {
    uid,
    displayName: typeof user.display_name === "string" ? user.display_name : "",
    masterTitle: typeof master.title === "string" ? master.title : "",
    photoUrl: (typeof master.mainPhoto === "string" && master.mainPhoto) ||
      (typeof user.photo_url === "string" && user.photo_url) || "",
  };
}

function createReferralOnboardingHandler({admin, normalizePhone}) {
  return async (request, response) => {
    response.set("Access-Control-Allow-Origin", "*");
    response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      jsonError(response, 405, "Method not allowed");
      return;
    }

    try {
      const authHeader = request.get("Authorization") || "";
      const token = authHeader.startsWith("Bearer ")
        ? authHeader.substring(7)
        : "";
      if (!token) {
        jsonError(response, 401, "Unauthorized");
        return;
      }
      const decoded = await admin.auth().verifyIdToken(token);
      const action = request.body && request.body.action;
      const firestore = admin.firestore();
      const currentReference = firestore.collection("user").doc(decoded.uid);

      if (action === "skip") {
        await currentReference.set({
          referralOnboardingCompleted: true,
          referralOnboardingRequired: false,
          referralSkippedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, {merge: true});
        response.json({ok: true});
        return;
      }

      const phone = normalizePhone(request.body && request.body.phone);
      if (!phone) {
        jsonError(response, 400, "Введите корректный номер телефона");
        return;
      }

      let authUser;
      try {
        authUser = await admin.auth().getUserByPhoneNumber(phone);
      } catch (error) {
        if (error && error.code === "auth/user-not-found") {
          response.json({found: false});
          return;
        }
        throw error;
      }
      if (authUser.uid === decoded.uid) {
        jsonError(response, 400, "Нельзя указать самого себя");
        return;
      }
      const masterDocument = await firestore.collection("user")
        .doc(authUser.uid).get();
      if (!masterDocument.exists || !isMasterProfile(masterDocument.data())) {
        response.json({found: false});
        return;
      }

      if (action === "lookup") {
        response.json({
          found: true,
          master: safeMasterCard(masterDocument.id, masterDocument.data()),
        });
        return;
      }
      if (action !== "accept") {
        jsonError(response, 400, "Unsupported action");
        return;
      }

      await firestore.runTransaction(async (transaction) => {
        const currentDocument = await transaction.get(currentReference);
        const current = currentDocument.data() || {};
        if (current.invitedBy) {
          const error = new Error("Пригласивший мастер уже указан");
          error.status = 409;
          throw error;
        }
        transaction.set(currentReference, {
          invitedBy: masterDocument.ref,
          invitedByUid: masterDocument.id,
          referralAcceptedAt: admin.firestore.FieldValue.serverTimestamp(),
          referralOnboardingCompleted: true,
          referralOnboardingRequired: false,
        }, {merge: true});
      });
      response.json({ok: true});
    } catch (error) {
      console.error("referralOnboarding failed", error);
      jsonError(response, error.status || 500, error.message || "Referral failed");
    }
  };
}

module.exports = {createReferralOnboardingHandler, isMasterProfile, safeMasterCard};
