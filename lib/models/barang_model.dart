import 'package:flutter/material.dart';
import '../config/colors.dart';

class Barang {
  final String id;
  final String nama;
  final String kategori;
  final int stok;
  final int stokMinimum;
  final String? gambar;

  Barang({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.stok,
    required this.stokMinimum,
    this.gambar,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    final kategori = json['kategori'] is Map<String, dynamic>
        ? json['kategori'] as Map<String, dynamic>
        : null;

    return Barang(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      kategori: kategori != null
          ? (kategori['nama']?.toString() ?? '')
          : (json['kategori']?.toString() ?? ''),
      stok: json['stok'] is int
          ? json['stok']
          : int.tryParse(json['stok']?.toString() ?? '0') ?? 0,
      stokMinimum: json['stok_minimum'] is int
          ? json['stok_minimum']
          : int.tryParse(json['stok_minimum']?.toString() ?? '0') ?? 0,
      gambar: json['gambar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'stok': stok,
      'stok_minimum': stokMinimum,
      'gambar': gambar,
    };
  }

  String get status {
    if (stok == 0) return 'Habis';
    if (stok <= stokMinimum) return 'Menipis';
    return 'Aman';
  }

  Color get statusColor {
    switch (status) {
      case 'Aman':
        return AppColors.successGreen;
      case 'Menipis':
        return AppColors.warningAmber;
      case 'Habis':
        return AppColors.dangerRed;
      default:
        return AppColors.slateText;
    }
  }

  double get persentaseStok {
    if (stokMinimum == 0) return 1.0;
    return (stok / (stokMinimum * 2)).clamp(0.0, 1.0);
  }
}
