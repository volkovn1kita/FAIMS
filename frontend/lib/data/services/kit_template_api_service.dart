import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:faims/core/constants.dart';
import 'package:faims/data/dtos/kit_template_dto.dart';
import 'package:faims/utils/session_service.dart';

class KitTemplateApiService {
  final String _baseUrl = Constants.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) throw Exception('Authorization token not found.');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Отримати всі шаблони (системні + власні організації)
  Future<List<KitTemplateDto>> getAllTemplates() async {
    final uri = Uri.parse('$_baseUrl/kit-templates');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return [];
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => KitTemplateDto.fromJson(e as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 401) {
      SessionService.instance.forceLogout();
      throw Exception('Unauthorized');
    }
    throw Exception('Failed to load templates: ${response.statusCode}');
  }

  /// Створити власний шаблон
  Future<void> createTemplate({
    required String name,
    String? description,
    required List<KitTemplateItemDto> items,
  }) async {
    final uri = Uri.parse('$_baseUrl/kit-templates');
    final headers = await _getHeaders();
    final body = json.encode({
      'name': name,
      'description': description,
      'items': items.map((i) => i.toJson()).toList(),
    });
    final response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 20));
    if (response.statusCode != 201) {
      throw Exception(json.decode(response.body)?.toString() ?? 'Failed to create template');
    }
  }

  /// Оновити власний шаблон
  Future<void> updateTemplate({
    required String id,
    required String name,
    String? description,
    required List<KitTemplateItemDto> items,
  }) async {
    final uri = Uri.parse('$_baseUrl/kit-templates/$id');
    final headers = await _getHeaders();
    final body = json.encode({
      'name': name,
      'description': description,
      'items': items.map((i) => i.toJson()).toList(),
    });
    final response = await http.put(uri, headers: headers, body: body).timeout(const Duration(seconds: 20));
    if (response.statusCode != 204) {
      throw Exception('Failed to update template: ${response.statusCode}');
    }
  }

  /// Видалити власний шаблон
  Future<void> deleteTemplate(String id) async {
    final uri = Uri.parse('$_baseUrl/kit-templates/$id');
    final headers = await _getHeaders();
    final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 20));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete template: ${response.statusCode}');
    }
  }

  /// Застосувати шаблон до аптечки
  Future<void> applyTemplateToKit({
    required String kitId,
    required String templateId,
  }) async {
    final uri = Uri.parse('$_baseUrl/kit-templates/apply/$kitId/$templateId');
    final headers = await _getHeaders();
    final response = await http.post(uri, headers: headers).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Failed to apply template: ${response.statusCode}');
    }
  }
}
