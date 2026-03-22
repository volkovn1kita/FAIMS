import 'dart:convert';
import 'dart:developer' as developer;
import 'package:frontend/core/constants.dart';
import 'package:http/http.dart' as http;
import '../models/auth_result.dart';
import '../dtos/login_dto.dart';
import '../dtos/register_organization_dto.dart';
import 'dart:async';

class AuthApiService {
  Future<AuthResult> login(LoginDto dto) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/users/login'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(dto.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('The server is not responding. Please check your connection or try again later.');
        },
      );

      if (response.statusCode == 200) {
        return AuthResult.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Incorrect email or password.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Server error. Status: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResult> registerOrganization(RegisterOrganizationDto dto) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/users/register-organization'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(dto.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('The server is not responding. Please check your connection or try again later.');
        },
      );

      if (response.statusCode == 200) {
        return AuthResult.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Validation error.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Server error. Status: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFcmToken(String authToken, String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/users/update-fcm-token'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': fcmToken}),
      );

      if (response.statusCode == 200) {
        developer.log('✅ FCM Token updated successfully on server', name: 'AuthApiService');
      } else {
        developer.log('⚠️ Failed to update FCM Token. Status: ${response.statusCode}, Body: ${response.body}', name: 'AuthApiService');
      }
    } catch (e) {
      developer.log('❌ Error updating FCM Token: $e', name: 'AuthApiService');
    }
  }
}