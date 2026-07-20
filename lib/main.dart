import 'package:flutter/material.dart';
import 'package:inventory_app/config/theme.dart';
import 'package:inventory_app/config/routes.dart';
import 'package:inventory_app/screens/auth/login_screen.dart';
import 'package:inventory_app/screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      theme: AppTheme.light,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
      },
      home: const LoginScreen(),
    );
  }
}
