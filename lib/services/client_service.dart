import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:frontend_sgfcp/models/client_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';

class ClientService {
  static const String baseUrl = 'http://localhost:5000';

  // GET ALL - Obtener todos los clientes
  static Future<List<ClientData>> getClients() async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/clients/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((client) => ClientData.fromJson(client)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}