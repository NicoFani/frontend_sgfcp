import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:frontend_sgfcp/models/expense_data.dart';

class ExpenseService {
  static const String baseUrl = 'http://localhost:5000';

  // GET BY TRIP - Obtener gastos de un viaje
  static Future<List<ExpenseData>> getExpensesByTrip({
    required int tripId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/expenses/trip/$tripId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((expense) => ExpenseData.fromJson(expense))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener gastos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}