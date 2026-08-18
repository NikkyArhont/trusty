const crypto = require("crypto");

const ALLOWED_STATUSES = new Set(["approved", "rejected"]);
const SERVICE_ID_PATTERN = /^[A-Za-z0-9_-]{1,128}$/;

function secureTokenEquals(actual, expected) {
  if (!actual || !expected) {
    return false;
  }

  const actualBuffer = Buffer.from(actual);
  const expectedBuffer = Buffer.from(expected);
  return actualBuffer.length === expectedBuffer.length &&
    crypto.timingSafeEqual(actualBuffer, expectedBuffer);
}

function bearerToken(request) {
  const header = request.get("Authorization") || "";
  return header.startsWith("Bearer ") ? header.slice(7).trim() : "";
}

function validateModerationRequest(body) {
  const serviceId = typeof body?.serviceId === "string"
    ? body.serviceId.trim()
    : "";
  const status = typeof body?.status === "string"
    ? body.status.trim()
    : "";
  const reason = typeof body?.reason === "string" ? body.reason.trim() : "";
  const moderatorId = typeof body?.moderatorId === "string"
    ? body.moderatorId.trim()
    : "";

  if (!SERVICE_ID_PATTERN.test(serviceId)) {
    return {error: "Invalid serviceId"};
  }
  if (!ALLOWED_STATUSES.has(status)) {
    return {error: "status must be approved or rejected"};
  }
  if (status === "rejected" && !reason) {
    return {error: "reason is required when status is rejected"};
  }
  if (reason.length > 2000) {
    return {error: "reason must not exceed 2000 characters"};
  }
  if (moderatorId.length > 128) {
    return {error: "moderatorId must not exceed 128 characters"};
  }

  return {serviceId, status, reason, moderatorId};
}

function createModerationCallback({admin, getExpectedToken}) {
  return async (request, response) => {
    if (request.method !== "POST") {
      response.set("Allow", "POST");
      response.status(405).json({error: "Method not allowed"});
      return;
    }

    const expectedToken = getExpectedToken();
    if (!expectedToken) {
      console.error("MODERATION_WEBHOOK_TOKEN is not configured");
      response.status(500).json({error: "Webhook is not configured"});
      return;
    }

    if (!secureTokenEquals(bearerToken(request), expectedToken)) {
      response.status(401).json({error: "Unauthorized"});
      return;
    }

    const payload = validateModerationRequest(request.body);
    if (payload.error) {
      response.status(400).json({error: payload.error});
      return;
    }

    const firestore = admin.firestore();
    const serviceRef = firestore.collection("service").doc(payload.serviceId);
    const targetStatus = payload.status === "approved" ? "show" : "denied";

    try {
      const result = await firestore.runTransaction(async (transaction) => {
        const serviceSnapshot = await transaction.get(serviceRef);
        if (!serviceSnapshot.exists) {
          return {notFound: true};
        }

        const service = serviceSnapshot.data() || {};
        const previousDecision = service.moderation?.status;
        if (service.status === targetStatus && previousDecision === payload.status) {
          return {idempotent: true};
        }
        if (service.status !== "onModerate") {
          return {conflict: true, currentStatus: service.status || null};
        }

        const decidedAt = admin.firestore.FieldValue.serverTimestamp();
        transaction.update(serviceRef, {
          status: targetStatus,
          moderation: {
            status: payload.status,
            reason: payload.reason || null,
            moderatorId: payload.moderatorId || null,
            source: "telegram_bot",
            decidedAt,
          },
        });

        if (service.owner) {
          const notificationRef = firestore
            .collection("notifications")
            .doc(`service_moderation_${payload.serviceId}_${payload.status}`);
          transaction.set(notificationRef, {
            user: service.owner,
            service: serviceRef,
            title: payload.status === "approved"
              ? "Услуга одобрена"
              : "Услуга отклонена",
            body: payload.status === "approved"
              ? "Ваша услуга опубликована."
              : payload.reason,
            type: "service_moderation",
            read: false,
            createdAt: decidedAt,
          });
        }

        return {idempotent: false};
      });

      if (result.notFound) {
        response.status(404).json({error: "Service not found"});
        return;
      }
      if (result.conflict) {
        response.status(409).json({
          error: "Service is not awaiting moderation",
          currentStatus: result.currentStatus,
        });
        return;
      }

      response.status(200).json({
        ok: true,
        serviceId: payload.serviceId,
        status: payload.status,
        idempotent: result.idempotent,
      });
    } catch (error) {
      console.error("moderationCallback failed", error);
      response.status(500).json({error: "Moderation update failed"});
    }
  };
}

module.exports = {
  createModerationCallback,
  secureTokenEquals,
  validateModerationRequest,
};
