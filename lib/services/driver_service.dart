import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:frontend_sgfcp/models/driver_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los choferes
  static Future<List<DriverData>> getDrivers() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/drivers/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<DriverData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((driver) => DriverData.fromJson(driver))
            .toList(),
        operation: 'obtener choferes',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}