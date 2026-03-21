import 'package:flutter/foundation.dart';
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
    
    final nameToSave = authResult.name ?? authResult.email.split('@')[0];
    await _tokenStorageService.saveName(nameToSave);

    if (!kIsWeb) {
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _apiService.updateFcmToken(authResult.token, fcmToken);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return authResult;
  }

  Future<String?> getToken() async {
    return await _tokenStorageService.getToken();
  }

  Future<String?> getName() async {
    return await _tokenStorageService.getName();
  }

  Future<void> logout() async {
    await _tokenStorageService.deleteToken();
  }

  Future<AuthResult> registerOrganization(RegisterOrganizationDto dto) async {
    final authResult = await _apiService.registerOrganization(dto);

    await _tokenStorageService.saveToken(authResult.token);
    
    final nameToSave = authResult.name ?? authResult.email.split('@')[0];
    await _tokenStorageService.saveName(nameToSave);

    if (!kIsWeb) {
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _apiService.updateFcmToken(authResult.token, fcmToken);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    return authResult;
  }
}