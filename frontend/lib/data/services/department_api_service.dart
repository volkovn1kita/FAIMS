// lib/data/services/department_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/dtos/department_dto.dart';
import 'package:frontend/data/dtos/department_create_dto.dart';
import 'package:frontend/data/dtos/department_detail_dto.dart';
import 'package:frontend/data/dtos/room_list_dto.dart'; // Використовуємо RoomListDto для деталей департаменту
import 'package:frontend/data/dtos/room_create_dto.dart';
import 'package:frontend/data/dtos/room_update_dto.dart';
import 'package:frontend/data/dtos/room_list_all_dto.dart'; // Для getAllRooms, якщо потрібно

class DepartmentApiService {
  final String _baseUrl = Constants.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) {
      throw Exception('Authorization token not found. Please log in.');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============== DEPARTMENT OPERATIONS ================

  Future<List<DepartmentDto>> getAllDepartments() async {
    final Uri uri = Uri.parse('$_baseUrl/departments');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => DepartmentDto.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load departments: ${response.statusCode}.')
            : 'Failed to load departments: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DepartmentDetailDto> getDepartmentById(String id) async {
    final Uri uri = Uri.parse('$_baseUrl/departments/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) throw Exception('Received empty response for department details.');
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return DepartmentDetailDto.fromJson(jsonMap);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Department with ID $id not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load department details: ${response.statusCode}.')
            : 'Failed to load department details: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addDepartment(DepartmentCreateDto dto) async {
    final Uri uri = Uri.parse('$_baseUrl/departments');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(dto.toJson()),
      ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 201) { // 201 Created
        // Backend повертає ID департаменту в тілі відповіді
        return response.body.isNotEmpty ? json.decode(response.body) : 'Success';
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to add department: ${response.statusCode}.')
            : 'Failed to add department: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDepartment(String id, String name) async {
    final Uri uri = Uri.parse('$_baseUrl/departments/$id');
    try {
      final headers = await _getHeaders();
      // Використовуємо DepartmentCreateDto для тіла запиту, як на бекенді
      final updateDto = DepartmentCreateDto(name: name);
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(updateDto.toJson()),
      ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 204) { // 204 No Content
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Department with ID $id not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to update department: ${response.statusCode}.')
            : 'Failed to update department: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDepartment(String id) async {
    final Uri uri = Uri.parse('$_baseUrl/departments/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 204) { // 204 No Content
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Department with ID $id not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to delete department: ${response.statusCode}.')
            : 'Failed to delete department: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============== ROOM OPERATIONS ================

  Future<List<RoomListAllDto>> getAllRooms() async {
    final Uri uri = Uri.parse('$_baseUrl/departments/rooms/all');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RoomListAllDto.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load all rooms: ${response.statusCode}.')
            : 'Failed to load all rooms: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomListDto>> getRoomsByDepartmentId(String departmentId) async {
    final Uri uri = Uri.parse('$_baseUrl/departments/$departmentId/rooms');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RoomListDto.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load rooms for department $departmentId: ${response.statusCode}.')
            : 'Failed to load rooms for department $departmentId: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addRoom(RoomCreateDto dto) async {
    final Uri uri = Uri.parse('$_baseUrl/departments/rooms');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(dto.toJson()),
      ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 201) { // 201 Created
        return response.body.isNotEmpty ? json.decode(response.body) : 'Success';
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to add room: ${response.statusCode}.')
            : 'Failed to add room: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRoom(String id, RoomUpdateDto dto) async {
    final Uri uri = Uri.parse('$_baseUrl/departments/rooms/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(dto.toJson()),
      ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 204) { // 204 No Content
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Room with ID $id not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to update room: ${response.statusCode}.')
            : 'Failed to update room: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRoom(String id) async {
    final Uri uri = Uri.parse('$_baseUrl/departments/rooms/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 204) { // 204 No Content
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Room with ID $id not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to delete room: ${response.statusCode}.')
            : 'Failed to delete room: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}