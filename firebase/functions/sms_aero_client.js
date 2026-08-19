"use strict";

const axios = require("axios");

const SMS_AERO_SEND_URL = "https://gate.smsaero.ru/v2/sms/send";

class SmsAeroError extends Error {
  constructor(message = "SMS provider rejected the request") {
    super(message);
    this.name = "SmsAeroError";
    this.code = "sms_provider_error";
  }
}

class SmsAeroClient {
  constructor({
    email,
    apiKey,
    sign,
    httpClient = axios,
    timeoutMs = 8000,
  }) {
    this.email = email;
    this.apiKey = apiKey;
    this.sign = sign;
    this.httpClient = httpClient;
    this.timeoutMs = timeoutMs;
  }

  async sendCode({number, code}) {
    if (!this.email || !this.apiKey || !this.sign) {
      throw new SmsAeroError("SMS provider is not configured");
    }

    const payload = new URLSearchParams({
      number: String(number).replace(/^\+/, ""),
      text: `Код для входа в Сарафан: ${code}. Никому его не сообщайте.`,
      sign: this.sign,
    });

    let response;
    try {
      response = await this.httpClient.post(SMS_AERO_SEND_URL, payload, {
        auth: {
          username: this.email,
          password: this.apiKey,
        },
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        timeout: this.timeoutMs,
        validateStatus: () => true,
      });
    } catch (_) {
      throw new SmsAeroError("SMS provider is unavailable");
    }

    const responseData = response && response.data;
    if (
      !response ||
      response.status < 200 ||
      response.status >= 300 ||
      !responseData ||
      responseData.success !== true
    ) {
      throw new SmsAeroError();
    }

    const data = responseData.data || {};
    return {
      provider: "smsaero",
      messageId: data.id == null ? null : String(data.id),
    };
  }
}

module.exports = {
  SMS_AERO_SEND_URL,
  SmsAeroClient,
  SmsAeroError,
};
