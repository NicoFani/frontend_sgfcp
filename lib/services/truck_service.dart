import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:frontend_sgfcp/models/truck_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TruckService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los camiones
  static Future<List<TruckData>> getTrucks() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/trucks/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<TruckData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((truck) => TruckData.fromJson(truck))
            .toList(),
        operation: 'obtener camiones',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET ONE - Obtener un camión específico
  static Future<TruckData> getTruckById({required int truckId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/trucks/$truckId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<TruckData>(
        response,
        (jsonData) => TruckData.fromJson(jsonData),
        operation: 'obtener camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Crear un nuevo camión
  static Future<TruckData> createTruck({
    required String plate,
    required bool operational,
    required String brand,
    required String modelName,
    required int fabricationYear,
    required DateTime serviceDueDate,
    required DateTime vtvDueDate,
    required DateTime plateDueDate,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        'plate': plate,
        'operational': operational,
        'brand': brand,
        'model_name': modelName,
        'fabrication_year': fabricationYear,
        'service_due_date': serviceDueDate.toIso8601String().split('T')[0],
        'vtv_due_date': vtvDueDate.toIso8601String().split('T')[0],
        'plate_due_date': plateDueDate.toIso8601String().split('T')[0],
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/trucks/'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<TruckData>(
        response,
        (jsonData) => TruckData.fromJson(jsonData),
        operation: 'crear camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar un camión
  static Future<TruckData> updateTruck({
    required int truckId,
    String? plate,
    bool? operational,
    String? brand,
    String? modelName,
    int? fabricationYear,
    DateTime? serviceDueDate,
    DateTime? vtvDueDate,
    DateTime? plateDueDate,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        if (plate != null) 'plate': plate,
        if (operational != null) 'operational': operational,
        if (brand != null) 'brand': brand,
        if (modelName != null) 'model_name': modelName,
        if (fabricationYear != null) 'fabrication_year': fabricationYear,
        if (serviceDueDate != null)
          'service_due_date': serviceDueDate.toIso8601String().split('T')[0],
        if (vtvDueDate != null)
          'vtv_due_date': vtvDueDate.toIso8601String().split('T')[0],
        if (plateDueDate != null)
          'plate_due_date': plateDueDate.toIso8601String().split('T')[0],
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/trucks/$truckId'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<TruckData>(
        response,
        (jsonData) => TruckData.fromJson(jsonData),
        operation: 'actualizar camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // DELETE - Eliminar un camión
  static Future<void> deleteTruck({required int truckId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/trucks/$truckId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'eliminar camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET - Obtener el chofer actual asignado a un camión
  static Future<Map<String, dynamic>?> getTruckCurrentDriver({
    required int truckId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/trucks/$truckId/current-driver'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<Map<String, dynamic>?>(
        response,
        (jsonData) => jsonData as Map<String, dynamic>?,
        operation: 'obtener chofer del camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
