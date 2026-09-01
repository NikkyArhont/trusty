import 'package:flutter_test/flutter_test.dart';
import 'package:trusty/flutter_flow/flutter_flow_util.dart';

void main() {
  test('formats service prices with spaces and a trailing ruble sign', () {
    expect(formatPrice(0), '0 ₽');
    expect(formatPrice(999), '999 ₽');
    expect(formatPrice(2000), '2 000 ₽');
    expect(formatPrice(33333), '33 333 ₽');
    expect(formatPrice(1234567), '1 234 567 ₽');
  });

  test('returns an empty value for a missing price', () {
    expect(formatPrice(null), '');
  });
}
