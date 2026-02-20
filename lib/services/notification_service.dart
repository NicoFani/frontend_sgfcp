import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_sgfcp/models/notification_data.dart';
import 'package:frontend_sgfcp/services/api_response_handler.dart';
import 'package:frontend_sgfcp/services/token_storage.dart';

class NotificationService {
  static String get baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:5000';

  static Future<List<NotificationData>> getNotifications() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/notifications/'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<List<NotificationData>>(
        response,
        (jsonData) => (jsonData as List<dynamic>)
            .map((item) => NotificationData.fromJson(item))
            .toList(),
        operation: 'obtener notificaciones',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  static Future<int> getUnreadCount() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/notifications/unread-count'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      return ApiResponseHandler.handleResponse<int>(
        response,
        (jsonData) => (jsonData['count'] as num).toInt(),
        operation: 'obtener conteo de notificaciones',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/notifications/$notificationId/read'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) => null,
        operation: 'marcar notificación como leída',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }

  static Future<void> markAllAsRead() async {
    final token = TokenStorage.accessToken;

    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/notifications/read-all'),
            headers: ApiResponseHandler.createHeaders(token),
          )
          .timeout(ApiResponseHandler.defaultTimeout);

      ApiResponseHandler.handleResponse<void>(
        response,
        (_) => null,
        operation: 'marcar notificaciones como leídas',
      );
    } catch (e) {
      ApiResponseHandler.handleNetworkError(e);
    }
  }
}
