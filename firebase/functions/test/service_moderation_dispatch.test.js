const assert = require("node:assert/strict");
const test = require("node:test");

const {
  buildModerationPayload,
  normalizeImages,
  shouldDispatch,
} = require("../service_moderation_dispatch");

test("normalizes nested service image arrays", () => {
  assert.deepEqual(
    normalizeImages(["https://one", ["https://two", "https://one"], ""]),
    ["https://one", "https://two"],
  );
});

test("dispatches new and edited pending services but ignores metadata writes", () => {
  const service = {
    status: "onModerate",
    title: "Массаж",
    price: 2500,
  };
  assert.equal(shouldDispatch(null, service), true);
  assert.equal(shouldDispatch({...service, status: "show"}, service), true);
  assert.equal(
    shouldDispatch(service, {
      ...service,
      moderationDispatch: {status: "sent"},
    }),
    false,
  );
  assert.equal(shouldDispatch(service, {...service, price: 3000}), true);
  assert.equal(shouldDispatch(service, {...service, status: "show"}), false);
});

test("builds the confirmed Telegram bot payload", async () => {
  const owner = {
    id: "owner-1",
    async get() {
      return {
        exists: true,
        data: () => ({
          display_name: "Иван",
          phone_number: "+79990000000",
          masterData: {title: "Иван Петров"},
        }),
      };
    },
  };

  const payload = await buildModerationPayload({
    serviceId: "service-1",
    service: {
      owner,
      categoryKey: "beauty",
      title: "Массаж лица",
      description: "60 минут",
      price: 2500,
      image: [["https://one"], "https://two"],
    },
  });

  assert.deepEqual(payload, {
    serviceId: "service-1",
    creator: {
      userId: "owner-1",
      name: "Иван Петров",
      phone: "+79990000000",
    },
    category: {key: "beauty", title: "Красота"},
    title: "Массаж лица",
    description: "60 минут",
    price: 2500,
    images: ["https://one", "https://two"],
  });
});
