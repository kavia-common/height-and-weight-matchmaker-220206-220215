import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:preference_frontend/main.dart';

void main() {
  // Initialize the integration test binding so tests run with real engine frames.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E - App launch and main screen', () {
    testWidgets('Launches MyApp and renders main screen with title and loader', (WidgetTester tester) async {
      // Pump the full app like a real user would experience on launch.
      await tester.pumpWidget(const MyApp());

      // Let the first frame settle.
      await tester.pumpAndSettle();

      // Verify that the MaterialApp and Scaffold tree are present.
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // AppBar with correct title should be visible.
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);

      // Main body content should include the message and a progress indicator.
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Ensure no network/backend actions are triggered; this app currently shows a static screen.
      // If future network clients are added, they must be mocked or disabled for integration tests.
    });

    testWidgets('Basic user flow readiness: can scroll and tap safely without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Try a simple tap on the AppBar title area to ensure no exceptions from gestures.
      final titleFinder = find.text('preference_frontend');
      expect(titleFinder, findsOneWidget);
      await tester.tap(titleFinder);
      await tester.pump();

      // Attempt a scroll gesture on body to ensure view is scroll-safe (even if not scrollable).
      await tester.drag(find.byType(Scaffold), const Offset(0, -50));
      await tester.pump();

      // Verify UI still intact
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
