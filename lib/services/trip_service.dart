import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:frontend_sgfcp/models/trip_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TripService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET BY DRIVER- Obtener todos los viajes del conductor autenticado
  static Future<List<TripData>> getTrips() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/trips/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<TripData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((trip) => TripData.fromJson(trip))
            .toList(),
        operation: 'obtener viajes',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET ONE - Obtener un viaje específico
  static Future<TripData> getTrip({required int tripId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/trips/$tripId/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<TripData>(
        response,
        (jsonData) => TripData.fromJson(jsonData),
        operation: 'obtener viaje',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
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
      ApiResponseHandler.handleNetworkError(e);
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
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // PUT - Actualizar un viaje
  static Future<TripData> updateTrip({
    required int tripId,
    required Map<String, dynamic> data,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final url = Uri.parse('$baseUrl/trips/$tripId');
      final body = jsonEncode(data);

      final response = await http
          .put(
            url,
            headers: ApiResponseHandler.createHeaders(token),
            body: body,
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<TripData>(
        response,
        (jsonData) => TripData.fromJson(jsonData['trip']),
        operation: 'actualizar viaje',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // POST - Crear un nuevo viaje
  static Future<List<TripData>> createTrip({
    required String origin,
    String? originDescription,
    required String destination,
    String? destinationDescription,
    required DateTime startDate,
    required int clientId,
    required List<int> driverIds,
    double? rate,
    String? documentType,
    String? documentNumber,
    double? estimatedKms,
    double? loadWeightOnLoad,
    double? loadWeightOnUnload,
    bool fuelOnClient = false,
    double? fuelLiters,
    double? clientAdvancePayment,
  }) async {
    final token = TokenStorage.accessToken;

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
        if (rate != null) 'rate': rate,
        if (documentType != null) 'document_type': documentType,
        if (documentNumber != null) 'document_number': documentNumber,
        if (estimatedKms != null) 'estimated_kms': estimatedKms,
        if (loadWeightOnLoad != null) 'load_weight_on_load': loadWeightOnLoad,
        if (loadWeightOnUnload != null)
          'load_weight_on_unload': loadWeightOnUnload,
        'fuel_on_client': fuelOnClient,
        if (fuelLiters != null) 'fuel_liters': fuelLiters,
        if (clientAdvancePayment != null)
          'client_advance_payment': clientAdvancePayment,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/trips/'),
            headers: ApiResponseHandler.createHeaders(token),
            body: jsonEncode(payload),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<TripData>>(
        response,
        (jsonData) => (jsonData['trips'] as List<dynamic>)
            .map((trip) => TripData.fromJson(trip))
            .toList(),
        operation: 'crear viaje',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // DELETE - Eliminar un viaje
  static Future<void> deleteTrip({required int tripId}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/trips/$tripId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) {},
        operation: 'eliminar viaje',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET BY DRIVER - Obtener viajes de un conductor específico
  static Future<List<TripData>> getTripsByDriver({
    required int driverId,
  }) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/trips/driver/$driverId'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<TripData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((trip) => TripData.fromJson(trip))
            .toList(),
        operation: 'obtener viajes del conductor',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  // GET BY STATE - Obtener viajes por estado
  static Future<List<TripData>> getTripsByState({required String state}) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/trips/state/$state'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<TripData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((trip) => TripData.fromJson(trip))
            .toList(),
        operation: 'obtener viajes por estado',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
