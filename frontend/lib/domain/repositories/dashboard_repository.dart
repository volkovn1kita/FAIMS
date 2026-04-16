import 'dart:convert';
import 'package:faims/core/constants.dart';
import 'package:faims/data/dtos/dashboard_overview.dart';
import 'package:http/http.dart' as http;
import 'package:faims/utils/token_storage_service.dart';

class DashboardRepository {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<DashboardOverview> getDashboardOverview() async {
    final token = await _tokenStorageService.getToken();
    if (token == null) {
      throw Exception('Auth token not found. User not logged in.');
    }
    return _fetchDashboard(token);
  }

  Future<DashboardOverview> _fetchDashboard(String token) async {
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
      throw Exception('Failed to load dashboard: ${response.statusCode}');
    }
  }
}
