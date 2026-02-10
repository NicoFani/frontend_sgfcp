import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los choferes
  static Future<List<DriverData>> getDrivers() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/drivers/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<DriverData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((driver) => DriverData.fromJson(driver))
            .toList(),
        operation: 'obtener choferes',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET ONE - Obtener un chofer específico
  static Future<DriverData> getDriverById({required int driverId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/drivers/$driverId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<DriverData>(
        response,
        (jsonData) => DriverData.fromJson(jsonData),
        operation: 'obtener chofer',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Crear un nuevo chofer completo (usuario + driver)
  static Future<DriverData> createDriverComplete({
    required String email,
    required String name,
    required String surname,
    required String cuil,
    required String cvu,
    required String phoneNumber,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      // Crear payload combinado
      final payload = {
        'email': email,
        'name': name,
        'surname': surname,
        'cuil': cuil,
        'cbu': cvu,
        'phone_number': phoneNumber,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/drivers/complete'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<DriverData>(
        response,
        (jsonData) => DriverData.fromJson(jsonData['driver']),
        operation: 'crear chofer completo',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Crear un nuevo chofer
  static Future<DriverData> createDriver({
    required int id, // This is the user ID
    required int dni,
    required String cuil,
    required String phoneNumber,
    required String cbu,
    required double commission,
    required DateTime enrollmentDate,
    required DateTime driverLicenseDueDate,
    required DateTime medicalExamDueDate,
    DateTime? terminationDate,
    bool active = true,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        'id': id,
        'dni': dni,
        'cuil': cuil,
        'phone_number': phoneNumber,
        'cbu': cbu,
        'commission': commission,
        'enrollment_date': enrollmentDate.toIso8601String().split('T')[0],
        'driver_license_due_date': driverLicenseDueDate.toIso8601String().split(
          'T',
        )[0],
        'medical_exam_due_date': medicalExamDueDate.toIso8601String().split(
          'T',
        )[0],
        'active': active,
        if (terminationDate != null)
          'termination_date': terminationDate.toIso8601String().split('T')[0],
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/drivers/'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<DriverData>(
        response,
        (jsonData) => DriverData.fromJson(jsonData),
        operation: 'crear chofer',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar datos básicos del chofer
  static Future<DriverData> updateDriverBasicData({
    required int driverId,
    String? name,
    String? surname,
    String? cuil,
    String? cvu,
    String? phoneNumber,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        if (name != null) 'name': name,
        if (surname != null) 'surname': surname,
        if (cuil != null) 'cuil': cuil,
        if (cvu != null) 'cbu': cvu,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/drivers/$driverId/basic'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<DriverData>(
        response,
        (jsonData) => DriverData.fromJson(jsonData['driver']),
        operation: 'actualizar datos del chofer',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar un chofer
  static Future<Map<String, dynamic>> updateDriver({
    required int driverId,
    int? dni,
    String? cuil,
    String? phoneNumber,
    String? cbu,
    double? commission,
    DateTime? enrollmentDate,
    DateTime? terminationDate,
    DateTime? driverLicenseDueDate,
    DateTime? medicalExamDueDate,
    bool? active,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        if (dni != null) 'dni': dni,
        if (cuil != null) 'cuil': cuil,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (cbu != null) 'cbu': cbu,
        if (commission != null) 'commission': commission,
        if (enrollmentDate != null)
          'enrollment_date': enrollmentDate.toIso8601String().split('T')[0],
        if (terminationDate != null)
          'termination_date': terminationDate.toIso8601String().split('T')[0],
        if (driverLicenseDueDate != null)
          'driver_license_due_date': driverLicenseDueDate
              .toIso8601String()
              .split('T')[0],
        if (medicalExamDueDate != null)
          'medical_exam_due_date': medicalExamDueDate.toIso8601String().split(
            'T',
          )[0],
        if (active != null) 'active': active,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/drivers/$driverId'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (jsonData) => {
          'success': true,
          'message': 'Usuario actualizado exitosamente',
          'user': jsonData['user'],

        },
        operation: 'actualizar chofer',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // DELETE - Eliminar un chofer
  static Future<void> deleteDriver({required int driverId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/drivers/$driverId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'eliminar chofer',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
