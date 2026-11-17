import 'package:flutter/material.dart';

import '../../../progress/data/local_progress_repository.dart';
import '../../../progress/domain/models/student_progress.dart';
import '../../../progress/domain/services/progress_service.dart';
import 'exercise_demo_screen.dart';

class LoginDemoScreen extends StatefulWidget {
  const LoginDemoScreen({super.key});

  @override
  State<LoginDemoScreen> createState() => _LoginDemoScreenState();
}

class _LoginDemoScreenState extends State<LoginDemoScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const String _registeredUser = 'estudiante01';
  static const String _registeredPassword = '123456';

  String _resultMessage = '';
  Color _messageColor = Colors.transparent;

  void _signIn() {
    final username = _userController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _resultMessage = 'Error: Los campos no pueden estar vacíos.';
        _messageColor = Colors.orange;
      });
      return;
    }

    if (username != _registeredUser || password != _registeredPassword) {
      setState(() {
        _resultMessage = 'Usuario o contraseña incorrecta.';
        _messageColor = Colors.red;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DemoHomeScreen(username: username),
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo: inicio de sesión'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
                    labelText: 'Usuario',
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
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
                if (_resultMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _messageColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _messageColor, width: 1.5),
                    ),
                    child: Text(
                      _resultMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _messageColor == Colors.orange
                            ? Colors.deepOrange
                            : _messageColor,
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

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key, required this.username});

  final String username;

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  late final ProgressService _progressService = ProgressService(
    repository: LocalProgressRepository(),
  );

  void _signOut(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginDemoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de la demo'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 70, color: Colors.blue),
            const SizedBox(height: 16),
            Text('Bienvenido, ${widget.username}'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DemoProfileScreen(
                      username: widget.username,
                      progressService: _progressService,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.account_circle),
              label: const Text('Consultar perfil'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDemoScreen(
                      progressService: _progressService,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.quiz_outlined),
              label: const Text('Practicar ejercicio'),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoProfileScreen extends StatefulWidget {
  const DemoProfileScreen({
    super.key,
    required this.username,
    required this.progressService,
  });

  final String username;
  final ProgressService progressService;

  @override
  State<DemoProfileScreen> createState() => _DemoProfileScreenState();
}

class _DemoProfileScreenState extends State<DemoProfileScreen> {
  late final Future<StudentProgress> _progress =
      widget.progressService.getProgress();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<StudentProgress>(
              future: _progress,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('No se pudo cargar el progreso.');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 45),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.username,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(height: 30),
                    _profileData(Icons.map, 'Zona', 'Zona Norte'),
                    _profileData(Icons.stairs, 'Nivel', '2'),
                    _profileData(
                      Icons.star,
                      'Puntos',
                      '${snapshot.data!.totalPoints}',
                    ),
                    _profileData(
                      Icons.assignment_turned_in,
                      'Intentos',
                      '${snapshot.data!.attempts.length}',
                    ),
                    _profileData(
                      Icons.local_fire_department,
                      'Racha',
                      '3 días',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileData(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value),
    );
  }
}
