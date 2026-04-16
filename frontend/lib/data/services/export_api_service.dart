import 'dart:async';
import 'dart:typed_data';
import 'package:faims/core/constants.dart';
import 'package:faims/utils/token_storage_service.dart';
import 'package:faims/utils/session_service.dart';
import 'package:http/http.dart' as http;

class ExportApiService {
  final String _baseUrl = Constants.baseUrl;
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenStorage.getToken();
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Uint8List> downloadInventoryCsv() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/export/inventory'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        SessionService.instance.forceLogout();
        throw Exception('Unauthorized. Please log in.');
      } else {
        throw Exception('Export failed. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List> downloadJournalCsv(DateTime startDate, DateTime endDate) async {
    try {
      final start = startDate.toUtc().toIso8601String();
      final end = endDate.toUtc().toIso8601String();

      final response = await http.get(
        Uri.parse('$_baseUrl/export/journal?startDate=$start&endDate=$end'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        SessionService.instance.forceLogout();
        throw Exception('Unauthorized. Please log in.');
      } else {
        throw Exception('Export failed. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('The server is not responding. Please check your connection or try again later.');
    } catch (e) {
      rethrow;
    }
  }
}
