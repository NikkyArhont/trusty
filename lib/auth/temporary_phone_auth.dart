import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const int phoneAuthCodeLength = 4;
const Duration phoneAuthRequestTimeout = Duration(seconds: 30);

const _requestCodeUrl =
    'https://us-central1-trusty-kzh1sb.cloudfunctions.net/'
    'requestPhoneAuthCode';
const _verifyCodeUrl =
    'https://us-central1-trusty-kzh1sb.cloudfunctions.net/'
    'verifyPhoneAuthCode';
const _createTelegramAuthUrl =
    'https://us-central1-trusty-kzh1sb.cloudfunctions.net/'
    'createTelegramPhoneAuth';
const _checkTelegramAuthUrl =
    'https://us-central1-trusty-kzh1sb.cloudfunctions.net/'
    'checkTelegramPhoneAuth';

class PhoneAuthChallenge {
  const PhoneAuthChallenge({
    required this.verificationId,
    required this.expiresIn,
    required this.resendAfter,
  });

  final String verificationId;
  final int expiresIn;
  final int resendAfter;
}

class TelegramAuthChallenge {
  const TelegramAuthChallenge({
    required this.challengeId,
    required this.botUrl,
    required this.expiresIn,
  });

  final String challengeId;
  final String botUrl;
  final int expiresIn;
}

class TelegramAuthStatus {
  const TelegramAuthStatus({required this.status, this.token});

  final String status;
  final String? token;
  bool get confirmed => status == 'confirmed' && token?.isNotEmpty == true;
  bool get expired => status == 'expired' || status == 'consumed';
}

Future<TelegramAuthChallenge> createTelegramPhoneAuth({
  required String phone,
  http.Client? client,
}) async {
  final data = await _postJson(
    url: _createTelegramAuthUrl,
    body: {'phone': phone},
    client: client,
  );
  final challengeId = data['challengeId'] as String?;
  final botUrl = data['botUrl'] as String?;
  if (challengeId == null ||
      challengeId.isEmpty ||
      botUrl == null ||
      botUrl.isEmpty) {
    throw const PhoneAuthApiException(
      'invalid_response',
      'Сервер авторизации временно недоступен.',
    );
  }
  return TelegramAuthChallenge(
    challengeId: challengeId,
    botUrl: botUrl,
    expiresIn: (data['expiresIn'] as num?)?.toInt() ?? 300,
  );
}

Future<TelegramAuthStatus> checkTelegramPhoneAuth({
  required String challengeId,
  http.Client? client,
}) async {
  final data = await _postJson(
    url: _checkTelegramAuthUrl,
    body: {'challengeId': challengeId},
    client: client,
  );
  return TelegramAuthStatus(
    status: data['status'] as String? ?? 'pending',
    token: data['token'] as String?,
  );
}

class PhoneAuthApiException implements Exception {
  const PhoneAuthApiException(this.code, this.userMessage);

  final String code;
  final String userMessage;

  @override
  String toString() => userMessage;
}

Future<PhoneAuthChallenge> requestPhoneAuthCode({
  required String phone,
  http.Client? client,
}) async {
  final data = await _postJson(
    url: _requestCodeUrl,
    body: {'phone': phone},
    client: client,
  );
  final verificationId = data['verificationId'] as String?;
  if (verificationId == null || verificationId.isEmpty) {
    throw const PhoneAuthApiException(
      'invalid_response',
      'Сервер авторизации временно недоступен.',
    );
  }

  return PhoneAuthChallenge(
    verificationId: verificationId,
    expiresIn: (data['expiresIn'] as num?)?.toInt() ?? 300,
    resendAfter: (data['resendAfter'] as num?)?.toInt() ?? 60,
  );
}

Future<String> verifyPhoneAuthCode({
  required String phone,
  required String verificationId,
  required String code,
  http.Client? client,
}) async {
  final data = await _postJson(
    url: _verifyCodeUrl,
    body: {'phone': phone, 'verificationId': verificationId, 'code': code},
    client: client,
  );
  final token = data['token'] as String?;
  if (token == null || token.isEmpty) {
    throw const PhoneAuthApiException(
      'invalid_response',
      'Сервер авторизации временно недоступен.',
    );
  }
  return token;
}

Future<Map<String, dynamic>> _postJson({
  required String url,
  required Map<String, dynamic> body,
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  final shouldCloseClient = client == null;
  try {
    final response = await httpClient
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(phoneAuthRequestTimeout);

    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const PhoneAuthApiException(
        'invalid_response',
        'Сервер авторизации временно недоступен.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = data['error'] as String? ?? 'server_unavailable';
      throw PhoneAuthApiException(code, phoneAuthErrorMessage(code));
    }
    return data;
  } on PhoneAuthApiException {
    rethrow;
  } on TimeoutException {
    throw const PhoneAuthApiException(
      'network_error',
      'Сервер не ответил. Проверьте интернет и попробуйте ещё раз.',
    );
  } on SocketException {
    throw const PhoneAuthApiException(
      'network_error',
      'Нет подключения к интернету.',
    );
  } on http.ClientException {
    throw const PhoneAuthApiException(
      'network_error',
      'Нет подключения к интернету.',
    );
  } finally {
    if (shouldCloseClient) {
      httpClient.close();
    }
  }
}

String phoneAuthErrorMessage(String code) {
  switch (code) {
    case 'invalid_phone':
      return 'Проверьте номер телефона.';
    case 'invalid_code':
      return 'Неверный код подтверждения.';
    case 'expired_code':
      return 'Срок действия кода истёк. Запросите новый код.';
    case 'too_many_attempts':
      return 'Слишком много попыток. Запросите новый код.';
    case 'resend_too_soon':
      return 'Повторный код пока нельзя отправить. Немного подождите.';
    case 'rate_limit':
      return 'Слишком много запросов. Попробуйте позже.';
    case 'sms_service_error':
      return 'Не удалось отправить СМС. Попробуйте ещё раз позже.';
    case 'invalid_challenge':
      return 'Ссылка для входа устарела. Попробуйте ещё раз.';
    default:
      return 'Сервер авторизации временно недоступен.';
  }
}
