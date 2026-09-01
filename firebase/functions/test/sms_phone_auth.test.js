"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");

const {SmsAeroClient, SmsAeroError} = require("../sms_aero_client");
const {
  CODE_TTL_MS,
  DAY_MS,
  HOUR_MS,
  MAX_CODE_ATTEMPTS,
  PhoneAuthError,
  PhoneAuthService,
  RESEND_DELAY_MS,
  normalizeRussianPhone,
} = require("../sms_phone_auth");

class InMemoryStore {
  constructor() {
    this.challenges = new Map();
    this.rates = new Map();
  }

  async reserveChallenge(challenge) {
    const rate = this.rates.get(challenge.phoneHash) || {
      sendTimestamps: [],
      lastRequestAtMillis: 0,
      activeVerificationId: null,
    };
    const recent = rate.sendTimestamps.filter(
      (value) => value > challenge.createdAtMillis - DAY_MS,
    );
    if (
      !challenge.isTestNumber &&
      rate.lastRequestAtMillis &&
      challenge.createdAtMillis - rate.lastRequestAtMillis <
        RESEND_DELAY_MS
    ) {
      throw new PhoneAuthError("resend_too_soon", 429);
    }
    if (
      !challenge.isTestNumber &&
      (recent.filter(
        (value) => value > challenge.createdAtMillis - HOUR_MS,
      ).length >= 5 ||
        recent.length >= 10)
    ) {
      throw new PhoneAuthError("rate_limit", 429);
    }

    if (rate.activeVerificationId) {
      const previous = this.challenges.get(rate.activeVerificationId);
      if (previous) {
        previous.status = "superseded";
        previous.used = true;
      }
    }

    this.challenges.set(challenge.verificationId, {
      ...challenge,
      attempts: 0,
      used: false,
      status: challenge.isTestNumber ? "active" : "sending",
    });
    this.rates.set(challenge.phoneHash, {
      sendTimestamps: [...recent, challenge.createdAtMillis],
      lastRequestAtMillis: challenge.createdAtMillis,
      activeVerificationId: challenge.verificationId,
    });
  }

  async markSent({verificationId, messageId}) {
    const challenge = this.challenges.get(verificationId);
    challenge.status = "active";
    challenge.providerMessageId = messageId;
  }

  async markFailed({verificationId, phoneHash, requestAtMillis}) {
    const challenge = this.challenges.get(verificationId);
    challenge.status = "failed";
    challenge.used = true;
    const rate = this.rates.get(phoneHash);
    rate.sendTimestamps = rate.sendTimestamps.filter(
      (value) => value !== requestAtMillis,
    );
    rate.lastRequestAtMillis =
      rate.sendTimestamps.length === 0
        ? 0
        : Math.max(...rate.sendTimestamps);
    if (rate.activeVerificationId === verificationId) {
      rate.activeVerificationId = null;
    }
  }

  async consumeChallenge({
    verificationId,
    phoneHash,
    submittedCodeHash,
    nowMillis,
  }) {
    const challenge = this.challenges.get(verificationId);
    if (
      !challenge ||
      challenge.phoneHash !== phoneHash ||
      (challenge.status !== "active" && challenge.status !== "blocked")
    ) {
      throw new PhoneAuthError("invalid_code", 401);
    }
    if (challenge.status === "blocked") {
      throw new PhoneAuthError("too_many_attempts", 429);
    }
    if (challenge.used) {
      throw new PhoneAuthError("invalid_code", 401);
    }
    if (challenge.expiresAtMillis <= nowMillis) {
      challenge.status = "expired";
      challenge.used = true;
      throw new PhoneAuthError("expired_code", 410);
    }
    if (challenge.attempts >= MAX_CODE_ATTEMPTS) {
      throw new PhoneAuthError("too_many_attempts", 429);
    }
    if (challenge.codeHash !== submittedCodeHash) {
      challenge.attempts += 1;
      if (challenge.attempts >= MAX_CODE_ATTEMPTS) {
        challenge.status = "blocked";
        challenge.used = true;
        throw new PhoneAuthError("too_many_attempts", 429);
      }
      throw new PhoneAuthError("invalid_code", 401);
    }
    challenge.status = "used";
    challenge.used = true;
  }
}

function createFixture({
  phone = "+79181234567",
  generatedCode = 1234,
  smsFailure = false,
  migrateGuest = async () => false,
} = {}) {
  let nowMillis = 1_800_000_000_000;
  let nextId = 1;
  const sentMessages = [];
  const logs = [];
  const users = new Map();
  const store = new InMemoryStore();
  const smsClient = {
    async sendCode(message) {
      sentMessages.push(message);
      if (smsFailure) {
        throw new SmsAeroError();
      }
      return {provider: "smsaero", messageId: "message-1"};
    },
  };
  const authClient = {
    async getUserByPhoneNumber(value) {
      const user = users.get(value);
      if (!user) {
        const error = new Error("not found");
        error.code = "auth/user-not-found";
        throw error;
      }
      return user;
    },
    async createUser({uid, phoneNumber}) {
      const user = {uid, phoneNumber};
      users.set(phoneNumber, user);
      return user;
    },
    async createCustomToken(uid) {
      return `token:${uid}`;
    },
  };
  const logger = {
    info(message, metadata) {
      logs.push(JSON.stringify({message, metadata}));
    },
    error(message, metadata) {
      logs.push(JSON.stringify({message, metadata}));
    },
  };
  const service = new PhoneAuthService({
    store,
    smsClient,
    authClient,
    hmacSecret: "unit-test-hmac-secret",
    now: () => nowMillis,
    randomInt: () => generatedCode,
    verificationIdFactory: () => `verification-${nextId++}`,
    logger,
    migrateGuest,
  });

  return {
    authClient,
    logs,
    phone,
    sentMessages,
    service,
    store,
    advance(milliseconds) {
      nowMillis += milliseconds;
    },
  };
}

async function expectError(promise, code) {
  await assert.rejects(promise, (error) => {
    assert.equal(error.code, code);
    return true;
  });
}

test("test number +79183633636 accepts 3636 without sending SMS", async () => {
  const fixture = createFixture({phone: "+79183633636"});
  const challenge = await fixture.service.requestCode(fixture.phone);
  const result = await fixture.service.verifyCode({
    rawPhone: fixture.phone,
    verificationId: challenge.verificationId,
    code: "3636",
  });
  assert.match(result.token, /^token:/);
  assert.equal(fixture.sentMessages.length, 0);
});

test("moves the anonymous guest profile before issuing an SMS auth token", async () => {
  const migrations = [];
  const fixture = createFixture({
    phone: "+79183633636",
    migrateGuest: async (migration) => migrations.push(migration),
  });
  const challenge = await fixture.service.requestCode(fixture.phone);

  await fixture.service.verifyCode({
    rawPhone: fixture.phone,
    verificationId: challenge.verificationId,
    code: "3636",
    guestUid: "anonymous-user",
  });

  assert.deepEqual(migrations, [{
    guestUid: "anonymous-user",
    targetUid: "phone_79183633636",
  }]);
});

test("test number +79183633636 is not blocked by production send limits", async () => {
  const fixture = createFixture({phone: "+79183633636"});

  for (let request = 0; request < 12; request += 1) {
    await fixture.service.requestCode(fixture.phone);
  }

  const activeChallenge = [...fixture.store.challenges.values()].at(-1);
  assert.equal(activeChallenge.status, "active");
  assert.equal(fixture.sentMessages.length, 0);
});

test("test number +79180000000 accepts 0000 with leading zeroes", async () => {
  const fixture = createFixture({phone: "+79180000000"});
  const challenge = await fixture.service.requestCode(fixture.phone);
  const result = await fixture.service.verifyCode({
    rawPhone: fixture.phone,
    verificationId: challenge.verificationId,
    code: "0000",
  });
  assert.match(result.token, /^token:/);
});

test("test number +79181111111 accepts 1111", async () => {
  const fixture = createFixture({phone: "+79181111111"});
  const challenge = await fixture.service.requestCode(fixture.phone);
  const result = await fixture.service.verifyCode({
    rawPhone: fixture.phone,
    verificationId: challenge.verificationId,
    code: "1111",
  });
  assert.match(result.token, /^token:/);
});

test("test number +79280352841 accepts 2841", async () => {
  const fixture = createFixture({phone: "+79280352841"});
  const challenge = await fixture.service.requestCode(fixture.phone);
  const result = await fixture.service.verifyCode({
    rawPhone: fixture.phone,
    verificationId: challenge.verificationId,
    code: "2841",
  });
  assert.match(result.token, /^token:/);
  assert.equal(fixture.sentMessages.length, 0);
});

test("test number +79181209565 accepts 9565", async () => {
  const fixture = createFixture({phone: "+79181209565"});
  const challenge = await fixture.service.requestCode(fixture.phone);
  const result = await fixture.service.verifyCode({
    rawPhone: fixture.phone,
    verificationId: challenge.verificationId,
    code: "9565",
  });
  assert.match(result.token, /^token:/);
  assert.equal(fixture.sentMessages.length, 0);
});

test("ordinary number does not automatically accept its last four digits", async () => {
  const fixture = createFixture({generatedCode: 1234});
  const challenge = await fixture.service.requestCode(fixture.phone);
  await expectError(
    fixture.service.verifyCode({
      rawPhone: fixture.phone,
      verificationId: challenge.verificationId,
      code: "4567",
    }),
    "invalid_code",
  );
});

test("ordinary number sends a code through SMS Aero", async () => {
  const fixture = createFixture({generatedCode: 7});
  await fixture.service.requestCode(fixture.phone);
  assert.deepEqual(fixture.sentMessages, [
    {number: "79181234567", code: "0007"},
  ]);
});

test("correct SMS code is accepted", async () => {
  const fixture = createFixture({generatedCode: 2468});
  const challenge = await fixture.service.requestCode(fixture.phone);
  const result = await fixture.service.verifyCode({
    rawPhone: fixture.phone,
    verificationId: challenge.verificationId,
    code: "2468",
  });
  assert.equal(result.token, "token:phone_79181234567");
});

test("incorrect SMS code is rejected", async () => {
  const fixture = createFixture({generatedCode: 2468});
  const challenge = await fixture.service.requestCode(fixture.phone);
  await expectError(
    fixture.service.verifyCode({
      rawPhone: fixture.phone,
      verificationId: challenge.verificationId,
      code: "1357",
    }),
    "invalid_code",
  );
});

test("expired code is rejected", async () => {
  const fixture = createFixture();
  const challenge = await fixture.service.requestCode(fixture.phone);
  fixture.advance(CODE_TTL_MS + 1);
  await expectError(
    fixture.service.verifyCode({
      rawPhone: fixture.phone,
      verificationId: challenge.verificationId,
      code: "1234",
    }),
    "expired_code",
  );
});

test("code cannot be used twice", async () => {
  const fixture = createFixture();
  const challenge = await fixture.service.requestCode(fixture.phone);
  const input = {
    rawPhone: fixture.phone,
    verificationId: challenge.verificationId,
    code: "1234",
  };
  await fixture.service.verifyCode(input);
  await expectError(fixture.service.verifyCode(input), "invalid_code");
});

test("challenge is blocked after five incorrect attempts", async () => {
  const fixture = createFixture();
  const challenge = await fixture.service.requestCode(fixture.phone);
  for (let attempt = 1; attempt < 5; attempt += 1) {
    await expectError(
      fixture.service.verifyCode({
        rawPhone: fixture.phone,
        verificationId: challenge.verificationId,
        code: "9999",
      }),
      "invalid_code",
    );
  }
  await expectError(
    fixture.service.verifyCode({
      rawPhone: fixture.phone,
      verificationId: challenge.verificationId,
      code: "9999",
    }),
    "too_many_attempts",
  );
  await expectError(
    fixture.service.verifyCode({
      rawPhone: fixture.phone,
      verificationId: challenge.verificationId,
      code: "1234",
    }),
    "too_many_attempts",
  );
});

test("new challenge invalidates the previous challenge", async () => {
  const fixture = createFixture();
  const first = await fixture.service.requestCode(fixture.phone);
  fixture.advance(RESEND_DELAY_MS);
  const second = await fixture.service.requestCode(fixture.phone);
  assert.notEqual(first.verificationId, second.verificationId);
  await expectError(
    fixture.service.verifyCode({
      rawPhone: fixture.phone,
      verificationId: first.verificationId,
      code: "1234",
    }),
    "invalid_code",
  );
});

test("8 and +7 formats normalize to the same Russian number", () => {
  assert.equal(normalizeRussianPhone("8 (918) 123-45-67"), "+79181234567");
  assert.equal(normalizeRussianPhone("+7 918 123 45 67"), "+79181234567");
});

test("SMS Aero failure leaves no active successful challenge", async () => {
  const fixture = createFixture({smsFailure: true});
  await expectError(
    fixture.service.requestCode(fixture.phone),
    "sms_service_error",
  );
  const challenges = [...fixture.store.challenges.values()];
  assert.equal(challenges.length, 1);
  assert.equal(challenges[0].status, "failed");
  assert.equal(challenges[0].used, true);
});

test("API key and one-time code are absent from logs", async () => {
  const fixture = createFixture({generatedCode: 5821});
  await fixture.service.requestCode(fixture.phone);
  const output = fixture.logs.join("\n");
  assert.doesNotMatch(output, /5821/);
  assert.doesNotMatch(output, /secret-api-key/);
  assert.doesNotMatch(output, /79181234567/);
  assert.match(output, /\+7918\*\*\*4567/);
});

test("Firestore rules deny client access to auth collections", () => {
  const rules = fs.readFileSync(
    path.join(__dirname, "..", "..", "firestore.rules"),
    "utf8",
  );
  assert.match(
    rules,
    /match \/smsAuthChallenges\/\{document\}[\s\S]*?allow read, write: if false;/,
  );
  assert.match(
    rules,
    /match \/smsAuthRateLimits\/\{document\}[\s\S]*?allow read, write: if false;/,
  );
});

test("SmsAeroClient uses Basic Auth and validates provider success", async () => {
  let request;
  const client = new SmsAeroClient({
    email: "account@example.com",
    apiKey: "secret-api-key",
    sign: "Sarafan",
    httpClient: {
      async post(url, body, options) {
        request = {url, body: body.toString(), options};
        return {status: 200, data: {success: true, data: {id: 42}}};
      },
    },
  });
  const result = await client.sendCode({
    number: "79181234567",
    code: "0042",
  });
  assert.equal(request.options.auth.username, "account@example.com");
  assert.equal(request.options.auth.password, "secret-api-key");
  assert.doesNotMatch(request.url, /secret-api-key/);
  assert.match(request.body, /number=79181234567/);
  assert.deepEqual(result, {provider: "smsaero", messageId: "42"});
});

test("SmsAeroClient throws a typed error for API rejection", async () => {
  const client = new SmsAeroClient({
    email: "account@example.com",
    apiKey: "secret-api-key",
    sign: "Sarafan",
    httpClient: {
      async post() {
        return {status: 200, data: {success: false}};
      },
    },
  });
  await assert.rejects(
    client.sendCode({number: "79181234567", code: "1234"}),
    SmsAeroError,
  );
});
