import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:frontend_sgfcp/models/advance_payment_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';

class AdvancePaymentService {
  static const String baseUrl = 'http://localhost:5000';

  // GET ALL - Obtener todos los adelantos
  static Future<List<AdvancePaymentData>> getAdvancePayments() async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/advance-payments/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((advance) => AdvancePaymentData.fromJson(advance))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener adelantos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // GET ONE - Obtener un adelanto por ID
  static Future<AdvancePaymentData> getAdvancePayment({
    required int advancePaymentId,
  }) async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/advance-payments/$advancePaymentId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AdvancePaymentData.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else if (response.statusCode == 404) {
        throw Exception('Adelanto no encontrado');
      } else {
        throw Exception('Error al obtener adelanto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // POST - Crear un nuevo adelanto
  static Future<AdvancePaymentData> createAdvancePayment({
    required int driverId,
    required DateTime date,
    required double amount,
  }) async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final payload = {
        'driver_id': driverId,
        'date': date.toIso8601String().split('T')[0],
        'amount': amount,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/advance-payments/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return AdvancePaymentData.fromJson(responseData['advance_payment']);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Datos inválidos: ${errorData['details'] ?? 'Verifique los campos'}',
        );
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para crear adelantos');
      } else {
        throw Exception('Error al crear adelanto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
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
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final payload = {
        'driver_id': driverId,
        'date': date.toIso8601String().split('T')[0],
        'amount': amount,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/advance-payments/$advancePaymentId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AdvancePaymentData.fromJson(responseData['advance_payment']);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Datos inválidos: ${errorData['details'] ?? 'Verifique los campos'}',
        );
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para actualizar este adelanto');
      } else if (response.statusCode == 404) {
        throw Exception('Adelanto no encontrado');
      } else {
        throw Exception('Error al actualizar adelanto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // DELETE - Eliminar un adelanto
  static Future<void> deleteAdvancePayment({
    required int advancePaymentId,
  }) async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/advance-payments/$advancePaymentId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para eliminar este adelanto');
      } else if (response.statusCode == 404) {
        throw Exception('Adelanto no encontrado');
      } else {
        throw Exception('Error al eliminar adelanto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}