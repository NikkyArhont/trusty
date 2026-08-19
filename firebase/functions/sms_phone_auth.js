"use strict";

const crypto = require("crypto");

const {SmsAeroClient} = require("./sms_aero_client");

const TEST_PHONE_NUMBERS = new Set([
  "+79183633636",
  "+79180000000",
  "+79181111111",
  "+79280352841",
  "+79181209565",
]);

const CODE_TTL_MS = 5 * 60 * 1000;
const RESEND_DELAY_MS = 60 * 1000;
const HOUR_MS = 60 * 60 * 1000;
const DAY_MS = 24 * HOUR_MS;
const MAX_SENDS_PER_HOUR = 5;
const MAX_SENDS_PER_DAY = 10;
const MAX_CODE_ATTEMPTS = 5;

class PhoneAuthError extends Error {
  constructor(code, status = 400) {
    super(code);
    this.name = "PhoneAuthError";
    this.code = code;
    this.status = status;
  }
}

function normalizeRussianPhone(value) {
  if (typeof value !== "string") {
    return "";
  }

  let digits = value.replace(/\D/g, "");
  if (digits.length === 11 && digits.startsWith("8")) {
    digits = `7${digits.slice(1)}`;
  }

  if (digits.length !== 11 || !digits.startsWith("7")) {
    return "";
  }

  return `+${digits}`;
}

function maskPhone(phone) {
  return `${phone.slice(0, 5)}***${phone.slice(-4)}`;
}

function hmac(secret, value) {
  return crypto.createHmac("sha256", secret).update(value).digest("hex");
}

function secureEqual(left, right) {
  const leftBuffer = Buffer.from(String(left));
  const rightBuffer = Buffer.from(String(right));
  return (
    leftBuffer.length === rightBuffer.length &&
    crypto.timingSafeEqual(leftBuffer, rightBuffer)
  );
}

function generateCode(randomInt = crypto.randomInt) {
  return String(randomInt(0, 10000)).padStart(4, "0");
}

class FirestorePhoneAuthStore {
  constructor({firestore, timestamp}) {
    this.firestore = firestore;
    this.timestamp = timestamp;
    this.challenges = firestore.collection("smsAuthChallenges");
    this.rateLimits = firestore.collection("smsAuthRateLimits");
  }

  async reserveChallenge(challenge) {
    const rateRef = this.rateLimits.doc(challenge.phoneHash);
    const challengeRef = this.challenges.doc(challenge.verificationId);

    await this.firestore.runTransaction(async (transaction) => {
      const rateSnapshot = await transaction.get(rateRef);
      const rateData = rateSnapshot.exists ? rateSnapshot.data() : {};
      const recentTimestamps = Array.isArray(rateData.sendTimestamps)
        ? rateData.sendTimestamps
            .map((value) =>
              typeof value === "number" ? value : value.toMillis(),
            )
            .filter((value) => value > challenge.createdAtMillis - DAY_MS)
        : [];

      const lastRequestAtMillis =
        typeof rateData.lastRequestAtMillis === "number"
          ? rateData.lastRequestAtMillis
          : 0;
      if (
        !challenge.isTestNumber &&
        lastRequestAtMillis &&
        challenge.createdAtMillis - lastRequestAtMillis < RESEND_DELAY_MS
      ) {
        throw new PhoneAuthError("resend_too_soon", 429);
      }

      const sendsLastHour = recentTimestamps.filter(
        (value) => value > challenge.createdAtMillis - HOUR_MS,
      ).length;
      if (
        !challenge.isTestNumber &&
        (sendsLastHour >= MAX_SENDS_PER_HOUR ||
          recentTimestamps.length >= MAX_SENDS_PER_DAY)
      ) {
        throw new PhoneAuthError("rate_limit", 429);
      }

      let previousRef = null;
      let previousSnapshot = null;
      if (rateData.activeVerificationId) {
        previousRef = this.challenges.doc(rateData.activeVerificationId);
        previousSnapshot = await transaction.get(previousRef);
      }

      if (previousSnapshot && previousSnapshot.exists) {
        transaction.update(previousRef, {
          status: "superseded",
          used: true,
          invalidatedAt: this.timestamp.fromMillis(challenge.createdAtMillis),
        });
      }

      transaction.create(challengeRef, {
        phoneHash: challenge.phoneHash,
        codeHash: challenge.codeHash,
        isTestNumber: challenge.isTestNumber,
        createdAt: this.timestamp.fromMillis(challenge.createdAtMillis),
        expiresAt: this.timestamp.fromMillis(challenge.expiresAtMillis),
        resendAvailableAt: this.timestamp.fromMillis(
          challenge.resendAvailableAtMillis,
        ),
        attempts: 0,
        used: false,
        status: challenge.isTestNumber ? "active" : "sending",
        provider: challenge.isTestNumber ? "test" : "smsaero",
        providerMessageId: null,
        deleteAt: this.timestamp.fromMillis(
          challenge.expiresAtMillis + DAY_MS,
        ),
      });

      transaction.set(rateRef, {
        sendTimestamps: [...recentTimestamps, challenge.createdAtMillis],
        lastRequestAtMillis: challenge.createdAtMillis,
        activeVerificationId: challenge.verificationId,
        updatedAt: this.timestamp.fromMillis(challenge.createdAtMillis),
      });
    });
  }

  async markSent({verificationId, messageId}) {
    await this.challenges.doc(verificationId).update({
      status: "active",
      providerMessageId: messageId,
    });
  }

  async markFailed({verificationId, phoneHash, requestAtMillis}) {
    const challengeRef = this.challenges.doc(verificationId);
    const rateRef = this.rateLimits.doc(phoneHash);
    await this.firestore.runTransaction(async (transaction) => {
      const rateSnapshot = await transaction.get(rateRef);
      const rateData = rateSnapshot.exists ? rateSnapshot.data() : {};
      const timestamps = Array.isArray(rateData.sendTimestamps)
        ? rateData.sendTimestamps
            .map((value) =>
              typeof value === "number" ? value : value.toMillis(),
            )
            .filter((value) => value !== requestAtMillis)
        : [];

      transaction.update(challengeRef, {
        status: "failed",
        used: true,
      });
      transaction.set(
        rateRef,
        {
          sendTimestamps: timestamps,
          lastRequestAtMillis:
            timestamps.length === 0 ? 0 : Math.max(...timestamps),
          activeVerificationId:
            rateData.activeVerificationId === verificationId
              ? null
              : rateData.activeVerificationId || null,
        },
        {merge: true},
      );
    });
  }

  async consumeChallenge({
    verificationId,
    phoneHash,
    submittedCodeHash,
    nowMillis,
  }) {
    const challengeRef = this.challenges.doc(verificationId);
    const rejectionCode = await this.firestore.runTransaction(
      async (transaction) => {
        const snapshot = await transaction.get(challengeRef);
        if (!snapshot.exists) {
          throw new PhoneAuthError("invalid_code", 401);
        }

        const challenge = snapshot.data();
        if (challenge.phoneHash !== phoneHash) {
          throw new PhoneAuthError("invalid_code", 401);
        }
        if (challenge.status === "blocked") {
          throw new PhoneAuthError("too_many_attempts", 429);
        }
        if (challenge.status !== "active" || challenge.used) {
          throw new PhoneAuthError("invalid_code", 401);
        }

        const expiresAtMillis =
          typeof challenge.expiresAt === "number"
            ? challenge.expiresAt
            : challenge.expiresAt.toMillis();
        if (expiresAtMillis <= nowMillis) {
          transaction.update(challengeRef, {
            status: "expired",
            used: true,
          });
          return "expired_code";
        }

        const attempts = Number(challenge.attempts || 0);
        if (attempts >= MAX_CODE_ATTEMPTS) {
          throw new PhoneAuthError("too_many_attempts", 429);
        }

        if (!secureEqual(challenge.codeHash, submittedCodeHash)) {
          const nextAttempts = attempts + 1;
          transaction.update(challengeRef, {
            attempts: nextAttempts,
            ...(nextAttempts >= MAX_CODE_ATTEMPTS
              ? {status: "blocked", used: true}
              : {}),
          });
          return nextAttempts >= MAX_CODE_ATTEMPTS
            ? "too_many_attempts"
            : "invalid_code";
        }

        transaction.update(challengeRef, {
          status: "used",
          used: true,
          usedAt: this.timestamp.fromMillis(nowMillis),
        });
        return null;
      },
    );

    if (rejectionCode) {
      throw new PhoneAuthError(
        rejectionCode,
        rejectionCode === "expired_code"
          ? 410
          : rejectionCode === "too_many_attempts"
            ? 429
            : 401,
      );
    }
  }
}

class PhoneAuthService {
  constructor({
    store,
    smsClient,
    authClient,
    hmacSecret,
    now = () => Date.now(),
    randomInt = crypto.randomInt,
    verificationIdFactory = crypto.randomUUID,
    logger = console,
  }) {
    this.store = store;
    this.smsClient = smsClient;
    this.authClient = authClient;
    this.hmacSecret = hmacSecret;
    this.now = now;
    this.randomInt = randomInt;
    this.verificationIdFactory = verificationIdFactory;
    this.logger = logger;
  }

  async requestCode(rawPhone) {
    const phone = normalizeRussianPhone(rawPhone);
    if (!phone) {
      throw new PhoneAuthError("invalid_phone");
    }
    if (!this.hmacSecret) {
      throw new PhoneAuthError("server_unavailable", 503);
    }

    const isTestNumber = TEST_PHONE_NUMBERS.has(phone);
    const code = isTestNumber
      ? phone.slice(-4)
      : generateCode(this.randomInt);
    const verificationId = this.verificationIdFactory();
    const createdAtMillis = this.now();
    const phoneHash = hmac(this.hmacSecret, `phone:${phone}`);
    const challenge = {
      verificationId,
      phoneHash,
      codeHash: hmac(
        this.hmacSecret,
        `code:${verificationId}:${code}`,
      ),
      isTestNumber,
      createdAtMillis,
      expiresAtMillis: createdAtMillis + CODE_TTL_MS,
      resendAvailableAtMillis: createdAtMillis + RESEND_DELAY_MS,
    };

    await this.store.reserveChallenge(challenge);

    if (!isTestNumber) {
      try {
        const result = await this.smsClient.sendCode({
          number: phone.slice(1),
          code,
        });
        await this.store.markSent({
          verificationId,
          messageId: result.messageId,
        });
      } catch (_) {
        await this.store.markFailed({
          verificationId,
          phoneHash,
          requestAtMillis: createdAtMillis,
        });
        this.logger.error("Phone auth SMS delivery failed", {
          phone: maskPhone(phone),
        });
        throw new PhoneAuthError("sms_service_error", 503);
      }
    }

    this.logger.info("Phone auth challenge created", {
      phone: maskPhone(phone),
    });
    return {
      success: true,
      verificationId,
      expiresIn: CODE_TTL_MS / 1000,
      resendAfter: RESEND_DELAY_MS / 1000,
    };
  }

  async verifyCode({rawPhone, verificationId, code}) {
    const phone = normalizeRussianPhone(rawPhone);
    if (
      !phone ||
      typeof verificationId !== "string" ||
      !verificationId ||
      !/^\d{4}$/.test(String(code || ""))
    ) {
      throw new PhoneAuthError("invalid_code", 401);
    }
    if (!this.hmacSecret) {
      throw new PhoneAuthError("server_unavailable", 503);
    }

    const phoneHash = hmac(this.hmacSecret, `phone:${phone}`);
    const submittedCodeHash = hmac(
      this.hmacSecret,
      `code:${verificationId}:${code}`,
    );
    await this.store.consumeChallenge({
      verificationId,
      phoneHash,
      submittedCodeHash,
      nowMillis: this.now(),
    });

    const digits = phone.slice(1);
    let userRecord;
    try {
      userRecord = await this.authClient.getUserByPhoneNumber(phone);
    } catch (error) {
      if (!error || error.code !== "auth/user-not-found") {
        throw new PhoneAuthError("server_unavailable", 503);
      }
    }

    if (!userRecord) {
      try {
        userRecord = await this.authClient.createUser({
          uid: `phone_${digits}`,
          phoneNumber: phone,
        });
      } catch (error) {
        if (
          error &&
          (error.code === "auth/uid-already-exists" ||
            error.code === "auth/phone-number-already-exists")
        ) {
          userRecord = await this.authClient.getUserByPhoneNumber(phone);
        } else {
          throw new PhoneAuthError("server_unavailable", 503);
        }
      }
    }

    const token = await this.authClient.createCustomToken(userRecord.uid, {
      phoneAuth: true,
    });
    this.logger.info("Phone auth challenge verified", {
      phone: maskPhone(phone),
    });
    return {success: true, token};
  }
}

function setCors(response) {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Headers", "Content-Type");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
}

function sendError(response, error) {
  const safeError =
    error instanceof PhoneAuthError
      ? error
      : new PhoneAuthError("server_unavailable", 503);
  response.status(safeError.status).json({
    success: false,
    error: safeError.code,
  });
}

function createPhoneAuthHandlers({admin, logger = console}) {
  function createService() {
    const firestore = admin.firestore();
    return new PhoneAuthService({
      store: new FirestorePhoneAuthStore({
        firestore,
        timestamp: admin.firestore.Timestamp,
      }),
      smsClient: new SmsAeroClient({
        email: process.env.SMSAERO_EMAIL,
        apiKey: process.env.SMSAERO_API_KEY,
        sign: process.env.SMSAERO_SIGN,
      }),
      authClient: admin.auth(),
      hmacSecret: process.env.SMS_AUTH_HMAC_SECRET,
      logger,
    });
  }

  async function requestPhoneAuthCode(request, response) {
    setCors(response);
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      response.status(405).json({success: false, error: "method_not_allowed"});
      return;
    }

    try {
      const result = await createService().requestCode(
        request.body && request.body.phone,
      );
      response.json(result);
    } catch (error) {
      sendError(response, error);
    }
  }

  async function verifyPhoneAuthCode(request, response) {
    setCors(response);
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      response.status(405).json({success: false, error: "method_not_allowed"});
      return;
    }

    try {
      const result = await createService().verifyCode({
        rawPhone: request.body && request.body.phone,
        verificationId: request.body && request.body.verificationId,
        code: request.body && request.body.code,
      });
      response.json(result);
    } catch (error) {
      sendError(response, error);
    }
  }

  return {requestPhoneAuthCode, verifyPhoneAuthCode};
}

module.exports = {
  CODE_TTL_MS,
  DAY_MS,
  FirestorePhoneAuthStore,
  HOUR_MS,
  MAX_CODE_ATTEMPTS,
  MAX_SENDS_PER_DAY,
  MAX_SENDS_PER_HOUR,
  PhoneAuthError,
  PhoneAuthService,
  RESEND_DELAY_MS,
  TEST_PHONE_NUMBERS,
  createPhoneAuthHandlers,
  generateCode,
  hmac,
  maskPhone,
  normalizeRussianPhone,
};
