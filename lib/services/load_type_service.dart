import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:frontend_sgfcp/models/load_type_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoadTypeService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los tipos de carga
  static Future<List<LoadTypeData>> getLoadTypes() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/load-types'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<LoadTypeData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((loadType) => LoadTypeData.fromJson(loadType))
            .toList(),
        operation: 'obtener tipos de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET ONE - Obtener un tipo de carga específico
  static Future<LoadTypeData> getLoadTypeById({required int loadTypeId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/load-types/$loadTypeId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<LoadTypeData>(
        response,
        (jsonData) => LoadTypeData.fromJson(jsonData),
        operation: 'obtener tipo de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Crear un nuevo tipo de carga
  static Future<LoadTypeData> createLoadType({
    required String name,
    required bool defaultCalculatedPerKm,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/load-types'),
            headers: ApiResponseHandler.createHeaders(token),
            body: json.encode({
              'name': name,
              'default_calculated_per_km': defaultCalculatedPerKm,
            }),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<LoadTypeData>(
        response,
        (jsonData) => LoadTypeData.fromJson(jsonData),
        operation: 'crear tipo de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar un tipo de carga
  static Future<LoadTypeData> updateLoadType({
    required int loadTypeId,
    String? name,
    bool? defaultCalculatedPerKm,
  }) async {
    final token = TokenStorage.accessToken;

    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (defaultCalculatedPerKm != null) {
      body['default_calculated_per_km'] = defaultCalculatedPerKm;
    }

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/load-types/$loadTypeId'),
            headers: ApiResponseHandler.createHeaders(token),
            body: json.encode(body),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<LoadTypeData>(
        response,
        (jsonData) => LoadTypeData.fromJson(jsonData),
        operation: 'actualizar tipo de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // DELETE - Eliminar un tipo de carga
  static Future<void> deleteLoadType({required int loadTypeId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/load-types/$loadTypeId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<void>(
        response,
        (_) => null,
        operation: 'eliminar tipo de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
