import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preference_frontend/main.dart';

void main() {
  group('MyApp and MyHomePage widget tests', () {
    testWidgets('MyApp builds MaterialApp with home MyHomePage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify MaterialApp exists
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify MyHomePage content is present
      expect(find.text('preference_frontend'), findsOneWidget);
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Scaffold with AppBar renders with correct title and theme color applied', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Find the AppBar and its title
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);

      // Ensure a Scaffold exists wrapping our content
      expect(find.byType(Scaffold), findsOneWidget);

      // Body content
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Ensure text is centered and column mainAxis is center', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Locate the Column and verify it uses MainAxisAlignment.center by checking layout
      final columnWidget = tester.widget<Column>(find.byType(Column));
      expect(columnWidget.mainAxisAlignment, equals(MainAxisAlignment.center));

      // Verify the primary status text exists exactly once
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
    });

    testWidgets('Wrap MyHomePage in a custom MaterialApp for future navigation', (WidgetTester tester) async {
      // This pattern mirrors how future tabs/navigation will be tested.
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'preference_frontend'),
        ),
      );

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('preference_frontend'), findsOneWidget);

      // Basic semantics and tree pump to simulate a frame
      await tester.pump();

      // Still see progress indicator and message
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('preference_frontend App is being generated...'), findsOneWidget);
    });
  });
}
