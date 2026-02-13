import 'dart:convert';
import 'package:http/http.dart' as http;

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (details != null) {
      return '$message: $details';
    }
    return message;
  }
}

/// Standardized HTTP response handler
class ApiResponseHandler {
  static const Duration defaultTimeout = Duration(seconds: 10);

  static String? _normalizeDetails(dynamic details) {
    if (details == null) return null;
    if (details is String) return details;
    if (details is List) {
      final parts = details
          .map((item) => _normalizeDetails(item))
          .where((item) => item != null && item!.trim().isNotEmpty)
          .cast<String>()
          .toList();
      return parts.isEmpty ? null : parts.join(' | ');
    }
    if (details is Map) {
      final parts = <String>[];
      details.forEach((key, value) {
        final normalized = _normalizeDetails(value);
        if (normalized != null && normalized.trim().isNotEmpty) {
          parts.add('$key: $normalized');
        }
      });
      return parts.isEmpty ? null : parts.join(' | ');
    }
    return details.toString();
  }

  /// Handle HTTP response and throw standardized exceptions
  static T handleResponse<T>(
    http.Response response,
    T Function(dynamic) successParser, {
    String operation = 'operation',
  }) {
    try {
      switch (response.statusCode) {
        case 200:
        case 201:
          final jsonData = jsonDecode(response.body);
          return successParser(jsonData);

        case 400:
          final errorData = jsonDecode(response.body);
          throw ApiException(
            'Datos inválidos',
            statusCode: 400,
            details: _normalizeDetails(
                  errorData['details'] ?? errorData['error'],
                ) ??
                'Verifique los campos',
          );

        case 401:
          throw ApiException(
            'No autorizado. Por favor inicia sesión nuevamente.',
            statusCode: 401,
          );

        case 403:
          throw ApiException(
            'No tienes permisos para realizar esta acción.',
            statusCode: 403,
          );

        case 404:
          throw ApiException(
            'Recurso no encontrado.',
            statusCode: 404,
          );

        case 409:
          final errorData = jsonDecode(response.body);
          throw ApiException(
            'Conflicto de datos',
            statusCode: 409,
            details: _normalizeDetails(errorData['error']) ?? 'El recurso ya existe',
          );

        case 500:
          throw ApiException(
            'Error interno del servidor. Inténtalo más tarde.',
            statusCode: 500,
          );

        default:
          throw ApiException(
            'Error en $operation: ${response.statusCode}',
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Error al procesar la respuesta del servidor',
        details: e.toString(),
      );
    }
  }

  /// Check authentication and throw if not authenticated
  static void checkAuthentication(String? token) {
    if (token == null || token.isEmpty) {
      throw ApiException('No autenticado. Por favor inicia sesión.');
    }
  }

  /// Create standardized headers with authentication
  static Map<String, String> createHeaders(String? token, {bool includeContentType = true}) {
    checkAuthentication(token);

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
    };

    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  /// Handle network errors and timeouts
  static Never handleNetworkError(Object error) {
    if (error is ApiException) {
      throw error;
    }

    if (error.toString().contains('TimeoutException')) {
      throw ApiException('Conexión agotada. Verifica tu conexión a internet e inténtalo nuevamente.');
    }

    throw ApiException(
      'Error de conexión. Verifica tu conexión a internet.',
      details: error.toString(),
    );
  }
}