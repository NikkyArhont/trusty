const {
  secureTokenEquals,
} = require("./moderation_callback");

const REPORT_ID_PATTERN = /^[A-Za-z0-9_-]{1,128}$/;
const ALLOWED_REPORT_STATUSES = new Set(["confirmed", "rejected"]);
const ALLOWED_REPORT_ACTIONS = new Set(["none", "blocked"]);

function bearerToken(request) {
  const header = request.get("Authorization") || "";
  return header.startsWith("Bearer ") ? header.slice(7).trim() : "";
}

function validateReportModerationRequest(body) {
  const reportId = typeof body?.reportId === "string"
    ? body.reportId.trim()
    : "";
  const status = typeof body?.status === "string"
    ? body.status.trim()
    : "";
  const action = typeof body?.action === "string"
    ? body.action.trim()
    : "";
  const reason = typeof body?.reason === "string" ? body.reason.trim() : "";

  if (!REPORT_ID_PATTERN.test(reportId)) {
    return {error: "Invalid reportId"};
  }
  if (!ALLOWED_REPORT_STATUSES.has(status)) {
    return {error: "status must be confirmed or rejected"};
  }
  if (!ALLOWED_REPORT_ACTIONS.has(action)) {
    return {error: "action must be none or blocked"};
  }
  if (action === "blocked" && status !== "confirmed") {
    return {error: "blocked action requires confirmed status"};
  }
  if (!reason) {
    return {error: "reason is required"};
  }
  if (reason.length > 2000) {
    return {error: "reason must not exceed 2000 characters"};
  }

  return {reportId, status, action, reason};
}

function notificationText(payload) {
  if (payload.status === "rejected") {
    return {
      title: "Жалоба отклонена",
      body: payload.reason,
    };
  }
  if (payload.action === "blocked") {
    return {
      title: "Пользователь заблокирован",
      body: payload.reason,
    };
  }
  return {
    title: "Нарушение подтверждено",
    body: payload.reason,
  };
}

function createReportModerationCallback({admin, getExpectedToken}) {
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

    const payload = validateReportModerationRequest(request.body);
    if (payload.error) {
      response.status(400).json({error: payload.error});
      return;
    }

    const firestore = admin.firestore();
    const reportRef = firestore.collection("reports").doc(payload.reportId);

    try {
      const result = await firestore.runTransaction(async (transaction) => {
        const reportSnapshot = await transaction.get(reportRef);
        if (!reportSnapshot.exists) {
          return {notFound: true};
        }

        const report = reportSnapshot.data() || {};
        const reportedUser = report.reportedUser;
        if (!reportedUser || !reportedUser.id) {
          return {invalidReportedUser: true};
        }

        let reportedUserSnapshot = null;
        if (payload.action === "blocked") {
          reportedUserSnapshot = await transaction.get(reportedUser);
          if (!reportedUserSnapshot.exists) {
            return {invalidReportedUser: true};
          }
        }

        const previous = report.moderation || {};
        const idempotent =
          report.status === payload.status &&
          previous.status === payload.status &&
          previous.action === payload.action;
        if (!idempotent && report.status !== "pending") {
          return {conflict: true, currentStatus: report.status || null};
        }

        const decidedAt = admin.firestore.FieldValue.serverTimestamp();
        if (!idempotent) {
          transaction.update(reportRef, {
            status: payload.status,
            moderation: {
              status: payload.status,
              action: payload.action,
              reason: payload.reason,
              source: "telegram_bot",
              decidedAt,
            },
          });

          if (payload.action === "blocked") {
            transaction.update(reportedUser, {
              isBlocked: true,
              blockedAt: decidedAt,
              blockedReason: payload.reason,
              blockedReport: reportRef,
            });
          }

          if (report.reporter) {
            const notification = notificationText(payload);
            const notificationRef = firestore
              .collection("notifications")
              .doc(
                `report_moderation_${payload.reportId}_` +
                `${payload.status}_${payload.action}`,
              );
            transaction.set(notificationRef, {
              user: report.reporter,
              chat: report.chat || null,
              title: notification.title,
              body: notification.body,
              type: "report_moderation",
              read: false,
              createdAt: decidedAt,
            });
          }
        }

        return {
          idempotent,
          blockedUserId: payload.action === "blocked"
            ? reportedUser.id
            : null,
        };
      });

      if (result.notFound) {
        response.status(404).json({error: "Report not found"});
        return;
      }
      if (result.invalidReportedUser) {
        response.status(409).json({error: "Reported user not found"});
        return;
      }
      if (result.conflict) {
        response.status(409).json({
          error: "Report has already been moderated",
          currentStatus: result.currentStatus,
        });
        return;
      }

      if (result.blockedUserId) {
        await admin.auth().updateUser(result.blockedUserId, {disabled: true});
        await admin.auth().revokeRefreshTokens(result.blockedUserId);
      }

      response.status(200).json({
        ok: true,
        reportId: payload.reportId,
        status: payload.status,
        action: payload.action,
        idempotent: result.idempotent,
      });
    } catch (error) {
      console.error("reportModerationCallback failed", error);
      response.status(500).json({error: "Report moderation update failed"});
    }
  };
}

module.exports = {
  createReportModerationCallback,
  notificationText,
  validateReportModerationRequest,
};
