"use strict";

const crypto = require("crypto");
const {normalizeRussianPhone, PhoneAuthError, maskPhone} =
  require("./sms_phone_auth");

const TELEGRAM_CHALLENGE_TTL_MS = 5 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;
const MAX_REQUESTS_PER_DAY = 20;

class TelegramPhoneAuthStore {
  constructor({firestore, timestamp}) {
    this.firestore = firestore;
    this.timestamp = timestamp;
    this.challenges = firestore.collection("telegramAuthChallenges");
    this.rateLimits = firestore.collection("telegramAuthRateLimits");
  }

  async createChallenge(challenge) {
    const challengeRef = this.challenges.doc(challenge.challengeId);
    const rateRef = this.rateLimits.doc(challenge.phoneHash);
    await this.firestore.runTransaction(async (transaction) => {
      const rateSnapshot = await transaction.get(rateRef);
      const data = rateSnapshot.exists ? rateSnapshot.data() : {};
      const recent = Array.isArray(data.requestTimestamps)
        ? data.requestTimestamps
            .map((value) => typeof value === "number" ? value : value.toMillis())
            .filter((value) => value > challenge.createdAtMillis - DAY_MS)
        : [];
      if (recent.length >= MAX_REQUESTS_PER_DAY) {
        throw new PhoneAuthError("rate_limit", 429);
      }

      transaction.create(challengeRef, {
        phone: challenge.phone,
        phoneHash: challenge.phoneHash,
        status: "pending",
        createdAt: this.timestamp.fromMillis(challenge.createdAtMillis),
        expiresAt: this.timestamp.fromMillis(challenge.expiresAtMillis),
        deleteAt: this.timestamp.fromMillis(challenge.expiresAtMillis + DAY_MS),
      });
      transaction.set(rateRef, {
        requestTimestamps: [...recent, challenge.createdAtMillis],
        updatedAt: this.timestamp.fromMillis(challenge.createdAtMillis),
      }, {merge: true});
    });
  }

  async consumeConfirmed({challengeId, nowMillis}) {
    const challengeRef = this.challenges.doc(challengeId);
    return this.firestore.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(challengeRef);
      if (!snapshot.exists) return {status: "expired"};
      const challenge = snapshot.data() || {};
      const expiresAt = typeof challenge.expiresAt === "number"
        ? challenge.expiresAt
        : challenge.expiresAt.toMillis();
      if (expiresAt <= nowMillis) {
        if (challenge.status === "pending") {
          transaction.update(challengeRef, {status: "expired"});
        }
        return {status: "expired"};
      }
      if (challenge.status === "consumed") return {status: "consumed"};
      if (challenge.status !== "confirmed") return {status: "pending"};

      transaction.update(challengeRef, {
        status: "consumed",
        consumedAt: this.timestamp.fromMillis(nowMillis),
      });
      return {status: "confirmed", phone: challenge.phone};
    });
  }
}

async function getOrCreateAuthUser(authClient, phone) {
  let userRecord;
  try {
    userRecord = await authClient.getUserByPhoneNumber(phone);
  } catch (error) {
    if (!error || error.code !== "auth/user-not-found") {
      throw new PhoneAuthError("server_unavailable", 503);
    }
  }
  if (!userRecord) {
    try {
      userRecord = await authClient.createUser({
        uid: `phone_${phone.slice(1)}`,
        phoneNumber: phone,
      });
    } catch (error) {
      if (error && (error.code === "auth/uid-already-exists" ||
          error.code === "auth/phone-number-already-exists")) {
        userRecord = await authClient.getUserByPhoneNumber(phone);
      } else {
        throw new PhoneAuthError("server_unavailable", 503);
      }
    }
  }
  return userRecord;
}

class TelegramPhoneAuthService {
  constructor({
    store,
    authClient,
    now = () => Date.now(),
    challengeIdFactory = () => crypto.randomBytes(32).toString("base64url"),
    logger = console,
  }) {
    this.store = store;
    this.authClient = authClient;
    this.now = now;
    this.challengeIdFactory = challengeIdFactory;
    this.logger = logger;
  }

  async create(rawPhone) {
    const phone = normalizeRussianPhone(rawPhone);
    if (!phone) throw new PhoneAuthError("invalid_phone");
    const challengeId = this.challengeIdFactory();
    const createdAtMillis = this.now();
    await this.store.createChallenge({
      challengeId,
      phone,
      phoneHash: crypto.createHash("sha256").update(phone).digest("hex"),
      createdAtMillis,
      expiresAtMillis: createdAtMillis + TELEGRAM_CHALLENGE_TTL_MS,
    });
    this.logger.info("Telegram auth challenge created", {phone: maskPhone(phone)});
    return {
      success: true,
      challengeId,
      botUrl: `https://t.me/Trusty_support_bot?start=login_${challengeId}`,
      expiresIn: TELEGRAM_CHALLENGE_TTL_MS / 1000,
    };
  }

  async status(challengeId) {
    if (typeof challengeId !== "string" ||
        !/^[A-Za-z0-9_-]{40,64}$/.test(challengeId)) {
      throw new PhoneAuthError("invalid_challenge", 400);
    }
    const result = await this.store.consumeConfirmed({
      challengeId,
      nowMillis: this.now(),
    });
    if (result.status !== "confirmed") return {status: result.status};

    const userRecord = await getOrCreateAuthUser(this.authClient, result.phone);
    const token = await this.authClient.createCustomToken(userRecord.uid, {
      phoneAuth: true,
      telegramAuth: true,
    });
    this.logger.info("Telegram auth challenge verified", {
      phone: maskPhone(result.phone),
    });
    return {status: "confirmed", token};
  }
}

function createTelegramPhoneAuthHandlers({admin}) {
  const firestore = admin.firestore();
  const store = new TelegramPhoneAuthStore({
    firestore,
    timestamp: admin.firestore.Timestamp,
  });
  const createService = () => new TelegramPhoneAuthService({
    store,
    authClient: admin.auth(),
  });

  const cors = (response) => {
    response.set("Access-Control-Allow-Origin", "*");
    response.set("Access-Control-Allow-Headers", "Content-Type");
    response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  };
  const run = (handler) => async (request, response) => {
    cors(response);
    if (request.method === "OPTIONS") return response.status(204).send("");
    if (request.method !== "POST") {
      return response.status(405).json({error: "method_not_allowed"});
    }
    try {
      response.json(await handler(createService(), request.body || {}));
    } catch (error) {
      const known = error instanceof PhoneAuthError;
      response.status(known ? error.status : 500).json({
        error: known ? error.code : "server_unavailable",
      });
    }
  };

  return {
    createTelegramPhoneAuth: run((service, body) => service.create(body.phone)),
    checkTelegramPhoneAuth: run((service, body) =>
      service.status(body.challengeId)),
  };
}

module.exports = {
  MAX_REQUESTS_PER_DAY,
  TELEGRAM_CHALLENGE_TTL_MS,
  TelegramPhoneAuthService,
  TelegramPhoneAuthStore,
  createTelegramPhoneAuthHandlers,
  getOrCreateAuthUser,
};
