import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:preference_frontend/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E - Route mounting and rebuilds', () {
    testWidgets('Mounts MyHomePage under multiple initial routes consistently', (WidgetTester tester) async {
      // First mount with root route
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => const MyHomePage(title: 'preference_frontend'),
          },
          initialRoute: '/',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Rebuild with an explicit '/home' mapping to the same widget
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/home': (context) => const MyHomePage(title: 'preference_frontend'),
          },
          initialRoute: '/home',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Rebuild stability: keeps key widgets after multiple pumps', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Initial expectations
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Multiple frames
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));

      // Still intact
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
    });
  });
}
