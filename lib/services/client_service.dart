import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:frontend_sgfcp/models/client_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los clientes
  static Future<List<ClientData>> getClients() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/clients/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<ClientData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((client) => ClientData.fromJson(client))
            .toList(),
        operation: 'obtener clientes',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}