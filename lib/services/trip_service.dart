import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TripService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET BY DRIVER- Obtener todos los viajes del conductor autenticado
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

  // GET ONE - Obtener un viaje específico
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

  // GET BY MONTH - Obtener viajes filtrados por mes
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

  // GET CURRENT -Obtener el viaje actual (estado "En curso")
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

  // GET NEXT - Obtener el próximo viaje (estado "Pendiente", el más próximo)
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

  // PUT - Actualizar estado de un viaje
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

  // POST - Crear un nuevo viaje
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
}