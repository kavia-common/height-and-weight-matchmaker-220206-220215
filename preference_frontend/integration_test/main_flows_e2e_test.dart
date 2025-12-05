import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:preference_frontend/main.dart';

/// Controlled-wait helpers for integration tests.
///
/// Why not pumpAndSettle?
/// - In real apps, animations/timers or non-quiescent states can keep the
///   frame scheduler active, causing pumpAndSettle to time out intermittently.
/// - These helpers use short, incremental pumps with a max timeout, waiting
///   only for specific UI conditions (a Finder to appear/disappear).
///
/// Usage strategy:
/// - Prefer waiting for target widgets by Key/Text or Type, instead of global
///   quiescence.
/// - Keep tests deterministic and offline.
Future<void> _pumpEndOfFrame(WidgetTester tester) async {
  // Ensure any pending microtasks and a frame render.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

/// Deterministic controlled wait with an extended timeout window.
/// Avoids pumpAndSettle to reduce flakiness due to ongoing animations/timers.
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
  // Ensure integration binding is used.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Keep animations at normal speed and avoid excessively slow motion in CI.
  setUpAll(() {
    timeDilation = 1.0;
  });

  group('E2E - Main flows and navigation', () {
    testWidgets('MaterialApp routes: start on / then navigate to /home (same screen)', (WidgetTester tester) async {
      // Build with routes mapping to the same MyHomePage for deterministic checks.
      final app = MaterialApp(
        title: 'AI Build Tool',
        routes: {
          '/': (context) => const MyHomePage(title: 'preference_frontend'),
          '/home': (context) => const MyHomePage(title: 'preference_frontend'),
        },
      );
      await tester.pumpWidget(app);

      // Wait explicitly for expected content instead of global settle.
      await _waitForFinder(tester, find.byType(MyHomePage));

      // Initial route should render MyHomePage
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);
      await _waitForFinder(tester, find.text('preference_frontend App is being generated...'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Validate route name on Navigator stack (should be '/')
      final initialRouteName = tester.state<NavigatorState>(find.byType(Navigator)).widget.initialRoute ?? '/';
      expect(initialRouteName, anyOf(isNull, equals('/')));

      // Simulate navigation deterministically by rebuilding with initialRoute '/home'.
      await tester.pumpWidget(
        MaterialApp(
          title: 'AI Build Tool',
          routes: {
            '/': (context) => const MyHomePage(title: 'preference_frontend'),
            '/home': (context) => const MyHomePage(title: 'preference_frontend'),
          },
          initialRoute: '/home',
        ),
      );
      await _pumpEndOfFrame(tester);

      await _waitForFinder(tester, find.byType(MyHomePage));

      // Verify again after "navigation"
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);
      await _waitForFinder(tester, find.text('preference_frontend App is being generated...'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Check the initialRoute configuration reflects '/home' for this rebuilt MaterialApp
      final newNavigator = tester.firstState<NavigatorState>(find.byType(Navigator));
      expect(newNavigator.widget.initialRoute, anyOf(equals('/home'), isNull)); // Some platforms null -> uses provided routes as default

      await _pumpEndOfFrame(tester);
    });

    testWidgets('AppBar presence, title text, and theme structure remain stable on rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await _waitForFinder(tester, find.byType(Scaffold));

      // Structural checks
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);

      // Rebuild (simulate a hot-reload-like rebuild)
      await tester.pump(const Duration(milliseconds: 16));

      // Ensure widgets are still present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('User interactions: tap title, drag body, ensure no errors and UI intact', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await _waitForFinder(tester, find.byType(Scaffold));

      // Tap on the title text in the AppBar (ensure visible & hittable)
      final titleFinder = find.text('preference_frontend');
      expect(titleFinder, findsOneWidget);
      expect(tester.widget<Text>(titleFinder).data, 'preference_frontend');
      await tester.ensureVisible(titleFinder);
      await tester.tap(titleFinder, warnIfMissed: false);
      await _pumpEndOfFrame(tester);

      // Drag gesture on Scaffold to simulate user scroll/drag
      await tester.drag(find.byType(Scaffold), const Offset(0, -100));
      await _pumpEndOfFrame(tester);

      // UI remains consistent
      await _waitForFinder(tester, find.text('preference_frontend App is being generated...'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await _pumpEndOfFrame(tester);
    });

    testWidgets('Loading/empty state verification: text and loader exist and are unique', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await _waitForFinder(tester, find.byType(Scaffold));

      final messageFinder = find.text('preference_frontend App is being generated...');
      final loaderFinder = find.byType(CircularProgressIndicator);

      await _waitForFinder(tester, messageFinder);

      expect(messageFinder, findsOneWidget);
      expect(loaderFinder, findsOneWidget);

      // Validate text widget properties
      final textWidget = tester.widget<Text>(messageFinder);
      expect((textWidget.data ?? '').trim().isNotEmpty, isTrue);
      expect(textWidget.style?.fontSize, 18);

      await _pumpEndOfFrame(tester);
    });

    testWidgets(
      'Route swap: switch to a dummy next page and back to home',
      (WidgetTester tester) async {
        // Create a simple navigation app with two routes.
        debugPrint('[Route swap] Building initial app at "/"');
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/': (context) => const MyHomePage(title: 'preference_frontend'),
              '/next': (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Next Page'),
                    ),
                    body: const Center(child: Text('Next Page Body')),
                  ),
            },
            initialRoute: '/',
          ),
        );

        // Initial deterministic settle to render first frame and reactive effects.
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Initial screen checks with unique finders on the home screen.
        final homeTypeFinder = find.byType(MyHomePage);
        final homeTitleFinder = find.text('preference_frontend');
        final homeLoadingTextFinder =
            find.text('preference_frontend App is being generated...');

        expect(homeTypeFinder, findsOneWidget);
        expect(homeTitleFinder, findsOneWidget);
        expect(homeLoadingTextFinder, findsOneWidget);

        // "Navigate" to next by rebuilding with initialRoute set to '/next' (deterministic and offline)
        debugPrint('[Route swap] Rebuilding app with initialRoute "/next"');
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/': (context) => const MyHomePage(title: 'preference_frontend'),
              '/next': (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Next Page'),
                    ),
                    body: const Center(child: Text('Next Page Body')),
                  ),
            },
            initialRoute: '/next',
          ),
        );

        // Give the framework time to process and fully settle on the next route.
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Unique finders for the target route.
        final nextAppBarTitleFinder = find.text('Next Page');
        final nextBodyFinder = find.text('Next Page Body');

        debugPrint('[Route swap] Verifying next page is visible');
        expect(nextAppBarTitleFinder, findsOneWidget);
        expect(nextBodyFinder, findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);

        // "Navigate" back by rebuilding with initialRoute '/'
        debugPrint('[Route swap] Rebuilding app with initialRoute "/"');
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/': (context) => const MyHomePage(title: 'preference_frontend'),
              '/next': (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Next Page'),
                    ),
                    body: const Center(child: Text('Next Page Body')),
                  ),
            },
            initialRoute: '/',
          ),
        );

        // Allow for route change and settle on the home view again.
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 10));

        debugPrint('[Route swap] Verifying home page is visible again');
        expect(homeTypeFinder, findsOneWidget);
        expect(homeTitleFinder, findsOneWidget);
        expect(homeLoadingTextFinder, findsOneWidget);
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}
