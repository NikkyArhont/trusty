const assert = require("node:assert/strict");
const test = require("node:test");

const {
  buildReportPayload,
  createReportModerationDispatcher,
  profileName,
  timestampToIso,
} = require("../report_moderation_dispatch");

function timestamp(iso) {
  return {toDate: () => new Date(iso)};
}

function userReference(id, data) {
  return {
    id,
    path: `user/${id}`,
    async get() {
      return {exists: true, data: () => data};
    },
  };
}

test("normalizes report timestamps and profile names", () => {
  assert.equal(
    timestampToIso(timestamp("2026-07-28T08:00:00.000Z")),
    "2026-07-28T08:00:00.000Z",
  );
  assert.equal(
    profileName({display_name: "Анна", masterData: {title: "Мастер Анна"}}),
    "Мастер Анна",
  );
});

test("builds the Telegram report payload with the last chat messages", async () => {
  const reporter = userReference("reporter-1", {
    display_name: "Анна",
    phone_number: "+79990000001",
  });
  const reportedUser = userReference("reported-1", {
    display_name: "Борис",
    phone_number: "+79990000002",
  });
  const chatData = {
    client: reporter,
    master: reportedUser,
    clientName: "Анна",
    masterName: "Борис",
  };
  const messages = [
    {
      data: () => ({
        sender: reportedUser,
        type: "image",
        image_url: "https://image",
        created_time: timestamp("2026-07-28T08:02:00.000Z"),
      }),
    },
    {
      data: () => ({
        sender: reporter,
        type: "text",
        text: "Здравствуйте",
        created_time: timestamp("2026-07-28T08:01:00.000Z"),
      }),
    },
  ];
  const chat = {
    id: "chat-1",
    async get() {
      return {exists: true, data: () => chatData};
    },
    collection(name) {
      assert.equal(name, "messages");
      return {
        orderBy(field, direction) {
          assert.equal(field, "created_time");
          assert.equal(direction, "desc");
          return {
            limit(value) {
              assert.equal(value, 30);
              return {get: async () => ({docs: messages})};
            },
          };
        },
      };
    },
  };

  const payload = await buildReportPayload({
    reportId: "report-1",
    report: {
      reporter,
      reportedUser,
      chat,
      reason: "Мошенничество",
      details: "Просит предоплату",
      createdAt: timestamp("2026-07-28T08:03:00.000Z"),
    },
  });

  assert.deepEqual(payload, {
    reportId: "report-1",
    reason: "Мошенничество",
    details: "Просит предоплату",
    reporter: {
      id: "reporter-1",
      name: "Анна",
      phone: "+79990000001",
    },
    reportedUser: {
      id: "reported-1",
      name: "Борис",
      phone: "+79990000002",
    },
    chat: {
      id: "chat-1",
      messages: [
        {
          createdAt: "2026-07-28T08:01:00.000Z",
          senderName: "Анна",
          text: "Здравствуйте",
        },
        {
          createdAt: "2026-07-28T08:02:00.000Z",
          senderName: "Борис",
          text: "[Изображение]",
        },
      ],
    },
    createdAt: "2026-07-28T08:03:00.000Z",
  });
});

test("accepts any successful HTTP response from the report bot", async () => {
  const reporter = userReference("reporter-1", {
    display_name: "Анна",
    phone_number: "+79990000001",
  });
  const reportedUser = userReference("reported-1", {
    display_name: "Борис",
    phone_number: "+79990000002",
  });
  const chat = {
    id: "chat-1",
    async get() {
      return {
        exists: true,
        data: () => ({
          client: reporter,
          master: reportedUser,
          clientName: "Анна",
          masterName: "Борис",
        }),
      };
    },
    collection() {
      return {
        orderBy() {
          return {
            limit() {
              return {get: async () => ({docs: []})};
            },
          };
        },
      };
    },
  };
  let dispatchUpdate = null;
  const snapshot = {
    exists: true,
    data: () => ({
      reporter,
      reportedUser,
      chat,
      reason: "Спам",
      details: "",
      status: "pending",
      createdAt: timestamp("2026-07-28T08:03:00.000Z"),
    }),
    ref: {
      async set(update) {
        dispatchUpdate = update;
      },
    },
  };
  const firestoreFactory = () => ({});
  firestoreFactory.FieldValue = {
    serverTimestamp: () => "SERVER_TIMESTAMP",
    increment: (value) => value,
  };
  const dispatcher = createReportModerationDispatcher({
    admin: {firestore: firestoreFactory},
    getApiSecret: () => "secret",
    httpClient: {
      async post() {
        return {status: 200, data: {success: true}};
      },
    },
  });

  await dispatcher(snapshot, {params: {reportId: "report-1"}});

  assert.equal(dispatchUpdate.moderationDispatch.status, "sent");
});
