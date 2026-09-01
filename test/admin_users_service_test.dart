import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/backend/admin/admin_users_service.dart';

void main() {
  test('parses client, master stages and service statuses', () {
    final user = AdminUserInfo.fromJson({
      'id': 'user-1',
      'displayName': 'Анна',
      'phone': '+70000000000',
      'clientCity': '',
      'registrationComplete': true,
      'masterStarted': true,
      'masterComplete': false,
      'hasActiveDevice': true,
      'pushNotificationsEnabled': true,
      'master': {'title': 'Мастер Анна', 'city': 'Краснодар'},
      'services': [
        {'id': 'service-1', 'title': 'Стрижка', 'status': 'onModerate'},
      ],
    });

    expect(user.registrationComplete, isTrue);
    expect(user.hasClientCity, isFalse);
    expect(user.masterStarted, isTrue);
    expect(user.pushNotificationsEnabled, isTrue);
    expect(user.masterComplete, isFalse);
    expect(user.hasMasterCity, isTrue);
    expect(user.services.single.status, 'onModerate');
    expect(user.searchableText, contains('анна'));
  });
}
