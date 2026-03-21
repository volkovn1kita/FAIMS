import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/dtos/analytics_dtos.dart';

class AnalyticsApiService {
  final String _baseUrl = Constants.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<DashboardStatsDto> getGlobalStats() async {
    final Uri uri = Uri.parse('$_baseUrl/analytics/global');

    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('Authorization token not found. Please log in.');
    }

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DashboardStatsDto.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401 || response.statusCode == 403) {
       throw Exception('Access denied. Only administrators can view global analytics.');
    } else {
      throw Exception('Failed to load analytics: ${response.statusCode}');
    }
  }
}