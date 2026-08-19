const axios = require("axios");

const DEFAULT_BOT_URL =
  "https://us-central1-trusty-kzh1sb.cloudfunctions.net/api/moderation";

const CATEGORY_TITLES = {
  health: "Здоровье",
  beauty: "Красота",
  animals: "Животные",
  build: "Строительство",
  repair: "Ремонт",
  home: "Дом и быт",
  auto: "Авто",
  education: "Обучение",
  it_digital: "IT и цифровые услуги",
  photo_video: "Фото и видео",
  legal: "Юридические услуги",
  accounting_finance: "Бухгалтерия и финансы",
  events: "Мероприятия",
  sport_fitness: "Спорт и фитнес",
  psychology: "Психология",
  moving_transport: "Переезды и перевозки",
  garden: "Сад и участок",
  business: "Бизнес-услуги",
};

const MODERATION_FIELDS = [
  "owner",
  "categoryKey",
  "title",
  "description",
  "price",
  "image",
  "place",
];

function normalizeImages(value) {
  const images = [];

  function collect(item) {
    if (typeof item === "string" && item.trim()) {
      images.push(item.trim());
      return;
    }
    if (Array.isArray(item)) {
      item.forEach(collect);
    }
  }

  collect(value);
  return [...new Set(images)];
}

function comparableValue(value) {
  if (value && typeof value.path === "string") {
    return value.path;
  }
  return value;
}

function shouldDispatch(before, after) {
  if (!after || after.status !== "onModerate") {
    return false;
  }
  if (!before || before.status !== "onModerate") {
    return true;
  }

  return MODERATION_FIELDS.some((field) => {
    return JSON.stringify(comparableValue(before[field])) !==
      JSON.stringify(comparableValue(after[field]));
  });
}

function creatorName(user, service) {
  const masterTitle = user?.masterData?.title;
  return String(masterTitle || user?.display_name || service.masterTitle || "")
    .trim();
}

async function buildModerationPayload({serviceId, service}) {
  let user = {};
  if (service.owner && typeof service.owner.get === "function") {
    const userSnapshot = await service.owner.get();
    if (userSnapshot.exists) {
      user = userSnapshot.data() || {};
    }
  }

  const categoryKey = String(service.categoryKey || "").trim();
  const city = String(
    user?.masterData?.mainAdres?.title || service?.place?.title || "",
  ).trim();
  return {
    serviceId,
    creator: {
      userId: service.owner?.id || String(user.uid || ""),
      name: creatorName(user, service),
      phone: String(user.phone_number || "").trim(),
    },
    category: {
      key: categoryKey,
      title: CATEGORY_TITLES[categoryKey] || categoryKey,
    },
    city,
    title: String(service.title || "").trim(),
    description: String(service.description || "").trim(),
    price: Number.isFinite(service.price) ? service.price : 0,
    images: normalizeImages(service.image),
  };
}

function createServiceModerationDispatcher({
  admin,
  httpClient = axios,
  getApiSecret,
  botUrl = DEFAULT_BOT_URL,
}) {
  return async (change, context) => {
    const before = change.before.exists ? change.before.data() : null;
    const after = change.after.exists ? change.after.data() : null;
    if (!shouldDispatch(before, after)) {
      return null;
    }

    const apiSecret = getApiSecret();
    if (!apiSecret) {
      throw new Error("API_SECRET_TOKEN is not configured");
    }

    const payload = await buildModerationPayload({
      serviceId: context.params.serviceId,
      service: after,
    });
    const attemptedAt = admin.firestore.FieldValue.serverTimestamp();

    try {
      const response = await httpClient.post(botUrl, payload, {
        headers: {
          Authorization: `Bearer ${apiSecret}`,
          "Content-Type": "application/json",
        },
        timeout: 20000,
      });

      if (!response.data || response.data.ok !== true) {
        throw new Error("Moderation bot returned an invalid response");
      }

      await change.after.ref.set({
        moderationDispatch: {
          status: "sent",
          sentAt: attemptedAt,
          lastError: null,
          attempts: admin.firestore.FieldValue.increment(1),
        },
      }, {merge: true});
      return null;
    } catch (error) {
      const statusCode = error.response?.status || null;
      const message = error.message || String(error);
      await change.after.ref.set({
        moderationDispatch: {
          status: "failed",
          lastAttemptAt: attemptedAt,
          lastError: message.slice(0, 500),
          statusCode,
          attempts: admin.firestore.FieldValue.increment(1),
        },
      }, {merge: true});

      if (!statusCode || statusCode >= 500) {
        throw error;
      }
      console.error("Moderation bot rejected the service", {
        serviceId: context.params.serviceId,
        statusCode,
        message,
      });
      return null;
    }
  };
}

module.exports = {
  CATEGORY_TITLES,
  DEFAULT_BOT_URL,
  buildModerationPayload,
  createServiceModerationDispatcher,
  normalizeImages,
  shouldDispatch,
};
