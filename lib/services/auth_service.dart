import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = 'http://localhost:5000';

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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return {
          'success': true,
          'access_token': jsonData['access_token'],
          'refresh_token': jsonData['refresh_token'],
          'user': jsonData['user'],
        };
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'Email o contraseña incorrectos'};
      } else if (response.statusCode == 403) {
        return {'success': false, 'error': 'Usuario inactivo'};
      } else {
        return {
          'success': false,
          'error': 'Error al iniciar sesión: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Usuario registrado exitosamente'};
      } else if (response.statusCode == 409) {
        return {'success': false, 'error': 'El email ya está registrado'};
      } else {
        final jsonData = jsonDecode(response.body);
        return {
          'success': false,
          'error': jsonData['error'] ?? 'Error al registrar usuario',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
