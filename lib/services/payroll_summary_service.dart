import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'package:frontend_sgfcp/models/payroll_summary_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PayrollSummaryService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  /// Generar nómina para un período y chofer específico (MANUAL)
  static Future<PayrollSummaryData> generateSummary({
    required int periodId,
    required int driverId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        'period_id': periodId,
        'driver_ids': [driverId],
        'is_manual': true, // Generación MANUAL, estado inicial será "draft"
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

  /// Obtener un resumen específico por ID junto con sus detalles
  static Future<PayrollSummaryWithDetailsData> getSummaryWithDetailsById({
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

      return ApiResponseHandler.handleResponse<PayrollSummaryWithDetailsData>(
        response,
        (jsonData) {
          final data = jsonData['data'] as Map<String, dynamic>;
          final summary = PayrollSummaryData.fromJson(
            data['summary'] as Map<String, dynamic>,
          );
          final rawDetails = (data['details'] as List<dynamic>? ?? const []);
          final details = rawDetails
              .map(
                (detail) =>
                    PayrollDetailData.fromJson(detail as Map<String, dynamic>),
              )
              .toList();

          return PayrollSummaryWithDetailsData(
            summary: summary,
            details: details,
          );
        },
        operation: 'obtener resumen de nómina con detalles',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Recalcular un resumen existente
  ///
  /// Útil cuando:
  /// - Se toca el botón "Recalcular resumen" manualmente
  /// - Se finaliza un viaje y necesita recalcularse un resumen en 'calculation_pending'
  static Future<PayrollSummaryData> recalculateSummary({
    required int summaryId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/payroll/summaries/$summaryId/recalculate'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode({}),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<PayrollSummaryData>(response, (
        jsonData,
      ) {
        final data = jsonData['data'];
        return PayrollSummaryData.fromJson(data['summary']);
      }, operation: 'recalcular resumen de nómina');
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Aprobar un resumen de liquidación
  ///
  /// Solo se pueden aprobar resúmenes en estado 'pending_approval'.
  /// La aprobación es irreversible.
  static Future<PayrollSummaryData> approveSummary({
    required int summaryId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/payroll/summaries/$summaryId/approve'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<PayrollSummaryData>(response, (
        jsonData,
      ) {
        final data = jsonData['data'];
        return PayrollSummaryData.fromJson(data);
      }, operation: 'aprobar resumen de nómina');
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  /// Exportar resumen a Excel o PDF
  ///
  /// Solo PDF para resúmenes aprobados.
  /// Excel para todos los estados.
  static Future<void> exportSummary({
    required int summaryId,
    required String format, // 'excel' o 'pdf'
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/payroll/summaries/$summaryId/export'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode({'format': format}),
          )
          .timeout(const Duration(seconds: 30)); // Más tiempo para exportación

      final data =
          await ApiResponseHandler.handleResponse<Map<String, dynamic>>(
            response,
            (jsonData) {
              return jsonData['data'] as Map<String, dynamic>;
            },
            operation: 'exportar resumen',
          );

      // Ahora descargar el archivo
      final filepath = data['filepath'] as String;
      final downloadUrl = '$baseUrl/api/payroll/summaries/$summaryId/download';

      final downloadResponse = await http.get(
        Uri.parse(downloadUrl),
        headers: ApiResponseHandler.createHeaders(token),
      );

      if (downloadResponse.statusCode == 200) {
        // Trigger download in browser
        final bytes = downloadResponse.bodyBytes;
        final filename = filepath.split('/').last;

        // Use dart:html for web download
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
