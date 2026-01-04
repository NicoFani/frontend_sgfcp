import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/models/expense_data.dart';
import 'package:frontend_sgfcp/models/client_data.dart';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/models/load_owner_data.dart';
import 'package:frontend_sgfcp/models/advance_payment_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  // Obtener todos los viajes del conductor autenticado
  static Future<List<TripData>> getTrips() async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/trips/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((trip) => TripData.fromJson(trip)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception('Error al obtener viajes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener un viaje específico
  static Future<TripData> getTrip({required int tripId}) async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/trips/$tripId/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TripData.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else if (response.statusCode == 404) {
        throw Exception('Viaje no encontrado');
      } else {
        throw Exception('Error al obtener viaje: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener viajes filtrados por mes
  static Future<List<TripData>> getTripsByMonth({
    required int year,
    required int month,
  }) async {
    try {
      final allTrips = await getTrips();
      return allTrips
          .where(
            (trip) =>
                trip.startDate.year == year && trip.startDate.month == month,
          )
          .toList();
    } catch (e) {
      throw Exception('Error al filtrar viajes por mes: $e');
    }
  }

  // Obtener el viaje actual (estado "En curso")
  static Future<TripData?> getCurrentTrip() async {
    try {
      final trips = await getTrips();
      try {
        final currentTrip = trips.firstWhere(
          (trip) => trip.state == 'En curso',
        );
        return currentTrip;
      } catch (e) {
        return null;
      }
    } catch (e) {
      throw Exception('Error al obtener viaje actual: $e');
    }
  }

  // Obtener el próximo viaje (estado "Pendiente", el más próximo)
  static Future<TripData?> getNextTrip() async {
    try {
      final trips = await getTrips();
      final pendingTrips = trips
          .where((trip) => trip.state == 'Pendiente')
          .toList();

      if (pendingTrips.isEmpty) return null;

      // Ordenar por fecha de inicio y devolver el primero
      pendingTrips.sort((a, b) => a.startDate.compareTo(b.startDate));
      return pendingTrips.first;
    } catch (e) {
      throw Exception('Error al obtener próximo viaje: $e');
    }
  }

  // Actualizar estado de un viaje
  static Future<TripData> updateTrip({
    required int tripId,
    required Map<String, dynamic> data,
  }) async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final url = Uri.parse('$baseUrl/trips/$tripId');
      final body = jsonEncode(data);

      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return TripData.fromJson(responseData['trip']);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para actualizar este viaje');
      } else if (response.statusCode == 404) {
        throw Exception('Viaje no encontrado');
      } else {
        throw Exception(
          'Error al actualizar viaje: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException catch (_) {
      throw Exception('Conexión agotada. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener gastos de un viaje
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

  // Obtener todos los clientes
  static Future<List<ClientData>> getClients() async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/clients/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((client) => ClientData.fromJson(client)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todos los choferes
  static Future<List<DriverData>> getDrivers() async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/drivers/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((driver) => DriverData.fromJson(driver)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener choferes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear un nuevo viaje
  static Future<TripData> createTrip({
    required String origin,
    String? originDescription,
    required String destination,
    String? destinationDescription,
    required DateTime startDate,
    required int clientId,
    required List<int> driverIds,
    String? documentType,
    String? documentNumber,
    double? estimatedKms,
    double? loadWeightOnLoad,
    double? loadWeightOnUnload,
    double? ratePerTon,
    bool fuelOnClient = false,
    double? fuelLiters,
  }) async {
    final token = TokenStorage.accessToken;
    if (token == null) {
      throw Exception('No autenticado. Por favor inicia sesión.');
    }

    try {
      final payload = {
        'origin': origin,
        if (originDescription != null) 'origin_description': originDescription,
        'destination': destination,
        if (destinationDescription != null)
          'destination_description': destinationDescription,
        'start_date': startDate.toIso8601String().split('T')[0],
        'client_id': clientId,
        'drivers': driverIds,
        'state_id': 'Pendiente', // Todos los viajes nuevos son Pendiente
        if (documentType != null) 'document_type': documentType,
        if (documentNumber != null) 'document_number': documentNumber,
        if (estimatedKms != null) 'estimated_kms': estimatedKms,
        if (loadWeightOnLoad != null) 'load_weight_on_load': loadWeightOnLoad,
        if (loadWeightOnUnload != null)
          'load_weight_on_unload': loadWeightOnUnload,
        if (ratePerTon != null) 'rate_per_ton': ratePerTon,
        'fuel_on_client': fuelOnClient,
        if (fuelLiters != null) 'fuel_liters': fuelLiters,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/trips/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return TripData.fromJson(responseData['trip']);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Datos inválidos: ${errorData['details'] ?? 'Verifique los campos'}',
        );
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para crear viajes');
      } else {
        throw Exception('Error al crear viaje: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todos los dadores de carga
  static Future<List<LoadOwnerData>> getLoadOwners() async {
    try {
      final token = TokenStorage.accessToken;
      final response = await http
          .get(
            Uri.parse('$baseUrl/load-owners/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((item) => LoadOwnerData.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception(
          'Error al obtener dadores de carga: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todos los adelantos
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

  // Obtener un adelanto por ID
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

  // Crear un nuevo adelanto
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

  // Actualizar un adelanto
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

  // Eliminar un adelanto
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
