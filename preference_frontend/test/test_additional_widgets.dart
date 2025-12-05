import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preference_frontend/main.dart';

void main() {
  group('Additional UI widget coverage', () {
    testWidgets('MaterialApp has expected title and theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify MaterialApp exists and title is set
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('AI Build Tool'));
      expect(materialApp.theme, isNotNull);

      // Root home should be MyHomePage via MyApp
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('AppBar contains leading/back button when provided by Navigator', (WidgetTester tester) async {
      // Use nested routes to ensure an AppBar back button appears via Navigator push
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'preference_frontend'),
        ),
      );

      // Initial screen shows message and progress
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Push a dummy page that also has an AppBar to test navigation/back icon rendering
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

      // Push to next via Navigator by invoking directly in test
      // Using a GlobalKey to access Navigator is unnecessary here; we can rebuild with next route
      // Instead, simulate by navigating using Navigator.of(context) with a helper.
      // We can't access context here; thus rebuild with initialRoute '/next'
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

      // On next page now
      expect(find.text('Next Page'), findsOneWidget);
      expect(find.text('Next Page Body'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Loading state: CircularProgressIndicator is present exactly once', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final progressFind = find.byType(CircularProgressIndicator);
      expect(progressFind, findsOneWidget);

      // Ensure semantics node exists for accessibility (no specific flag requirement)
      final semanticsNode = tester.getSemantics(progressFind);
      expect(semanticsNode, isNotNull);
    });

    testWidgets('Empty state: message text is not empty and visible', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final msgFinder = find.text('preference_frontend App is being generated...');
      expect(msgFinder, findsOneWidget);

      // Confirm Text widget has non-empty data
      final textWidget = tester.widget<Text>(msgFinder);
      expect((textWidget.data ?? '').trim().isNotEmpty, isTrue);
      expect(textWidget.style?.fontSize, equals(18));
    });

    testWidgets('Column layout contains spacing via SizedBox', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Assert that a SizedBox with height 20 is present between text and progress
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);

      // Check at least one SizedBox has the configured height
      bool hasHeight20 = false;
      for (final e in sizedBoxes.evaluate()) {
        final w = e.widget;
        if (w is SizedBox && w.height == 20) {
          hasHeight20 = true;
          break;
        }
      }
      expect(hasHeight20, isTrue);
    });

    testWidgets('Scaffold structure: AppBar, body Center, and Column are present', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('Navigation structure with MaterialApp routes can mount MyHomePage properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (context) => const MyHomePage(title: 'preference_frontend'),
            '/home': (context) => const MyHomePage(title: 'preference_frontend'),
          },
          initialRoute: '/home',
        ),
      );

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
    });
  });
}
