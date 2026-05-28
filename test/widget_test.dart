// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:unibridge/main.dart';

void main() {
  testWidgets('UniBridge home page loads', (WidgetTester tester) async {
    await tester.pumpWidget(const UniBridgeApp());

    expect(find.text('Welcome to UniBridge'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Get Started opens role selection', (WidgetTester tester) async {
    await tester.pumpWidget(const UniBridgeApp());

    await tester.ensureVisible(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Role'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Faculty'), findsOneWidget);
    expect(find.text('Organiser'), findsOneWidget);
  });
}
