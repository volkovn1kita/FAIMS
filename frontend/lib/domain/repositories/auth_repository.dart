
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/data/dtos/login_dto.dart';
import 'package:frontend/data/models/auth_result.dart';
import 'package:frontend/data/services/auth_api_service.dart';
import 'package:frontend/utils/token_storage_service.dart';
import 'package:frontend/data/dtos/register_organization_dto.dart';

class AuthRepository {
  final AuthApiService _apiService = AuthApiService();
  final TokenStorageService _tokenStorageService = TokenStorageService(); 

  Future<AuthResult> login(LoginDto dto) async {
    final authResult = await _apiService.login(dto);
    await _tokenStorageService.saveToken(authResult.token);

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("📲 Phone FCM Token: $fcmToken");
        // Відправляємо на сервер, використовуючи токен авторизації, який ми щойно отримали
        await _apiService.updateFcmToken(authResult.token, fcmToken);
      }
    } catch (e) {
      print("⚠️ FCM Token Error during login: $e");
    }

    return authResult;
  }

  Future<String?> getToken() async {
    return await _tokenStorageService.getToken(); 
  }

  Future<void> logout() async {
    await _tokenStorageService.deleteToken();
  }

  Future<AuthResult> registerOrganization(RegisterOrganizationDto dto) async {
    final authResult = await _apiService.registerOrganization(dto);
    
    await _tokenStorageService.saveToken(authResult.token);

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("📲 Phone FCM Token (Registration): $fcmToken");
        await _apiService.updateFcmToken(authResult.token, fcmToken);
      }
    } catch (e) {
      print("⚠️ FCM Token Error during registration: $e");
    }

    return authResult;
  }

}