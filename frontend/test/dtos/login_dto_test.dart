import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/dtos/login_dto.dart';

void main() {
  group('LoginDto', () {
    test('toJson produces correct map', () {
      final dto = LoginDto(email: 'test@example.com', password: 'secret123');
      final json = dto.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'secret123');
      expect(json.length, 2);
    });

    test('toJson with empty strings', () {
      final dto = LoginDto(email: '', password: '');
      final json = dto.toJson();

      expect(json['email'], '');
      expect(json['password'], '');
    });
  });
}
