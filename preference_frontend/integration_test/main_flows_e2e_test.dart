import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:preference_frontend/main.dart';

// This suite expands coverage of realistic end-to-end flows that are safe offline.
// We avoid any networking and focus on navigating simple routes, verifying primary
// widgets, and ensuring basic interactions do not crash the app.
void main() {
  // Initialize the integration test binding to run with real engine frames.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E - Main flows and navigation', () {
    testWidgets('MaterialApp routes: start on / then navigate to /home (same screen)', (WidgetTester tester) async {
      // Create a basic routes table that maps to the same MyHomePage for navigation verification.
      await tester.pumpWidget(
        MaterialApp(
          title: 'AI Build Tool',
          routes: {
            '/': (context) => const MyHomePage(title: 'preference_frontend'),
            '/home': (context) => const MyHomePage(title: 'preference_frontend'),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Initial route should render MyHomePage
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Navigate to '/home' and ensure UI remains consistent
      // Use Navigator to pushNamed - wrap call inside runAsync to avoid "context across async gap"
      await tester.runAsync(() async {
        // We cannot access BuildContext directly here. Instead, rebuild with initialRoute to simulate navigation.
      });

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

      await tester.pumpAndSettle();

      // Verify again after "navigation"
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AppBar presence, title text, and theme structure remain stable on rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // Tap on the title text in the AppBar
      final titleFinder = find.text('preference_frontend');
      expect(titleFinder, findsOneWidget);
      await tester.tap(titleFinder);
      await tester.pump();

      // Drag gesture on Scaffold to simulate user scroll/drag
      await tester.drag(find.byType(Scaffold), const Offset(0, -100));
      await tester.pump();

      // UI remains consistent
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Loading/empty state verification: text and loader exist and are unique', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final messageFinder = find.text('preference_frontend App is being generated...');
      final loaderFinder = find.byType(CircularProgressIndicator);

      expect(messageFinder, findsOneWidget);
      expect(loaderFinder, findsOneWidget);

      // Validate text widget properties
      final textWidget = tester.widget<Text>(messageFinder);
      expect((textWidget.data ?? '').trim().isNotEmpty, isTrue);
      expect(textWidget.style?.fontSize, 18);
    });

    testWidgets('Route swap: switch to a dummy next page and back to home', (WidgetTester tester) async {
      // Create a simple navigation app with two routes.
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

      await tester.pumpAndSettle();

      // Initial screen checks
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);

      // "Navigate" to next by rebuilding with initialRoute set to '/next' (deterministic and offline)
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
      await tester.pumpAndSettle();

      // On next page
      expect(find.text('Next Page'), findsOneWidget);
      expect(find.text('Next Page Body'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // "Navigate" back by rebuilding with initialRoute '/'
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
      await tester.pumpAndSettle();

      // Back on home
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
    });
  });
}
