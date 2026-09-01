"use strict";

const ADMIN_PHONE = "+79183633636";

function timestampToIso(value) {
  if (!value) return null;
  if (typeof value.toDate === "function") return value.toDate().toISOString();
  if (value instanceof Date) return value.toISOString();
  return null;
}

function text(value) {
  return typeof value === "string" ? value.trim() : "";
}

function placeTitle(value) {
  return value && typeof value === "object" ? text(value.title) : "";
}

function isMasterStarted(user) {
  const master = user.masterData || {};
  return user.masterMode === true ||
    master.onboardingCompleted === true ||
    master.profileCompleted === true ||
    Boolean(
      text(master.title) ||
      text(master.descrip) ||
      text(master.initCat) ||
      text(master.mainPhoto) ||
      placeTitle(master.mainAdres),
    );
}

function isMasterComplete(user) {
  const master = user.masterData || {};
  return Boolean(
    text(master.title) &&
    text(master.descrip) &&
    text(master.initCat) &&
    text(master.mainPhoto) &&
    placeTitle(master.mainAdres),
  );
}

function serializeService(document) {
  const service = document.data() || {};
  const images = Array.isArray(service.image)
    ? service.image.flat(Infinity).filter((value) => typeof value === "string")
    : [];
  return {
    id: document.id,
    title: text(service.title) || "Без названия",
    description: text(service.description),
    price: Number.isFinite(service.price) ? service.price : 0,
    duration: Number.isFinite(service.time) ? service.time : 0,
    durationUnit: text(service.timeUnit) || "min",
    categoryKey: text(service.categoryKey),
    city: placeTitle(service.place),
    status: text(service.status) || "unknown",
    image: images.length > 0 ? images[0] : "",
    moderationReason: service.moderation && typeof service.moderation === "object"
      ? text(service.moderation.reason)
      : "",
  };
}

function buildAdminUser(document, services) {
  const user = document.data() || {};
  const master = user.masterData || {};
  const displayName = text(user.display_name);
  const phone = text(user.phone_number);
  const isGuest = user.isGuest === true;
  const registrationComplete = !isGuest &&
    (user.clientProfileCompleted === true || Boolean(displayName));
  const clientCity = placeTitle(user.mainLoc);
  const masterCity = placeTitle(master.mainAdres);
  const started = isMasterStarted(user);
  const complete = isMasterComplete(user);
  return {
    id: document.id,
    displayName: displayName || phone || (isGuest ? "Гость" : "Пользователь"),
    phone,
    email: text(user.email),
    photo: text(user.photo_url),
    bio: text(user.bio),
    createdAt: timestampToIso(user.created_time),
    lastActiveAt: timestampToIso(user.lastActiveAt),
    hasActiveDevice: Array.isArray(user.fcmTokens) &&
      user.fcmTokens.some((token) => text(token)),
    pushNotificationsEnabled: user.pushNotificationsEnabled !== false,
    isGuest,
    registrationComplete,
    clientCity,
    masterStarted: started,
    masterComplete: complete,
    master: {
      title: text(master.title),
      description: text(master.descrip),
      categoryKey: text(master.initCat),
      photo: text(master.mainPhoto),
      city: masterCity,
      onboardingComplete: master.onboardingCompleted === true,
      profileCompleteFlag: master.profileCompleted === true,
    },
    services,
  };
}

function createGetAdminUsersHandler({admin}) {
  return async (request, response) => {
    response.set("Access-Control-Allow-Origin", "*");
    response.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
    response.set("Access-Control-Allow-Methods", "GET, OPTIONS");
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "GET") {
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
      const authUser = await admin.auth().getUser(decoded.uid);
      if (authUser.phoneNumber !== ADMIN_PHONE) {
        response.status(403).json({error: "Forbidden"});
        return;
      }

      const firestore = admin.firestore();
      const [usersSnapshot, servicesSnapshot] = await Promise.all([
        firestore.collection("user").get(),
        firestore.collection("service").get(),
      ]);
      const servicesByOwner = new Map();
      for (const document of servicesSnapshot.docs) {
        const ownerId = document.data().owner && document.data().owner.id;
        if (!ownerId) continue;
        if (!servicesByOwner.has(ownerId)) servicesByOwner.set(ownerId, []);
        servicesByOwner.get(ownerId).push(serializeService(document));
      }

      const users = usersSnapshot.docs.map((document) => buildAdminUser(
        document,
        servicesByOwner.get(document.id) || [],
      ));
      response.status(200).json({
        generatedAt: new Date().toISOString(),
        users,
      });
    } catch (error) {
      console.error("getAdminUsers failed", error);
      response.status(500).json({error: "Admin users failed"});
    }
  };
}

module.exports = {
  ADMIN_PHONE,
  buildAdminUser,
  createGetAdminUsersHandler,
  isMasterComplete,
  isMasterStarted,
  serializeService,
  timestampToIso,
};
