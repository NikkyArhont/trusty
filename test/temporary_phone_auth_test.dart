import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/auth/temporary_phone_auth.dart';

void main() {
  test('phone auth code contains four digits', () {
    expect(phoneAuthCodeLength, 4);
  });

  test('phone auth allows enough time for a real SMS provider response', () {
    expect(phoneAuthRequestTimeout, const Duration(seconds: 30));
  });

  test('phone auth errors are mapped to safe user messages', () {
    expect(
      phoneAuthErrorMessage('invalid_code'),
      'Неверный код подтверждения.',
    );
    expect(
      phoneAuthErrorMessage('unknown_internal_error'),
      'Сервер авторизации временно недоступен.',
    );
  });
}
