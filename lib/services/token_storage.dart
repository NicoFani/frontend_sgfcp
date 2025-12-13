/// Servicio simple para almacenar el token en memoria
/// TODO: Implementar almacenamiento seguro con flutter_secure_storage para producción
class TokenStorage {
  static String? _accessToken;
  static String? _refreshToken;
  static Map<String, dynamic>? _user;

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static Map<String, dynamic>? get user => _user;

  static bool get isAuthenticated => _accessToken != null;

  static void saveTokens({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _user = user;
  }

  static void clear() {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
  }
}
