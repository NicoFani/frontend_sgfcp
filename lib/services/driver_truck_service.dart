import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:frontend_sgfcp/models/driver_truck_data.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverTruckService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todas las asignaciones conductor-camión
  static Future<List<DriverTruckData>> getDriverTrucks() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/driver-trucks/'),
            headers: ApiResponseHandler.createHeaders(null, includeContentType: false),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<DriverTruckData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((item) => DriverTruckData.fromJson(item))
            .toList(),
        operation: 'obtener asignaciones conductor-camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET ONE - Obtener una asignación específica
  static Future<DriverTruckData> getDriverTruckById({required int driverTruckId}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/driver-trucks/$driverTruckId'),
            headers: ApiResponseHandler.createHeaders(null, includeContentType: false),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<DriverTruckData>(
        response,
        (jsonData) => DriverTruckData.fromJson(jsonData),
        operation: 'obtener asignación conductor-camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Asignar conductor a camión
  static Future<DriverTruckData> assignDriverToTruck({
    required int driverId,
    required int truckId,
    required DateTime date,
  }) async {
    try {
      final payload = {
        'driver_id': driverId,
        'truck_id': truckId,
        'date': date.toIso8601String().split('T')[0],
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/driver-trucks/'),
            headers: ApiResponseHandler.createHeaders(null, includeContentType: false),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<DriverTruckData>(
        response,
        (jsonData) => DriverTruckData.fromJson(jsonData['driver_truck']),
        operation: 'asignar conductor a camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar asignación
  static Future<DriverTruckData> updateDriverTruck({
    required int driverTruckId,
    int? driverId,
    int? truckId,
    DateTime? date,
  }) async {
    try {
      final payload = {
        if (driverId != null) 'driver_id': driverId,
        if (truckId != null) 'truck_id': truckId,
        if (date != null) 'date': date.toIso8601String().split('T')[0],
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/driver-trucks/$driverTruckId'),
            headers: ApiResponseHandler.createHeaders(null, includeContentType: false),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<DriverTruckData>(
        response,
        (jsonData) => DriverTruckData.fromJson(jsonData['driver_truck']),
        operation: 'actualizar asignación conductor-camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // DELETE - Remover asignación conductor-camión
  static Future<void> removeDriverFromTruck({required int driverTruckId}) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/driver-trucks/$driverTruckId'),
            headers: ApiResponseHandler.createHeaders(null, includeContentType: false),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'remover asignación conductor-camión',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // TODO: These methods require backend implementation
  // GET TRUCKS BY DRIVER - Obtener camiones asignados a un conductor
  // static Future<List<TruckData>> getTrucksByDriver({required int driverId}) async {
  //   // This would require a new backend endpoint
  // }

  // GET DRIVERS BY TRUCK - Obtener conductores asignados a un camión
  // static Future<List<DriverData>> getDriversByTruck({required int truckId}) async {
  //   // This would require a new backend endpoint
  // }
}