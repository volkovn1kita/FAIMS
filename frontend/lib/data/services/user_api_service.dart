// lib/data/api_services/user_api_service.dart - ОНОВЛЕНА ВЕРСІЯ (з доданими методами керування користувачами)
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:frontend/data/dtos/create_user_request_dto.dart';
import 'package:frontend/data/dtos/user_role_dto.dart';
import 'package:frontend/data/dtos/update_user_request_dto.dart'; // <--- НОВИЙ DTO
import 'package:http/http.dart' as http;
import 'package:frontend/utils/token_storage_service.dart';

class UserApiService {
  final String _baseUrl = Constants.baseUrl;
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _tokenStorageService.getToken();
    final Map<String, String> headers = {};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- GET ALL USERS ---
  Future<List<UserDto>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        return List<UserDto>.from(l.map((model) => UserDto.fromJson(model)));
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized or Forbidden. Please log in with an Administrator account.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to load users. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }

  // --- GET USER BY ID (Admin) --- <--- НОВИЙ МЕТОД
  Future<UserDto> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return UserDto.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized or Forbidden. Please log in with an Administrator account.');
      } else if (response.statusCode == 404) {
        throw Exception('User not found.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to load user. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }

  // --- CREATE USER (Admin) ---
  Future<String> adminCreateUser(CreateUserRequestDto dto) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/admin-create'),
        headers: await _getHeaders(),
        body: jsonEncode(dto.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return responseBody['userId'] as String;
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Validation error.');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized or Forbidden. Please log in with an Administrator account.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create user. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }

  // --- UPDATE USER (Admin) --- <--- НОВИЙ МЕТОД
  Future<void> adminUpdateUser(String userId, UpdateUserRequestDto dto) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: await _getHeaders(),
        body: jsonEncode(dto.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return; 
        } else {
          return;
        }
      } else if (response.statusCode == 204) { 
        return; // Успішне оновлення, повертаємо void
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Validation error.');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized or Forbidden. Please log in with an Administrator account.');
      } else if (response.statusCode == 404) {
        throw Exception('User not found.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to update user. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }

  // --- DELETE USER (Admin) --- <--- НОВИЙ МЕТОД
  Future<void> adminDeleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 204) { // 204 No Content - зазвичай повертається при успішному видаленні
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized or Forbidden. Please log in with an Administrator account.');
      } else if (response.statusCode == 404) {
        throw Exception('User not found.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to delete user. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }


  // --- GET AVAILABLE ROLES ---
  Future<List<UserRoleDto>> getAvailableRoles() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      UserRoleDto(name: 'Administrator'),
      UserRoleDto(name: 'User'),
    ];
  }

  // --- GET MY PROFILE ---
  Future<UserDto> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return UserDto.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to load profile. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }

  // --- UPDATE MY PROFILE ---
  Future<UserDto?> updateMyProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? oldPassword,
    String? newPassword,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };
      if (oldPassword != null && newPassword != null && newPassword.isNotEmpty) {
        body['oldPassword'] = oldPassword;
        body['newPassword'] = newPassword;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/users/me'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          return UserDto.fromJson(json.decode(response.body));
        }
        return null;
      }

      else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Validation error.');
      }

      else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in.');
      }
      else {
        String message = 'Failed to update profile. Status: ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final errorBody = jsonDecode(response.body);
            message = errorBody['message'] ?? message;
          } catch (_) {}
        }
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }


  // --- ЗАВАНТАЖЕННЯ АВАТАРА ДЛЯ ПОТОЧНОГО КОРИСТУВАЧА ---
  Future<String?> uploadMyAvatar(File avatarFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/users/me/avatar');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(await _getHeaders(isMultipart: true));
      request.files.add(await http.MultipartFile.fromPath(
        'avatarFile',
        avatarFile.path,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['avatarUrl'] as String?;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized or Forbidden. Please log in.');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to upload avatar: Validation error.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to upload avatar. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }

  // --- ВИДАЛЕННЯ АВАТАРА ДЛЯ ПОТОЧНОГО КОРИСТУВАЧА ---
  Future<void> deleteMyAvatar() async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/me/avatar'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized or Forbidden. Please log in.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to delete avatar. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }

  // --- Завантаження аватара для конкретного користувача (Admin) ---
  Future<String?> uploadUserAvatar(String userId, File avatarFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/users/$userId/avatar');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(await _getHeaders(isMultipart: true));
      request.files.add(await http.MultipartFile.fromPath(
        'avatarFile',
        avatarFile.path,
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['avatarUrl'] as String?;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized or Forbidden. Please log in with an Administrator account.');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to upload user avatar: Validation error.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to upload user avatar. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }

  // --- Видалення аватара для конкретного користувача (Admin) ---
  Future<void> deleteUserAvatar(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/$userId/avatar'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized or Forbidden. Please log in with an Administrator account.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to delete user avatar. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }
}