import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:frontend_sgfcp/models/advance_payment_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdvancePaymentService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los adelantos
  static Future<List<AdvancePaymentData>> getAdvancePayments() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/advance-payments/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<AdvancePaymentData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((advance) => AdvancePaymentData.fromJson(advance))
            .toList(),
        operation: 'obtener adelantos',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET ONE - Obtener un adelanto por ID
  static Future<AdvancePaymentData> getAdvancePayment({
    required int advancePaymentId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/advance-payments/$advancePaymentId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<AdvancePaymentData>(
        response,
        (jsonData) => AdvancePaymentData.fromJson(jsonData),
        operation: 'obtener adelanto',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Crear un nuevo adelanto
  static Future<AdvancePaymentData> createAdvancePayment({
    required int driverId,
    required DateTime date,
    required double amount,
    Uint8List? receiptFileBytes,
    String? receiptFileName,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      // Si hay archivo adjunto, usar multipart/form-data
      if (receiptFileBytes != null && receiptFileName != null) {
        final uri = Uri.parse('$baseUrl/advance-payments/');
        final request = http.MultipartRequest('POST', uri);

        // Headers
        request.headers['Authorization'] = 'Bearer $token';

        // Campos del formulario
        request.fields['driver_id'] = driverId.toString();
        request.fields['date'] = date.toIso8601String().split('T')[0];
        request.fields['amount'] = amount.toString();

        // Archivo adjunto
        request.files.add(
          http.MultipartFile.fromBytes(
            'receipt',
            receiptFileBytes,
            filename: receiptFileName,
          ),
        );

        final streamedResponse = await request.send().timeout(
          ApiResponseHandler.defaultTimeout,
        );
        final response = await http.Response.fromStream(streamedResponse);

        return ApiResponseHandler.handleResponse<AdvancePaymentData>(
          response,
          (jsonData) =>
              AdvancePaymentData.fromJson(jsonData['advance_payment']),
          operation: 'crear adelanto con comprobante',
        );
      } else {
        // Sin archivo, usar JSON normal
        final payload = {
          'driver_id': driverId,
          'date': date.toIso8601String().split('T')[0],
          'amount': amount,
        };

        final response = await http
            .post(
              Uri.parse('$baseUrl/advance-payments/'),
              headers: ApiResponseHandler.createHeaders(token),
              body: jsonEncode(payload),
            )
            .timeout(ApiResponseHandler.defaultTimeout);

        return ApiResponseHandler.handleResponse<AdvancePaymentData>(
          response,
          (jsonData) =>
              AdvancePaymentData.fromJson(jsonData['advance_payment']),
          operation: 'crear adelanto',
        );
      }
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar un adelanto
  static Future<AdvancePaymentData> updateAdvancePayment({
    required int advancePaymentId,
    required int driverId,
    required DateTime date,
    required double amount,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        'driver_id': driverId,
        'date': date.toIso8601String().split('T')[0],
        'amount': amount,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/advance-payments/$advancePaymentId'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<AdvancePaymentData>(
        response,
        (jsonData) => AdvancePaymentData.fromJson(jsonData['advance_payment']),
        operation: 'actualizar adelanto',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // DELETE - Eliminar un adelanto
  static Future<void> deleteAdvancePayment({
    required int advancePaymentId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/advance-payments/$advancePaymentId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'eliminar adelanto',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
