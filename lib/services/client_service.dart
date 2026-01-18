import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:frontend_sgfcp/models/client_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClientService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

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

  // GET ONE - Obtener un cliente específico
  static Future<ClientData> getClientById({required int clientId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/clients/$clientId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<ClientData>(
        response,
        (jsonData) => ClientData.fromJson(jsonData),
        operation: 'obtener cliente',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Crear un nuevo cliente
  static Future<ClientData> createClient({required String name}) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {'name': name};

      final response = await http
          .post(
            Uri.parse('$baseUrl/clients/'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<ClientData>(
        response,
        (jsonData) => ClientData.fromJson(jsonData['client'] ?? jsonData),
        operation: 'crear cliente',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar un cliente
  static Future<ClientData> updateClient({
    required int clientId,
    required String name,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {'name': name};

      final response = await http
          .put(
            Uri.parse('$baseUrl/clients/$clientId'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<ClientData>(
        response,
        (jsonData) => ClientData.fromJson(jsonData['client'] ?? jsonData),
        operation: 'actualizar cliente',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // DELETE - Eliminar un cliente
  static Future<void> deleteClient({required int clientId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/clients/$clientId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'eliminar cliente',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
