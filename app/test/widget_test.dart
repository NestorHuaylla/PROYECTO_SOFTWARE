import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';
import 'package:app/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('KadirApp carga SplashScreen al iniciar', (WidgetTester tester) async {
    await tester.pumpWidget(const KadirApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}