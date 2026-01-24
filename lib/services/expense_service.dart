import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:frontend_sgfcp/models/expense_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ExpenseService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET BY TRIP - Obtener gastos de un viaje
  static Future<List<ExpenseData>> getExpensesByTrip({
    required int tripId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/expenses/trip/$tripId'),
            headers: ApiResponseHandler.createHeaders(
              token,
              includeContentType: false,
            ),
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

  // GET ALL - Obtener todos los gastos (filtrados por conductor si no es admin)
  static Future<List<ExpenseData>> getAllExpenses() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/expenses/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<ExpenseData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((expense) => ExpenseData.fromJson(expense))
            .toList(),
        operation: 'obtener todos los gastos',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET ONE - Obtener un gasto específico
  static Future<ExpenseData> getExpenseById({required int expenseId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/expenses/$expenseId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<ExpenseData>(
        response,
        (jsonData) => ExpenseData.fromJson(jsonData),
        operation: 'obtener gasto',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Crear un nuevo gasto
  static Future<ExpenseData> createExpense({
    required int driverId,
    required String expenseType,
    required DateTime date,
    required double amount,
    int? tripId,
    String? description,
    String? receiptUrl,
    String? fineMunicipality,
    String? repairType,
    double? fuelLiters,
    String? tollType,
    bool? paidByAdmin,
    String? tollPortFeeName,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final payload = {
        'driver_id': driverId,
        'expense_type': expenseType,
        'date': date.toIso8601String().split('T')[0],
        'amount': amount,
        if (tripId != null) 'trip_id': tripId,
        if (description != null) 'description': description,
        if (receiptUrl != null) 'receipt_url': receiptUrl,
        if (fineMunicipality != null) 'fine_municipality': fineMunicipality,
        if (repairType != null) 'repair_type': repairType,
        if (fuelLiters != null) 'fuel_liters': fuelLiters,
        if (tollType != null) 'toll_type': tollType,
        if (paidByAdmin != null) 'paid_by_admin': paidByAdmin,
        if (tollPortFeeName != null) 'toll_port_fee_name': tollPortFeeName,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/expenses/'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<ExpenseData>(
        response,
        (jsonData) => ExpenseData.fromJson(jsonData['expense']),
        operation: 'crear gasto',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar un gasto
  static Future<ExpenseData> updateExpense({
    required int expenseId,
    required Map<String, dynamic> data,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/expenses/$expenseId'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(data),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<ExpenseData>(
        response,
        (jsonData) => ExpenseData.fromJson(jsonData['expense']),
        operation: 'actualizar gasto',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // DELETE - Eliminar un gasto
  static Future<void> deleteExpense({required int expenseId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/expenses/$expenseId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'eliminar gasto',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET BY TYPE - Obtener gastos por tipo
  static Future<List<ExpenseData>> getExpensesByType({
    required String expenseType,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/expenses/type/$expenseType'),
            headers: ApiResponseHandler.createHeaders(
              null,
              includeContentType: false,
            ),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<ExpenseData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((expense) => ExpenseData.fromJson(expense))
            .toList(),
        operation: 'obtener gastos por tipo',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
