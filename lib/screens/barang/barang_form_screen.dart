import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/barang_model.dart';
import '../../models/kategori_model.dart';
import '../../services/inventory_api.dart';

class BarangFormScreen extends StatefulWidget {
  const BarangFormScreen({super.key});

  @override
  State<BarangFormScreen> createState() => _BarangFormScreenState();
}

class _BarangFormScreenState extends State<BarangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _stokController = TextEditingController();
  final _stokMinController = TextEditingController();
  final _gambarController = TextEditingController();

  final InventoryApi _api = InventoryApi();
  bool _isLoading = false;
  List<Kategori> _kategoriList = [];
  bool _isLoadingKategori = true;

  @override
  void initState() {
    super.initState();
    _loadKategori();j
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kategoriController.dispose();
    _stokController.dispose();
    _stokMinController.dispose();
    _gambarController.dispose();
    super.dispose();
  }

  Future<void> _loadKategori() async {
    try {
      final list = await _api.fetchKategoriList();
      if (!mounted) return;
      setState(() {
        _kategoriList = list;
        _isLoadingKategori = false;
      });
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingKategori = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final stok = int.tryParse(_stokController.text.trim()) ?? 0;
      final stokMin = int.tryParse(_stokMinController.text.trim()) ?? 0;

      await _api.createBarang(
        nama: _namaController.text.trim(),
        kategori: _kategoriController.text.trim(),
        stok: stok,
        stokMinimum: stokMin,
        gambar: _gambarController.text.trim().isEmpty
            ? null
            : _gambarController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil ditambahkan'),
          backgroundColor: AppColors.successGreen,
        ),
      );

      Navigator.pop(context, true);
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.navyText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tambah Barang',
          style: AppTextStyles.h2.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing24,
              vertical: AppConstants.spacing16,
            ),
            children: [
              const SizedBox(height: AppConstants.spacing8),
              Text('Nama Barang', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Kertas A4 80gsm',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama barang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Kategori', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              _isLoadingKategori
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        hintText: 'Pilih kategori',
                      ),
                      value: _kategoriController.text.isEmpty
                          ? null
                          : _kategoriController.text,
                      items: _kategoriList
                          .map(
                            (k) => DropdownMenuItem(
                              value: k.nama,
                              child: Text(k.nama),
                            ),
                          )
                          .toList()
                          .cast<DropdownMenuItem<String>>(),
                      onChanged: (value) {
                        if (value != null) {
                          _kategoriController.text = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kategori tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 20),
              Text('Jumlah Stok', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 100',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Stok Minimum', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              TextFormField(
                controller: _stokMinController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 10',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok minimum tidak boleh kosong';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('URL Gambar (Opsional)', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gambarController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'https://example.com/gambar.jpg',
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.pureWhite,
                            ),
                          ),
                        )
                      : const Text(
                          'Simpan Barang',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}
