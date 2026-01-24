import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_sgfcp/models/payroll_summary_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PayrollSummaryService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  /// Generar nómina para un período y chofer específico
  static Future<PayrollSummaryData> generateSummary({
    required int periodId,
    required int driverId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        'period_id': periodId,
        'driver_ids': [driverId],
        'is_manual': false,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/payroll/summaries/generate'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<PayrollSummaryData>(response, (
        jsonData,
      ) {
        final summaries = jsonData['data'] as List<dynamic>;
        if (summaries.isEmpty) {
          throw Exception('No se pudo generar el resumen');
        }
        return PayrollSummaryData.fromJson(summaries[0]);
      }, operation: 'generar resumen de nómina');
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Obtener resúmenes de un período
  static Future<List<PayrollSummaryData>> getSummariesByPeriod({
    required int periodId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/payroll/summaries?period_id=$periodId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<PayrollSummaryData>>(
        response,
        (jsonData) {
          final data = jsonData['data'] as List<dynamic>;
          return data
              .map((summary) => PayrollSummaryData.fromJson(summary))
              .toList();
        },
        operation: 'obtener resúmenes de nómina',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Obtener todos los resúmenes
  static Future<List<PayrollSummaryData>> getAllSummaries() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/payroll/summaries'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<PayrollSummaryData>>(
        response,
        (jsonData) {
          final data = jsonData['data'] as List<dynamic>;
          return data
              .map((summary) => PayrollSummaryData.fromJson(summary))
              .toList();
        },
        operation: 'obtener todos los resúmenes',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Obtener un resumen específico por ID
  static Future<PayrollSummaryData> getSummaryById({
    required int summaryId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/payroll/summaries/$summaryId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<PayrollSummaryData>(response, (
        jsonData,
      ) {
        final data = jsonData['data'];
        return PayrollSummaryData.fromJson(data['summary']);
      }, operation: 'obtener resumen de nómina');
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
