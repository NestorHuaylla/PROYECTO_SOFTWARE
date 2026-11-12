import 'package:flutter/material.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KadirApp());
}

class KadirApp extends StatelessWidget {
  const KadirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KADIR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}