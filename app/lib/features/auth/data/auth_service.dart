class AuthService {
  /// Simulación del registro de estudiante mientras se conecta con Django
  Future<bool> register(String identifier, String alias, String password) async {
    // Simulamos 1 segundo de espera de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Aquí más adelante llamaremos al endpoint POST de Django:
    // http://10.0.2.2:8000/api/auth/register/
    return true;
  }

  /// Simulación del inicio de sesión
  Future<bool> login(String identifier, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}