import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:frontend_sgfcp/models/expense_data.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExpenseService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET BY TRIP - Obtener gastos de un viaje
  static Future<List<ExpenseData>> getExpensesByTrip({
    required int tripId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/expenses/trip/$tripId'),
            headers: ApiResponseHandler.createHeaders(null, includeContentType: false),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<ExpenseData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((expense) => ExpenseData.fromJson(expense))
            .toList(),
        operation: 'obtener gastos del viaje',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}