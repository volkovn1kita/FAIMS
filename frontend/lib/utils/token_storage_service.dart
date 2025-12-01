
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // Зберігає JWT токен
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Отримує JWT токен
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Видаляє JWT токен (для виходу з системи)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}