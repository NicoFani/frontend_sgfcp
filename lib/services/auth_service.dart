import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      final jsonData = ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (data) => {
          'success': true,
          'access_token': data['access_token'],
          'refresh_token': data['refresh_token'],
          'user': data['user'],
        },
        operation: 'iniciar sesión',
      );

      return jsonData;
    } catch (e) {
      if (e is ApiException) {
        return {
          'success': false,
          'error': e.message,
        };
      }
      return {
        'success': false,
        'error': 'Error de conexión. Verifica tu conexión a internet.',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String surname,
    required String email,
    required String password,
    bool isAdmin = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'surname': surname,
              'email': email,
              'password': password,
              'is_admin': isAdmin,
            }),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      final jsonData = ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (data) => {
          'success': true,
          'message': 'Usuario registrado exitosamente',
          'user': data['user'],
        },
        operation: 'registrar usuario',
      );

      return jsonData;
    } catch (e) {
      if (e is ApiException) {
        return {
          'success': false,
          'error': e.message,
        };
      }
      return {
        'success': false,
        'error': 'Error de conexión. Verifica tu conexión a internet.',
      };
    }
  }
}
