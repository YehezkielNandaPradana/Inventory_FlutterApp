import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/barang_model.dart';
import '../../services/inventory_api.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';

class KondisiRusakScreen extends StatefulWidget {
  const KondisiRusakScreen({super.key});

  @override
  State<KondisiRusakScreen> createState() => _KondisiRusakScreenState();
}

class _KondisiRusakScreenState extends State<KondisiRusakScreen> {
  final InventoryApi _api = InventoryApi();
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();

  int _selectedNavIndex = 3;
  bool _isLoading = false;
  bool _isLoadingBarang = true;
  List<Barang> _barangList = [];
  Barang? _selectedBarang;

  @override
  void initState() {
    super.initState();
    _loadBarang();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _loadBarang() async {
    try {
      final list = await _api.fetchBarangList();
      if (!mounted) return;
      setState(() {
        _barangList = list;
        _isLoadingBarang = false;
      });
    } on Exception catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingBarang = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBarang == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih barang terlebih dahulu'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    final jumlah = int.tryParse(_jumlahController.text.trim()) ?? 0;
    if (jumlah > _selectedBarang!.stok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah rusak ($jumlah) melebihi stok tersedia (${_selectedBarang!.stok})',
          ),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _api.createTransaksi(
        barangId: _selectedBarang!.id,
        jenis: 'rusak',
        jumlah: jumlah,
        keterangan: _keteranganController.text.trim().isEmpty
            ? null
            : _keteranganController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.pureWhite, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$jumlah unit ${_selectedBarang!.nama} dicatat rusak',
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

      _jumlahController.clear();
      _keteranganController.clear();
      setState(() => _selectedBarang = null);
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

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    setState(() => _selectedNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.barangList);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.stokMasuk);
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: EdgeInsets.only(
                left: AppConstants.spacing24,
                right: AppConstants.spacing24,
                top: AppConstants.spacing16,
                bottom:
                    AppConstants.spacing32 + MediaQuery.of(context).padding.bottom,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.pureWhite,
      elevation: 0,
      floating: true,
      snap: true,
      toolbarHeight: 64,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: AppConstants.spacing24,
          bottom: 16,
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.dangerRed, AppColors.dangerRed.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.pureWhite,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text('Kondisi Rusak', style: AppTextStyles.h1.copyWith(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pureWhite,
            AppColors.pureWhite.withOpacity(0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.dangerRed.withOpacity(0.15),
                  AppColors.dangerRed.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.dangerRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pencatatan Kerusakan',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Catat barang yang mengalami kerusakan',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBarangField(),
            const SizedBox(height: 20),
            _buildField(
              label: 'Jumlah Rusak',
              hint: 'Contoh: 5',
              icon: Icons.warning_amber_rounded,
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }
                final qty = int.tryParse(value.trim());
                if (qty == null || qty <= 0) {
                  return 'Masukkan angka yang valid';
                }
                if (_selectedBarang != null && qty > _selectedBarang!.stok) {
                  return 'Melebihi stok tersedia (${_selectedBarang!.stok})';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildField(
              label: 'Penyebab / Keterangan',
              hint: 'Contoh: Kaca pecah, baterai bocor',
              icon: Icons.notes_outlined,
              controller: _keteranganController,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarangField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Barang',
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.navyText.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        _isLoadingBarang
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBg.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.lightBlueBg.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: AppColors.slateText.withOpacity(0.5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Memuat data barang...',
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _barangList.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBg.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Belum ada barang tersedia',
                      style: AppTextStyles.bodySecondary,
                    ),
                  )
                : DropdownButtonFormField<Barang>(
                    decoration: InputDecoration(
                      hintText: 'Pilih barang',
                      hintStyle: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 13,
                        color: AppColors.slateText.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: AppColors.slateText.withOpacity(0.7),
                      ),
                      filled: true,
                      fillColor: AppColors.lightBlueBg.withOpacity(0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.lightBlueBg.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.dangerRed.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.dangerRed,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                    value: _selectedBarang,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: AppColors.navyText,
                    ),
                    items: _barangList
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                  color: AppColors.slateText,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${b.nama} (Stok: ${b.stok})',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedBarang = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Pilih barang terlebih dahulu';
                      }
                      return null;
                    },
                  ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.navyText.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: AppColors.navyText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySecondary.copyWith(
              fontSize: 13,
              color: AppColors.slateText.withOpacity(0.6),
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: AppColors.slateText.withOpacity(0.7),
            ),
            filled: true,
            fillColor: AppColors.lightBlueBg.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.lightBlueBg.withOpacity(0.4),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.dangerRed.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.dangerRed,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
          inputFormatters: keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dangerRed,
          foregroundColor: AppColors.pureWhite,
          disabledBackgroundColor: AppColors.dangerRed.withOpacity(0.5),
          disabledForegroundColor: AppColors.pureWhite.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: AppColors.dangerRed.withOpacity(0.3),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.pureWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Menyimpan...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pureWhite,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Simpan Kondisi Rusak',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pureWhite,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
