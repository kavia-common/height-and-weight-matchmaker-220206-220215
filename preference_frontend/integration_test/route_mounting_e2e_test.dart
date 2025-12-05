import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:preference_frontend/main.dart';

/// Controlled-wait helpers mirroring main_flows_e2e_test.dart to keep tests
/// deterministic by avoiding pumpAndSettle.
Future<void> _pumpUntil(WidgetTester tester, bool Function() condition,
    {Duration timeout = const Duration(seconds: 8),
    Duration step = const Duration(milliseconds: 100)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (condition()) return;
    await tester.pump(step);
  }
  if (!condition()) {
    throw TestFailure('Condition not met within ${timeout.inMilliseconds}ms');
  }
}

Future<void> _waitForFinder(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 8),
    Duration step = const Duration(milliseconds: 100)}) async {
  await _pumpUntil(tester, () => tester.any(finder),
      timeout: timeout, step: step);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    timeDilation = 1.0;
  });

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
      await _waitForFinder(tester, find.byType(MyHomePage));

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
      await _waitForFinder(tester, find.byType(MyHomePage));

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Rebuild stability: keeps key widgets after multiple pumps', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await _waitForFinder(tester, find.byType(Scaffold));

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
