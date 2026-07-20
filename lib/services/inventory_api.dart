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
}
