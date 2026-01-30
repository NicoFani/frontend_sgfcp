import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverCommissionService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  /// Obtener todas las comisiones (historial)
  static Future<List<Map<String, dynamic>>> getDriverCommissions({
    required int driverId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/drivers/$driverId/commission/history'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<Map<String, dynamic>>>(
        response,
        (jsonData) {
          final data = jsonData['data'] as List<dynamic>;
          return data
              .map((commission) => commission as Map<String, dynamic>)
              .toList();
        },
        operation: 'obtener historial de comisiones',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Obtener la comisión actual de un chofer
  static Future<Map<String, dynamic>> getDriverCommissionById({
    required int driverId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/drivers/$driverId/commission/current'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (jsonData) => jsonData['data'] as Map<String, dynamic>,
        operation: 'obtener comisión actual del chofer',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Crear/Establecer una nueva comisión para un chofer
  static Future<Map<String, dynamic>> createDriverCommission({
    required int driverId,
    required double commissionPercentage,
    DateTime? effectiveFrom,
  }) async {
    final token = TokenStorage.accessToken;

    final body = <String, dynamic>{
      'driver_id': driverId,
      'commission_percentage': commissionPercentage,
    };

    if (effectiveFrom != null) {
      body['effective_from'] = effectiveFrom.toIso8601String();
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/drivers/$driverId/commission'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (jsonData) => jsonData['data'] as Map<String, dynamic>,
        operation: 'crear comisión del chofer',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
  // TODO: CREAR FUNCIONALIDAD DE ACTUALIZAR COMISIÓN UNA VEZ QUE EL BACKEND LO SOPORTE
  /// Actualizar una comisión existente (nota: el backend cierra la anterior)
  // static Future<Map<String, dynamic>> updateDriverCommission({
  //   required int driverId,
  //   required double commissionPercentage,
  //   DateTime? effectiveFrom,
  // }) async {
  //   final token = TokenStorage.accessToken;

  //   final body = <String, dynamic>{
  //     'commission_percentage': commissionPercentage,
  //   };

  //   // if (effectiveFrom != null) {
  //   //   body['effective_from'] = effectiveFrom.toIso8601String();
  //   // }

  //   try {
  //     final response = await http
  //         .post(
  //           Uri.parse('$baseUrl/api/drivers/$driverId/commission'),
  //           headers: ApiResponseHandler.createHeaders(token),
  //           body: jsonEncode(body),
  //         )
  //         .timeout(ApiResponseHandler.defaultTimeout);

  //     return ApiResponseHandler.handleResponse<Map<String, dynamic>>(
  //       response,
  //       (jsonData) => jsonData['data'] as Map<String, dynamic>,
  //       operation: 'actualizar comisión del chofer',
  //     );
  //   } catch (e) {
  //     ApiResponseHandler.handleNetworkError(e);
  //   }
  // }

  /// Eliminar una comisión (nota: el backend no tiene endpoint de eliminar)
  /// Esta función no está implementada porque el backend no lo soporta
  static Future<void> deleteDriverCommission({
    required int commissionId,
  }) async {
    throw UnimplementedError(
      'El backend no soporta eliminación de comisiones. Las comisiones se cierran automáticamente.',
    );
  }
}
