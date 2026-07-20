import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/barang_model.dart';
import '../models/kategori_model.dart';

class InventoryApi {
  final String baseUrl = AppConstants.baseUrl;

  Future<List<Barang>> fetchBarangList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/barangs'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data barang (${response.statusCode})');
    }

    final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
    return list.map((item) => Barang.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Kategori>> fetchKategoriList() async {
    final response = await http.get(
      Uri.parse('$baseUrl/kategoris'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data kategori (${response.statusCode})');
    }

    final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
    return list.map((item) => Kategori.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Barang> createBarang({
    required String nama,
    required String kategori,
    required int stok,
    required int stokMinimum,
    String? gambar,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/barangs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nama': nama,
        'kategori': kategori,
        'stok': stok,
        'stok_minimum': stokMinimum,
        if (gambar != null) 'gambar': gambar,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal menambahkan barang (${response.statusCode})');
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;
    return Barang.fromJson(json);
  }
}
