import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:frontend_sgfcp/models/load_owner_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoadOwnerService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los dadores de carga
  static Future<List<LoadOwnerData>> getLoadOwners() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/load-owners/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<LoadOwnerData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((item) => LoadOwnerData.fromJson(item as Map<String, dynamic>))
            .toList(),
        operation: 'obtener dadores de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET ONE - Obtener un dador de carga específico
  static Future<LoadOwnerData> getLoadOwnerById({required int loadOwnerId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/load-owners/$loadOwnerId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<LoadOwnerData>(
        response,
        (jsonData) => LoadOwnerData.fromJson(jsonData),
        operation: 'obtener dador de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Crear un nuevo dador de carga
  static Future<LoadOwnerData> createLoadOwner({
    required String name,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        'name': name,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/load-owners/'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<LoadOwnerData>(
        response,
        (jsonData) => LoadOwnerData.fromJson(jsonData),
        operation: 'crear dador de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar un dador de carga
  static Future<LoadOwnerData> updateLoadOwner({
    required int loadOwnerId,
    required String name,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        'name': name,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/load-owners/$loadOwnerId'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<LoadOwnerData>(
        response,
        (jsonData) => LoadOwnerData.fromJson(jsonData),
        operation: 'actualizar dador de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // DELETE - Eliminar un dador de carga
  static Future<void> deleteLoadOwner({required int loadOwnerId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/load-owners/$loadOwnerId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'eliminar dador de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}