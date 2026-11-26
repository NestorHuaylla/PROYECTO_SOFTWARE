import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  /// URL pública de tu backend Django en AWS EC2
  static const String baseUrl = 'http://3.18.3.0:8000/api';

  static String? accessToken;
  static String? refreshToken;
  static Map<String, dynamic>? currentUser;

  /// POST /api/auth/register/ -> Crea Usuario + PerfilEstudiante en PostgreSQL
  Future<bool> register(String identifier, String alias, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register/'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'identificador': identifier,
              'alias': alias,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 12));

      final data = _decodificarRespuesta(response);
      if (response.statusCode == 201) {
        _guardarSesion(data);
        return true;
      }

      throw AuthException(
        _extraerError(data, 'No se pudo registrar la cuenta (${response.statusCode}).'),
      );
    } on TimeoutException {
      throw const AuthException('Tiempo agotado al conectar con el servidor AWS.');
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Sin conexión con el servidor AWS (3.18.3.0:8000).');
    }
  }

  /// POST /api/auth/login/ -> Compatible con onBackendAuth de LoginScreen
  Future<bool> login(String identifier, String password) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/login/'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'identificador': identifier,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final data = _decodificarRespuesta(response);
      _guardarSesion(data);
      return true;
    }

    if (response.statusCode == 400 ||
        response.statusCode == 401 ||
        response.statusCode == 403) {
      return false;
    }

    throw AuthException('Error del servidor (${response.statusCode}).');
  }

  /// GET /api/users/me/ -> Obtiene el perfil actualizado usando el token JWT
  Future<Map<String, dynamic>?> fetchMe() async {
    final token = accessToken;
    if (token == null) return null;

    final response = await http
        .get(
          Uri.parse('$baseUrl/users/me/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      currentUser = _decodificarRespuesta(response);

  
      return currentUser;
    }
    return null;
  }

  static void logout() {
    accessToken = null;
    refreshToken = null;
    currentUser = null;
  }

  void _guardarSesion(Map<String, dynamic> data) {
    final tokens = data['tokens'];
    if (tokens is Map<String, dynamic>) {
      accessToken = tokens['access'] as String?;
      refreshToken = tokens['refresh'] as String?;
    }
    final usuario = data['usuario'];
    if (usuario is Map<String, dynamic>) {
      currentUser = usuario;
    }
  }

  Map<String, dynamic> _decodificarRespuesta(http.Response response) {
  if (response.bodyBytes.isEmpty) return <String, dynamic>{};
  final texto = utf8.decode(response.bodyBytes, allowMalformed: true);
  final decoded = jsonDecode(texto);
  return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
}

  String _extraerError(Map<String, dynamic> data, String porDefecto) {
    if (data['error'] is String) return data['error'] as String;
    if (data['detail'] is String) return data['detail'] as String;
    for (final valor in data.values) {
      if (valor is List && valor.isNotEmpty) return valor.first.toString();
      if (valor is String && valor.isNotEmpty) return valor;
    }
    return porDefecto;
  }
}