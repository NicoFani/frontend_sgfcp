import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_sgfcp/services/token_storage.dart';
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

  static Future<Map<String, dynamic>> refreshToken() async {
    final refreshToken = TokenStorage.refreshToken;

    if (refreshToken == null) {
      return {
        'success': false,
        'error': 'No hay token de refresco disponible',
      };
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $refreshToken',
            },
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      final jsonData = ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (data) => {
          'success': true,
          'access_token': data['access_token'],
        },
        operation: 'renovar token',
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

  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = TokenStorage.accessToken;

    if (token == null) {
      return {
        'success': false,
        'error': 'No hay token de acceso disponible',
      };
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      final jsonData = ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (data) => {
          'success': true,
          'user': data,
        },
        operation: 'obtener usuario actual',
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

  static Future<Map<String, dynamic>> logout() async {
    final token = TokenStorage.accessToken;

    if (token == null) {
      return {
        'success': false,
        'error': 'No hay token de acceso disponible',
      };
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'cerrar sesión',
      );

      return {
        'success': true,
        'message': 'Sesión cerrada exitosamente',
      };
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

  static Future<Map<String, dynamic>> updateUser({
    required int userId,
    String? name,
    String? surname,
    String? email,
    bool? isAdmin,
  }) async {
    final token = TokenStorage.accessToken;

    if (token == null) {
      return {
        'success': false,
        'error': 'No hay token de acceso disponible',
      };
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (surname != null) body['surname'] = surname;
    if (email != null) body['email'] = email;
    if (isAdmin != null) body['is_admin'] = isAdmin;

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/users/$userId'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      final jsonData = ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (data) => {
          'success': true,
          'message': 'Usuario actualizado exitosamente',
          'user': data['user'],
        },
        operation: 'actualizar usuario',
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

  // TODO: These functions require backend implementation
  // static Future<Map<String, dynamic>> resetPassword({
  //   required String email,
  // }) async {
  //   // This would require a new backend endpoint like /auth/reset-password
  // }
}
