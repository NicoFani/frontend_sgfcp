import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los choferes
  static Future<List<DriverData>> getDrivers() async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/drivers/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((driver) => DriverData.fromJson(driver)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener choferes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}