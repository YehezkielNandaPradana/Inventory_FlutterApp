import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/barang_model.dart';
import '../../services/inventory_api.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<Barang> _barangList = [];
  int _totalBarang = 0;
  int _stokMenipis = 0;
  int _totalKategori = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = InventoryApi();
      final barangList = await api.fetchBarangList();

      final stokMenipis = barangList
          .where((b) => b.status == 'Menipis' || b.status == 'Habis')
          .length;
      final totalKategori = barangList.map((b) => b.kategori).toSet().length;

      if (!mounted) return;

      setState(() {
        _barangList = barangList;
        _totalBarang = barangList.length;
        _stokMenipis = stokMenipis;
        _totalKategori = totalKategori;
        _isLoading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: AppConstants.spacing32 + mediaQuery.padding.bottom,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing24,
                    ),
                    child: _buildStats(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing24,
                  ),
                  child: Transform.translate(
                    offset: const Offset(0, -12),
                    child: _buildBarangTerbaru(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing24,
        AppConstants.spacing24,
        AppConstants.spacing24,
        56,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.75),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'A',
                  style: AppTextStyles.h1.copyWith(color: AppColors.pureWhite),
                ),
              ),
              const SizedBox(width: AppConstants.spacing16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, Admin',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selamat datang kembali!',
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: AppColors.pureWhite.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pureWhite.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.pureWhite,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    if (_isLoading) {
      return Row(
        children: const [
          Expanded(child: StatCard(title: 'Total Barang', value: '-', accentColor: AppColors.primaryBlue)),
          SizedBox(width: AppConstants.spacing16),
          Expanded(child: StatCard(title: 'Stok Menipis', value: '-', accentColor: AppColors.warningAmber)),
          SizedBox(width: AppConstants.spacing16),
          Expanded(child: StatCard(title: 'Kategori', value: '-', accentColor: AppColors.primaryBlue)),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Barang',
            value: _totalBarang.toString(),
            accentColor: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: AppConstants.spacing16),
        Expanded(
          child: StatCard(
            title: 'Stok Menipis',
            value: _stokMenipis.toString(),
            accentColor: AppColors.warningAmber,
          ),
        ),
        const SizedBox(width: AppConstants.spacing16),
        Expanded(
          child: StatCard(
            title: 'Kategori',
            value: _totalKategori.toString(),
            accentColor: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildBarangTerbaru() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Barang Terbaru', style: AppTextStyles.h2),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lihat Semua',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing16),
        if (_isLoading)
          _buildLoadingList()
        else if (_errorMessage != null && _barangList.isEmpty)
          _buildErrorState()
        else if (_barangList.isEmpty)
          _buildEmptyState()
        else
          _buildBarangList(),
      ],
    );
  }

  Widget _buildLoadingList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBg.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 40,
            color: AppColors.dangerRed.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Gagal memuat data',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.pureWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 40,
            color: AppColors.slateText.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text('Belum ada barang', style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }

  Widget _buildBarangList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _barangList.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.lightBlueBg,
          ),
        ),
        itemBuilder: (context, index) {
          return ItemCard(
            barang: _barangList[index],
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.barangDetail,
                arguments: _barangList[index],
              );
            },
          );
        },
      ),
    );
  }
}
