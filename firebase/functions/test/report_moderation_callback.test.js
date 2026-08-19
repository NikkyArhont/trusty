const assert = require("node:assert/strict");
const test = require("node:test");

const {
  createReportModerationCallback,
  validateReportModerationRequest,
} = require("../report_moderation_callback");

function createResponse() {
  return {
    headers: {},
    statusCode: null,
    body: null,
    set(name, value) {
      this.headers[name] = value;
      return this;
    },
    status(value) {
      this.statusCode = value;
      return this;
    },
    json(value) {
      this.body = value;
      return this;
    },
  };
}

function createFakeAdmin(initialReport) {
  const reportRef = {id: "report_123", path: "reports/report_123"};
  const reporterRef = {id: "reporter", path: "user/reporter"};
  const reportedUserRef = {id: "reported", path: "user/reported"};
  const state = {
    report: initialReport
      ? {
          reporter: reporterRef,
          reportedUser: reportedUserRef,
          ...initialReport,
        }
      : null,
    reportedUser: {display_name: "Нарушитель"},
    notification: null,
    disabledUser: null,
    revokedUserId: null,
  };

  const firestore = {
    collection(name) {
      return {
        doc(id) {
          if (name === "reports") {
            assert.equal(id, "report_123");
            return reportRef;
          }
          return {id, path: `${name}/${id}`};
        },
      };
    },
    async runTransaction(callback) {
      return callback({
        async get(ref) {
          if (ref === reportRef) {
            return {
              exists: state.report !== null,
              data: () => state.report,
            };
          }
          if (ref === reportedUserRef) {
            return {
              exists: state.reportedUser !== null,
              data: () => state.reportedUser,
            };
          }
          throw new Error(`Unexpected reference ${ref.path}`);
        },
        update(ref, update) {
          if (ref === reportRef) {
            state.report = {...state.report, ...update};
          } else if (ref === reportedUserRef) {
            state.reportedUser = {...state.reportedUser, ...update};
          } else {
            throw new Error(`Unexpected update ${ref.path}`);
          }
        },
        set(ref, value) {
          state.notification = {ref, value};
        },
      });
    },
  };
  const firestoreFactory = () => firestore;
  firestoreFactory.FieldValue = {
    serverTimestamp: () => "SERVER_TIMESTAMP",
  };

  return {
    admin: {
      firestore: firestoreFactory,
      auth: () => ({
        async updateUser(uid, update) {
          state.disabledUser = {uid, update};
        },
        async revokeRefreshTokens(uid) {
          state.revokedUserId = uid;
        },
      }),
    },
    state,
  };
}

test("validates the confirmed and blocked report contract", () => {
  assert.deepEqual(
    validateReportModerationRequest({
      reportId: "report_123",
      status: "confirmed",
      action: "blocked",
      reason: "Подтверждённое мошенничество",
    }),
    {
      reportId: "report_123",
      status: "confirmed",
      action: "blocked",
      reason: "Подтверждённое мошенничество",
    },
  );
});

test("rejects invalid report decisions", () => {
  assert.deepEqual(
    validateReportModerationRequest({
      reportId: "../report",
      status: "confirmed",
      action: "none",
      reason: "Причина",
    }),
    {error: "Invalid reportId"},
  );
  assert.deepEqual(
    validateReportModerationRequest({
      reportId: "report_123",
      status: "rejected",
      action: "blocked",
      reason: "Причина",
    }),
    {error: "blocked action requires confirmed status"},
  );
});

test("blocks the reported user and notifies the reporter", async () => {
  const {admin, state} = createFakeAdmin({status: "pending"});
  const handler = createReportModerationCallback({
    admin,
    getExpectedToken: () => "secret",
  });
  const response = createResponse();

  await handler(
    {
      method: "POST",
      body: {
        reportId: "report_123",
        status: "confirmed",
        action: "blocked",
        reason: "Мошенничество подтверждено",
      },
      get: () => "Bearer secret",
    },
    response,
  );

  assert.equal(response.statusCode, 200);
  assert.equal(state.report.status, "confirmed");
  assert.equal(state.report.moderation.action, "blocked");
  assert.equal(state.reportedUser.isBlocked, true);
  assert.deepEqual(state.disabledUser, {
    uid: "reported",
    update: {disabled: true},
  });
  assert.equal(state.revokedUserId, "reported");
  assert.equal(state.notification.value.user.id, "reporter");
  assert.equal(state.notification.value.type, "report_moderation");
});

test("rejects an unauthenticated callback", async () => {
  const {admin} = createFakeAdmin({status: "pending"});
  const handler = createReportModerationCallback({
    admin,
    getExpectedToken: () => "secret",
  });
  const response = createResponse();

  await handler(
    {
      method: "POST",
      body: {
        reportId: "report_123",
        status: "confirmed",
        action: "none",
        reason: "Причина",
      },
      get: () => "Bearer wrong",
    },
    response,
  );

  assert.equal(response.statusCode, 401);
});
