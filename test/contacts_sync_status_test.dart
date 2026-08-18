import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/init/sync_contacts.dart';

void main() {
  test('contacts become stale after three calendar months', () {
    final now = DateTime(2026, 7, 31, 12);

    expect(
      isContactsSyncOlderThanThreeMonths(DateTime(2026, 4, 30, 12), now: now),
      isFalse,
    );
    expect(
      isContactsSyncOlderThanThreeMonths(DateTime(2026, 4, 29, 12), now: now),
      isTrue,
    );
  });

  test('recent contacts sync stays current', () {
    final now = DateTime(2026, 7, 31, 12);

    expect(
      isContactsSyncOlderThanThreeMonths(DateTime(2026, 7, 1), now: now),
      isFalse,
    );
  });
}
