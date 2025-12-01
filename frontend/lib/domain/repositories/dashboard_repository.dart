import 'dart:convert';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/dtos/dashboard_overview.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class DashboardRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); 
  static const _tokenKey = 'jwt_token'; 

  Future<DashboardOverview> getDashboardOverview() async {
    final token = await _storage.read(key: _tokenKey);

    if (token == null) {
      throw Exception('Auth token not found. User not logged in.');
    }

    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/dashboard/overview'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DashboardOverview.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      throw Exception('Failed to load dashboard overview: ${response.statusCode}. Body: ${response.body}');
    }
  }
}