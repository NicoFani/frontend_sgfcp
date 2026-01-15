import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:frontend_sgfcp/models/load_owner_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoadOwnerService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los dadores de carga
  static Future<List<LoadOwnerData>> getLoadOwners() async {
    try {
      final token = TokenStorage.accessToken;
      final response = await http
          .get(
            Uri.parse('$baseUrl/load-owners/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((item) => LoadOwnerData.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception(
          'Error al obtener dadores de carga: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}