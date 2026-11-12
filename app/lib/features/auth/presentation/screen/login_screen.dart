import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  /// Callback opcional cuando el inicio de sesión es exitoso (ej. para navegar al Home)
  final VoidCallback? onLoginSuccess;

  /// Función opcional para conectar la validación al backend (Django REST API)
  final Future<bool> Function(String usuario, String contrasena)? onBackendAuth;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onBackendAuth,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String _usuarioRegistrado = "estudiante01";
  final String _contrasenaRegistrada = "123456";

  String _mensajeResultado = "";
  Color _colorMensaje = Colors.transparent;
  bool _cargando = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Punto único listo para conectar con el Backend (Django)
  Future<bool> _validarCredenciales(String usuario, String contrasena) async {
    if (widget.onBackendAuth != null) {
      return await widget.onBackendAuth!(usuario, contrasena);
    }

    // =========================================================================
    // CUANDO CONECTEN EL BACKEND DJANGO, AQUÍ VA EL POST:
    // final response = await http.post(
    //   Uri.parse('http://10.0.2.2:8000/api/auth/login/'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'username': usuario, 'password': contrasena}),
    // );
    // return response.statusCode == 200;
    // =========================================================================

    // Validación original de tu compañero:
    return usuario == _usuarioRegistrado && contrasena == _contrasenaRegistrada;
  }

  Future<void> _procesarInicioSesion() async {
    String usuarioIngresado = _userController.text.trim();
    String contrasenaIngresada = _passwordController.text;

    if (usuarioIngresado.isEmpty || contrasenaIngresada.isEmpty) {
      setState(() {
        _mensajeResultado = "Error: Los campos no pueden estar vacíos.";
        _colorMensaje = Colors.orange;
      });
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final bool esValido = await _validarCredenciales(
        usuarioIngresado,
        contrasenaIngresada,
      );

      if (!mounted) return;

      if (esValido) {
        setState(() {
          _cargando = false;
          _mensajeResultado = "Inicio de sesión exitoso";
          _colorMensaje = Colors.green;
        });

        if (widget.onLoginSuccess != null) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) widget.onLoginSuccess!();
          });
        }
      } else {
        setState(() {
          _cargando = false;
          _mensajeResultado = "Usuario o contraseña incorrecta";
          _colorMensaje = Colors.red;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _mensajeResultado = "Error al conectar con el servidor.";
        _colorMensaje = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión de Estudiantes'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _cargando ? null : _procesarInicioSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    _cargando ? 'Validando...' : 'Iniciar Sesión',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
                if (_mensajeResultado.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _colorMensaje.withAlpha(38),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _colorMensaje, width: 1.5),
                    ),
                    child: Text(
                      _mensajeResultado,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _colorMensaje == Colors.orange
                            ? Colors.deepOrange
                            : _colorMensaje,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}