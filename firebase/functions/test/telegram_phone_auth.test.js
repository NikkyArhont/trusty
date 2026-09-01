const test = require("node:test");
const assert = require("node:assert/strict");
const {
  TELEGRAM_CHALLENGE_TTL_MS,
  TelegramPhoneAuthService,
} = require("../telegram_phone_auth");

function fixture(
  status = {status: "pending"},
  migrateGuest = async () => false,
) {
  const saved = [];
  const store = {
    createChallenge: async (challenge) => saved.push(challenge),
    consumeConfirmed: async () => status,
  };
  const authClient = {
    getUserByPhoneNumber: async () => ({uid: "phone_79181234567"}),
    createCustomToken: async (uid, claims) => `${uid}:${claims.telegramAuth}`,
  };
  return {
    saved,
    service: new TelegramPhoneAuthService({
      store,
      authClient,
      now: () => 1_700_000_000_000,
      challengeIdFactory: () => "a".repeat(43),
      logger: {info: () => {}},
      migrateGuest,
    }),
  };
}

test("creates a five-minute Telegram deep-link challenge", async () => {
  const {service, saved} = fixture();
  const result = await service.create("8 (918) 123-45-67");
  assert.equal(result.challengeId, "a".repeat(43));
  assert.equal(result.expiresIn, TELEGRAM_CHALLENGE_TTL_MS / 1000);
  assert.equal(
    result.botUrl,
    `https://t.me/Trusty_support_bot?start=login_${"a".repeat(43)}`,
  );
  assert.equal(saved[0].phone, "+79181234567");
  assert.equal(saved[0].expiresAtMillis - saved[0].createdAtMillis,
    TELEGRAM_CHALLENGE_TTL_MS);
});

test("returns pending without creating a Firebase token", async () => {
  const {service} = fixture({status: "pending"});
  assert.deepEqual(await service.status("a".repeat(43)), {status: "pending"});
});

test("returns a custom token only after Telegram confirmation", async () => {
  const {service} = fixture({status: "confirmed", phone: "+79181234567"});
  assert.deepEqual(await service.status("a".repeat(43)), {
    status: "confirmed",
    token: "phone_79181234567:true",
  });
});

test("moves the anonymous guest profile before issuing a Telegram token", async () => {
  const migrations = [];
  const {service} = fixture(
    {status: "confirmed", phone: "+79181234567"},
    async (migration) => migrations.push(migration),
  );

  await service.status("a".repeat(43), "anonymous-user");

  assert.deepEqual(migrations, [{
    guestUid: "anonymous-user",
    targetUid: "phone_79181234567",
  }]);
});
