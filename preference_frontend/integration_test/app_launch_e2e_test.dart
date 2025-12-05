import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:preference_frontend/main.dart';

/// Helper waits to avoid pumpAndSettle timeouts.
/// We prefer explicit waits for target widgets and controlled pump loops.
Future<void> _pumpEndOfFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() condition,
    {Duration timeout = const Duration(seconds: 15),
    Duration step = const Duration(milliseconds: 100)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (condition()) {
      await _pumpEndOfFrame(tester);
      return;
    }
    await tester.pump(step);
  }
  if (!condition()) {
    throw TestFailure('Condition not met within ${timeout.inMilliseconds}ms');
  }
  await _pumpEndOfFrame(tester);
}

Future<void> _waitForFinder(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 15),
    Duration step = const Duration(milliseconds: 100)}) async {
  await _pumpUntil(tester, () => tester.any(finder),
      timeout: timeout, step: step);
}

void main() {
  // Initialize the integration test binding so tests run with real engine frames.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    timeDilation = 1.0;
  });

  group('E2E - App launch and main screen', () {
    testWidgets('Launches MyApp and renders main screen with title and loader', (WidgetTester tester) async {
      // Pump the full app like a real user would experience on launch.
      await tester.pumpWidget(const MyApp());

      // Wait for primary scaffold to appear instead of global settle.
      await _waitForFinder(tester, find.byType(Scaffold));

      // Verify that the MaterialApp and Scaffold tree are present.
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // AppBar with correct title should be visible.
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);

      // Main body content should include the message and a progress indicator.
      await _waitForFinder(tester, find.text('preference_frontend App is being generated...'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await _pumpEndOfFrame(tester);

      // Ensure no network/backend actions are triggered; this app currently shows a static screen.
      // If future network clients are added, they must be mocked or disabled for integration tests.
    });

    testWidgets('Basic user flow readiness: can scroll and tap safely without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await _waitForFinder(tester, find.byType(Scaffold));

      // Try a simple tap on the AppBar title area to ensure no exceptions from gestures.
      final titleFinder = find.text('preference_frontend');
      expect(titleFinder, findsOneWidget);
      await tester.ensureVisible(titleFinder);
      await tester.tap(titleFinder, warnIfMissed: false);
      await _pumpEndOfFrame(tester);

      // Attempt a scroll gesture on body to ensure view is scroll-safe (even if not scrollable).
      await tester.drag(find.byType(Scaffold), const Offset(0, -50));
      await _pumpEndOfFrame(tester);

      // Verify UI still intact
      await _waitForFinder(tester, find.text('preference_frontend App is being generated...'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await _pumpEndOfFrame(tester);
    });
  });
}
