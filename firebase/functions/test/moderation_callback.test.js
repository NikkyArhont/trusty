const assert = require("node:assert/strict");
const test = require("node:test");

const {
  createModerationCallback,
  secureTokenEquals,
  validateModerationRequest,
} = require("../moderation_callback");

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

function createFakeAdmin(initialService) {
  const state = {
    service: initialService ? {...initialService} : null,
    notification: null,
  };
  const serviceRef = {id: "service_123", path: "service/service_123"};
  const firestore = {
    collection(name) {
      return {
        doc(id) {
          if (name === "service") {
            assert.equal(id, "service_123");
            return serviceRef;
          }
          return {id, path: `${name}/${id}`};
        },
      };
    },
    async runTransaction(callback) {
      return callback({
        async get(ref) {
          assert.equal(ref, serviceRef);
          return {
            exists: state.service !== null,
            data: () => state.service,
          };
        },
        update(ref, update) {
          assert.equal(ref, serviceRef);
          state.service = {...state.service, ...update};
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

  return {admin: {firestore: firestoreFactory}, state};
}

test("accepts an approval payload", () => {
  assert.deepEqual(
    validateModerationRequest({
      serviceId: "service_123",
      status: "approved",
      moderatorId: "telegram:42",
    }),
    {
      serviceId: "service_123",
      status: "approved",
      reason: "",
      moderatorId: "telegram:42",
    },
  );
});

test("requires a rejection reason", () => {
  assert.deepEqual(
    validateModerationRequest({serviceId: "service_123", status: "rejected"}),
    {error: "reason is required when status is rejected"},
  );
});

test("rejects unsupported statuses and unsafe document ids", () => {
  assert.deepEqual(
    validateModerationRequest({serviceId: "../service", status: "approved"}),
    {error: "Invalid serviceId"},
  );
  assert.deepEqual(
    validateModerationRequest({serviceId: "service_123", status: "pending"}),
    {error: "status must be approved or rejected"},
  );
});

test("compares webhook tokens safely", () => {
  assert.equal(secureTokenEquals("secret", "secret"), true);
  assert.equal(secureTokenEquals("wrong", "secret"), false);
  assert.equal(secureTokenEquals("", "secret"), false);
});

test("applies an authenticated approval and creates a notification", async () => {
  const owner = {path: "user/owner"};
  const {admin, state} = createFakeAdmin({status: "onModerate", owner});
  const handler = createModerationCallback({
    admin,
    getExpectedToken: () => "secret",
  });
  const response = createResponse();

  await handler(
    {
      method: "POST",
      body: {
        serviceId: "service_123",
        status: "approved",
        moderatorId: "telegram:42",
      },
      get: () => "Bearer secret",
    },
    response,
  );

  assert.equal(response.statusCode, 200);
  assert.equal(response.body.idempotent, false);
  assert.equal(state.service.status, "show");
  assert.equal(state.service.moderation.status, "approved");
  assert.equal(state.notification.value.user, owner);
});

test("rejects an invalid bearer token before accessing Firestore", async () => {
  const {admin} = createFakeAdmin({status: "onModerate"});
  const handler = createModerationCallback({
    admin,
    getExpectedToken: () => "secret",
  });
  const response = createResponse();

  await handler(
    {
      method: "POST",
      body: {serviceId: "service_123", status: "approved"},
      get: () => "Bearer wrong",
    },
    response,
  );

  assert.equal(response.statusCode, 401);
  assert.deepEqual(response.body, {error: "Unauthorized"});
});
