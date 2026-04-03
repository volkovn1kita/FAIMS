import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/dtos/expiration_status.dart';

void main() {
  group('ExpirationStatus', () {
    test('has all expected values', () {
      expect(ExpirationStatus.values.length, 4);
      expect(ExpirationStatus.values, contains(ExpirationStatus.good));
      expect(ExpirationStatus.values, contains(ExpirationStatus.warning));
      expect(ExpirationStatus.values, contains(ExpirationStatus.critical));
      expect(ExpirationStatus.values, contains(ExpirationStatus.expired));
    });

    test('good is not expired', () {
      const status = ExpirationStatus.good;
      expect(status == ExpirationStatus.expired, isFalse);
      expect(status == ExpirationStatus.critical, isFalse);
    });

    test('expired is distinct from warning', () {
      expect(ExpirationStatus.expired == ExpirationStatus.warning, isFalse);
    });
  });
}
