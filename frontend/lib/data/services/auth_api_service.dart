
import 'dart:convert';
import 'package:frontend/core/constants.dart';
import 'package:http/http.dart' as http;
import '../models/auth_result.dart';
import '../dtos/login_dto.dart';
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
}