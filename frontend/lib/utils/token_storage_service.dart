import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  static const String _nameKey = 'user_name';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveName(String name) async {
    await _storage.write(key: _nameKey, value: name);
  }

  Future<String?> getName() async {
    return await _storage.read(key: _nameKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}