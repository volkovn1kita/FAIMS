
import 'package:frontend/data/dtos/login_dto.dart';
import 'package:frontend/data/models/auth_result.dart';
import 'package:frontend/data/services/auth_api_service.dart';
import 'package:frontend/utils/token_storage_service.dart';

class AuthRepository {
  final AuthApiService _apiService = AuthApiService();
  final TokenStorageService _tokenStorageService = TokenStorageService(); 

  Future<AuthResult> login(LoginDto dto) async {
    final authResult = await _apiService.login(dto);
    await _tokenStorageService.saveToken(authResult.token);
    return authResult;
  }

  Future<String?> getToken() async {
    return await _tokenStorageService.getToken(); 
  }

  Future<void> logout() async {
    await _tokenStorageService.deleteToken();
  }
}