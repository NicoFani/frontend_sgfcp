import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverGuaranteedMinimumService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  /// Obtener todos los mínimos garantizados
  /// Opcionalmente filtrados por chofer
  static Future<List<Map<String, dynamic>>> getDriverGuaranteedMinimums({
    int? driverId,
  }) async {
    final token = TokenStorage.accessToken;
    final queryParams = <String, String>{};

    if (driverId != null) {
      queryParams['driver_id'] = driverId.toString();
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/minimum-guaranteed')
                .replace(queryParameters: queryParams),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<Map<String, dynamic>>>(
        response,
        (jsonData) {
          // El backend retorna un array directamente o bajo 'data'
          final data = jsonData is List ? jsonData : jsonData['data'] ?? [];
          return (data as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        },
        operation: 'obtener mínimos garantizados',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Obtener un mínimo garantizado por ID
  static Future<Map<String, dynamic>> getDriverGuaranteedMinimumById({
    required int minimumId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/minimum-guaranteed/$minimumId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (jsonData) => jsonData is Map
            ? jsonData as Map<String, dynamic>
            : jsonData['data'] as Map<String, dynamic>,
        operation: 'obtener mínimo garantizado',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Crear un nuevo mínimo garantizado
  static Future<Map<String, dynamic>> createDriverGuaranteedMinimum({
    required int driverId,
    required double amount,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final token = TokenStorage.accessToken;

    final body = <String, dynamic>{
      'driver_id': driverId,
      'minimum_guaranteed': amount,
      'effective_from': startDate.toIso8601String(),
    };

    if (endDate != null) {
      body['effective_until'] = endDate.toIso8601String();
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/minimum-guaranteed'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (jsonData) => jsonData is Map
            ? jsonData as Map<String, dynamic>
            : jsonData['data'] as Map<String, dynamic>,
        operation: 'crear mínimo garantizado',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Actualizar un mínimo garantizado existente
  static Future<Map<String, dynamic>> updateDriverGuaranteedMinimum({
    required int minimumId,
    double? amount,
    // DateTime? startDate,
    // DateTime? endDate,
  }) async {
    final token = TokenStorage.accessToken;

    final body = <String, dynamic>{};

    if (amount != null) body['minimum_guaranteed'] = amount;
    // if (startDate != null) body['effective_from'] = startDate.toIso8601String();
    // if (endDate != null) body['effective_until'] = endDate.toIso8601String();

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/minimum-guaranteed/$minimumId'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (jsonData) => jsonData is Map
            ? jsonData as Map<String, dynamic>
            : jsonData['data'] as Map<String, dynamic>,
        operation: 'actualizar mínimo garantizado',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Eliminar un mínimo garantizado
  static Future<void> deleteDriverGuaranteedMinimum({
    required int minimumId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/minimum-guaranteed/$minimumId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'eliminar mínimo garantizado',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Obtener el mínimo garantizado vigente para un chofer
  static Future<Map<String, dynamic>> getCurrentMinimumGuaranteed({
    required int driverId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/minimum-guaranteed/driver/$driverId/current'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (jsonData) => jsonData is Map
            ? jsonData as Map<String, dynamic>
            : jsonData['data'] as Map<String, dynamic>,
        operation: 'obtener mínimo garantizado vigente',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Obtener el mínimo garantizado vigente en una fecha específica
  static Future<Map<String, dynamic>> getMinimumGuaranteedAtDate({
    required int driverId,
    required DateTime date,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/minimum-guaranteed/driver/$driverId/at-date?date=${date.toIso8601String()}',
            ),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (jsonData) => jsonData is Map
            ? jsonData as Map<String, dynamic>
            : jsonData['data'] as Map<String, dynamic>,
        operation: 'obtener mínimo garantizado en fecha específica',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
