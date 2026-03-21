import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/dtos/report_item_dto.dart';

class ReportsApiService {
  final String _baseUrl = Constants.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<ReportItemDto>> getPurchasingReport(DateTime startDate, DateTime endDate) async {
    final uri = Uri.parse('$_baseUrl/reports/purchasing?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}');
    return _fetchReport(uri);
  }

  Future<List<ReportItemDto>> getDisposalReport(DateTime startDate, DateTime endDate) async {
    final uri = Uri.parse('$_baseUrl/reports/disposal?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}');
    return _fetchReport(uri);
  }

  Future<List<ReportItemDto>> _fetchReport(Uri uri) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception('Authorization token not found.');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ReportItemDto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load report: ${response.statusCode}');
    }
  }
}