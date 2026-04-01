// lib/data/services/first_aid_kit_api_service.dart
import 'dart:convert';
import 'package:frontend/data/dtos/create_kit_dto.dart';
import 'package:frontend/data/dtos/department_dto.dart';
import 'package:frontend/data/dtos/medication_quantity_update_dto.dart';
import 'package:frontend/data/dtos/medication_refill_dto.dart';
import 'package:frontend/data/dtos/medication_write_off_dto.dart';
import 'package:frontend/data/dtos/room_dto.dart';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/dtos/first_aid_kit_list_dto.dart';
import 'package:frontend/data/dtos/update_kit_dto.dart';
import 'package:frontend/data/dtos/medication_dto.dart';
import 'package:frontend/data/dtos/medication_create_dto.dart'; // <<<--- НОВИЙ ІМПОРТ
import 'package:frontend/data/dtos/medication_update_dto.dart'; // <<<--- НОВИЙ ІМПОРТ

class FirstAidKitApiService {
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

  Future<List<UserDto>> getResponsibleUsers() async {
    final Uri uri = Uri.parse('$_baseUrl/users');
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
        return jsonList.map((json) => UserDto.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load responsible users: ${response.statusCode}.')
            : 'Failed to load responsible users: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DepartmentDto>> getDepartments() async {
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


  Future<List<FirstAidKitListDto>> getFirstAidKits({
    String? searchTerm,
    String? statusFilter,
    String? responsibleUserId,
    String? departmentId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final Map<String, String> queryParams = {};
    if (searchTerm != null && searchTerm.isNotEmpty) queryParams['searchTerm'] = searchTerm;
    if (statusFilter != null && statusFilter.isNotEmpty) queryParams['statusFilter'] = statusFilter;
    if (responsibleUserId != null && responsibleUserId.isNotEmpty && responsibleUserId != 'All') queryParams['responsibleUserId'] = responsibleUserId;
    if (departmentId != null && departmentId.isNotEmpty && departmentId != 'All') queryParams['departmentId'] = departmentId;
    queryParams['pageNumber'] = pageNumber.toString();
    queryParams['pageSize'] = pageSize.toString();

    final Uri uri = Uri.parse('$_baseUrl/kits').replace(queryParameters: queryParams);
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
        return jsonList.map((json) => FirstAidKitListDto.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load first aid kits: ${response.statusCode}.')
            : 'Failed to load first aid kits: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<FirstAidKitListDto> getMyKit() async {
    final Uri uri = Uri.parse('$_baseUrl/kits/my');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Received empty response for your kit.');
        }
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return FirstAidKitListDto.fromJson(jsonMap);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('You are not assigned to any first aid kit.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load your kit: ${response.statusCode}.')
            : 'Failed to load your kit: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<FirstAidKitListDto> getFirstAidKitById(String id) async {
    final Uri uri = Uri.parse('$_baseUrl/kits/$id');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) throw Exception('Received empty response for kit details.');
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return FirstAidKitListDto.fromJson(jsonMap);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Kit with ID $id not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load first aid kit details: ${response.statusCode}.')
            : 'Failed to load first aid kit details: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==== МЕТОДИ ДЛЯ МЕДИКАМЕНТІВ ====

  Future<List<MedicationDto>> getMedicationsForKit(String kitId) async {
    // Змінено URL відповідно до вашого контролера
    final Uri uri = Uri.parse('$_baseUrl/kits/$kitId/medications');
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
        return jsonList.map((json) => MedicationDto.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load medications for kit $kitId: ${response.statusCode}.')
            : 'Failed to load medications for kit $kitId: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<MedicationDto> getMedicationById(String medicationId) async {
    final Uri uri = Uri.parse('$_baseUrl/kits/medications/$medicationId');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) throw Exception('Received empty response for medication details.');
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return MedicationDto.fromJson(jsonMap);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Medication with ID $medicationId not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load medication details: ${response.statusCode}.')
            : 'Failed to load medication details: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addMedication(MedicationCreateDto medicationDto) async {
    final Uri uri = Uri.parse('$_baseUrl/kits/medications');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(medicationDto.toJson()),
      ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Залежно від того, що повертає бекенд: тут очікуємо ID нового медикаменту
        return response.body.isNotEmpty ? json.decode(response.body) : 'Success';
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to add medication: ${response.statusCode}.')
            : 'Failed to add medication: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> useMedication(String medicationId, MedicationQuantityUpdateDto dto) async {
    final Uri uri = Uri.parse('$_baseUrl/kits/medications/$medicationId/use');
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

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Medication with ID $medicationId not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to use medication: ${response.statusCode}.')
            : 'Failed to use medication: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> writeOffMedication(String medicationId, MedicationWriteOffDto dto) async {
    final Uri uri = Uri.parse('$_baseUrl/kits/medications/$medicationId/write-off');
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

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Medication with ID $medicationId not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to write off medication: ${response.statusCode}.')
            : 'Failed to write off medication: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMedication(MedicationUpdateDto medicationDto) async {
    final Uri uri = Uri.parse('$_baseUrl/kits/medications');
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(medicationDto.toJson()),
      ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Успішно оновлено, контенту немає
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to update medication: ${response.statusCode}.')
            : 'Failed to update medication: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedication(String medicationId, String kitId) async {
    // Змінено URL відповідно до вашого контролера
    final Uri uri = Uri.parse('$_baseUrl/kits/medications/$medicationId?kitId=$kitId');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Успішно видалено, контенту немає
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Medication with ID $medicationId not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to delete medication: ${response.statusCode}.')
            : 'Failed to delete medication: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ==== МЕТОДИ ДЛЯ AddEditKitScreen (без змін) ====

  Future<List<RoomDto>> getRoomsByDepartmentId(String departmentId) async {
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
        return jsonList.map((json) => RoomDto.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to load rooms: ${response.statusCode}.')
            : 'Failed to load rooms: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createKit(CreateKitDto kitDto) async {
    final Uri uri = Uri.parse('$_baseUrl/kits');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(kitDto.toJson()),
      ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to create kit: ${response.statusCode}.')
            : 'Failed to create kit: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateKit(String kitId, UpdateKitDto kitDto) async {
    final Uri uri = Uri.parse('$_baseUrl/kits');

    final UpdateKitDto updatedKitDto = kitDto.copyWith(id: kitId);

    try {
      final headers = await _getHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(updatedKitDto.toJson()),
      ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to update kit: ${response.statusCode}.')
            : 'Failed to update kit: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteKit(String kitId) async {
    final Uri uri = Uri.parse('$_baseUrl/kits/$kitId');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              throw Exception('Server is not responding. Please try again later.');
            },
          );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authorization error: ${response.statusCode}. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Kit with ID $kitId not found.');
      } else {
        final String errorMessage = response.body.isNotEmpty
            ? (json.decode(response.body)['message'] ?? 'Failed to delete kit: ${response.statusCode}.')
            : 'Failed to delete kit: Server returned ${response.statusCode} with no content.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refillMedication(String medicationId, MedicationRefillDto dto) async {
    final token = await _storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('$_baseUrl/kits/medications/$medicationId/refill'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(dto.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to refill medication: ${response.body}');
    }
  }

}