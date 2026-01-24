import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_sgfcp/models/payroll_period_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PayrollPeriodService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  /// Obtener todos los períodos de nómina
  static Future<List<PayrollPeriodData>> getAllPeriods() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/payroll/periods'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<PayrollPeriodData>>(
        response,
        (jsonData) {
          final data = jsonData['data'] as List<dynamic>;
          return data
              .map((period) => PayrollPeriodData.fromJson(period))
              .toList();
        },
        operation: 'obtener períodos de nómina',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Obtener un período específico por ID
  static Future<PayrollPeriodData> getPeriodById({
    required int periodId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/payroll/periods/$periodId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<PayrollPeriodData>(
        response,
        (jsonData) => PayrollPeriodData.fromJson(jsonData),
        operation: 'obtener período de nómina',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
