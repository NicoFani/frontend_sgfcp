import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:frontend_sgfcp/models/load_owner_data.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoadOwnerService {
  static String get baseUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  // GET ALL - Obtener todos los dadores de carga
  static Future<List<LoadOwnerData>> getLoadOwners() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/load-owners/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<LoadOwnerData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((item) => LoadOwnerData.fromJson(item as Map<String, dynamic>))
            .toList(),
        operation: 'obtener dadores de carga',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}