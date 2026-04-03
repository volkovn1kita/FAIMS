import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/constants.dart';

void main() {
  group('Constants', () {
    test('baseUrl is not empty', () {
      expect(Constants.baseUrl, isNotEmpty);
    });

    test('baseUrl starts with http', () {
      expect(Constants.baseUrl.startsWith('http'), isTrue);
    });

    test('baseUrl ends with /api', () {
      expect(Constants.baseUrl.endsWith('/api'), isTrue);
    });

    test('baseUrl does not contain whitespace', () {
      expect(Constants.baseUrl.contains(' '), isFalse);
    });
  });
}
