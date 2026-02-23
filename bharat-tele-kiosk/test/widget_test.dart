// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tele_kiosk/screens/login_page.dart';

void main() {
  testWidgets('Login validation test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Check for login elements
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Test invalid login
    await tester.enterText(find.byType(TextField).first, 'wronguser');
    await tester.enterText(find.byType(TextField).last, 'wrongpass');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
