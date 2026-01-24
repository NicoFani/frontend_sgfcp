import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PayrollOtherItemService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  /// Crear nuevo concepto de nómina
  static Future<Map<String, dynamic>> createOtherItem({
    required int driverId,
    required int periodId,
    required String itemType,
    required String description,
    required double amount,
    String? reference,
    String? receiptUrl,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payroll-other-items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'driver_id': driverId,
          'period_id': periodId,
          'item_type': itemType,
          'description': description,
          'amount': amount,
          'reference': reference,
          'receipt_url': receiptUrl,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creando concepto: $e');
    }
  }

  /// Obtener todos los conceptos
  static Future<Map<String, dynamic>> getAllOtherItems({
    int? driverId,
    int? periodId,
    String? itemType,
    int page = 1,
    int perPage = 20,
  }) async {
    final token = TokenStorage.accessToken;
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (driverId != null) queryParams['driver_id'] = driverId.toString();
    if (periodId != null) queryParams['period_id'] = periodId.toString();
    if (itemType != null) queryParams['item_type'] = itemType;

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/payroll-other-items',
        ).replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error obteniendo conceptos: $e');
    }
  }

  /// Obtener conceptos por período y chofer
  static Future<List<Map<String, dynamic>>> getOtherItemsByPeriodAndDriver({
    required int periodId,
    required int driverId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/payroll-other-items/period/$periodId/driver/$driverId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return (jsonData as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error obteniendo conceptos: $e');
    }
  }

  /// Actualizar concepto
  static Future<Map<String, dynamic>> updateOtherItem({
    required int itemId,
    String? description,
    double? amount,
    DateTime? date,
    String? reference,
  }) async {
    final token = TokenStorage.accessToken;
    final body = <String, dynamic>{};

    if (description != null) body['description'] = description;
    if (amount != null) body['amount'] = amount;
    if (date != null) body['date'] = date.toIso8601String().split('T').first;
    if (reference != null) body['reference'] = reference;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/payroll-other-items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error actualizando concepto: $e');
    }
  }

  /// Eliminar concepto
  static Future<void> deleteOtherItem({required int itemId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/payroll-other-items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error eliminando concepto: $e');
    }
  }
}
