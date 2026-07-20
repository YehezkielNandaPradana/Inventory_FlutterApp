import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/main.dart';
import 'package:inventory_app/screens/auth/login_screen.dart';
import 'package:inventory_app/screens/dashboard/dashboard_screen.dart';

void main() {
  testWidgets('Login and dashboard navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen is showing.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);

    // Enter username and password
    await tester.enterText(find.byType(TextFormField).first, 'admin');
    await tester.enterText(find.byType(TextFormField).last, 'admin123');

    // Tap the log in button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start navigation delay
    await tester.pump(const Duration(milliseconds: 800)); // Complete the Future.delayed
    await tester.pumpAndSettle(); // Settle navigation transition

    // Verify that it has navigated to the DashboardScreen.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Halo, Admin'), findsOneWidget);
  });
}
