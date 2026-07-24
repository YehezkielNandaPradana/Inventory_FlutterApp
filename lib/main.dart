import 'package:flutter/material.dart';
import 'package:inventory_app/config/theme.dart';
import 'package:inventory_app/config/routes.dart';
import 'package:inventory_app/screens/auth/login_screen.dart';
import 'package:inventory_app/screens/dashboard/dashboard_screen.dart';
import 'package:inventory_app/screens/barang/barang_list_screen.dart';
import 'package:inventory_app/screens/barang/barang_form_screen.dart';
import 'package:inventory_app/screens/transaksi/stok_masuk_screen.dart';
import 'package:inventory_app/screens/transaksi/kondisi_rusak_screen.dart';
import 'package:inventory_app/screens/rekap/rekap_screen.dart';

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
        AppRoutes.dashboard: (context) => DashboardScreen(),
        AppRoutes.barangList: (context) => const BarangListScreen(),
        AppRoutes.barangForm: (context) => const BarangFormScreen(),
        AppRoutes.stokMasuk: (context) => const StokMasukScreen(),
        AppRoutes.kondisiRusak: (context) => const KondisiRusakScreen(),
        AppRoutes.rekap: (context) => const RekapScreen(),
      },
      home: const LoginScreen(),
    );
  }
}
