import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/transaksi_model.dart';
import '../../services/inventory_api.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';

class RekapScreen extends StatefulWidget {
  const RekapScreen({super.key});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  final InventoryApi _api = InventoryApi();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _rekapData;
  List<Transaksi> _transaksiTerbaru = [];

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
      final rekap = await _api.fetchRekap();
      final transaksi = await _api.fetchTransaksiList();

      if (!mounted) return;

      setState(() {
        _rekapData = rekap;
        _transaksiTerbaru = transaksi.take(20).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primaryBlue,
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
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Transaksi Terbaru'),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      _buildLoadingState()
                    else if (_errorMessage != null)
                      _buildErrorState()
                    else if (_transaksiTerbaru.isEmpty)
                      _buildEmptyTransaksi()
                    else
                      _buildTransaksiList(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.barangList);
              break;
            case 2:
              Navigator.pushReplacementNamed(context, AppRoutes.stokMasuk);
              break;
            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.kondisiRusak);
              break;
          }
        },
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
                  colors: [AppColors.primaryBlue, AppColors.skyBlue],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: AppColors.pureWhite,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text('Pengecekan Rekap', style: AppTextStyles.h1.copyWith(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_isLoading) {
      return Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ShimmerCard(delay: index * 100),
          ),
        ),
      );
    }

    if (_rekapData == null) return const SizedBox.shrink();

    final totalBarang = _rekapData!['total_barang'] ?? 0;
    final totalStok = _rekapData!['total_stok'] ?? 0;
    final stokMenipis = _rekapData!['stok_menipis'] ?? 0;
    final totalRusak = _rekapData!['total_rusak'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Barang',
                value: totalBarang.toString(),
                icon: Icons.inventory_2_rounded,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Total Stok',
                value: totalStok.toString(),
                icon: Icons.numbers_rounded,
                color: AppColors.skyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Stok Menipis',
                value: stokMenipis.toString(),
                icon: Icons.warning_amber_rounded,
                color: AppColors.warningAmber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Total Rusak',
                value: totalRusak.toString(),
                icon: Icons.warning_rounded,
                color: AppColors.dangerRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h2,
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ShimmerCard(delay: index * 100),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 36,
            color: AppColors.dangerRed.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Gagal memuat data',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransaksi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 36,
            color: AppColors.slateText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: AppTextStyles.h3.copyWith(color: AppColors.navyText),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaksi akan muncul di sini',
            style: AppTextStyles.caption.copyWith(color: AppColors.slateText),
          ),
        ],
      ),
    );
  }

  Widget _buildTransaksiList() {
    return Column(
      children: List.generate(_transaksiTerbaru.length, (index) {
        final transaksi = _transaksiTerbaru[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TransaksiCard(transaksi: transaksi),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.navyText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.slateText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransaksiCard extends StatelessWidget {
  final Transaksi transaksi;

  const _TransaksiCard({required this.transaksi});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch (transaksi.jenis) {
      case 'masuk':
        statusColor = AppColors.successGreen;
        statusIcon = Icons.arrow_downward_rounded;
        break;
      case 'rusak':
        statusColor = AppColors.dangerRed;
        statusIcon = Icons.warning_amber_rounded;
        break;
      default:
        statusColor = AppColors.slateText;
        statusIcon = Icons.swap_horiz_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, size: 20, color: statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaksi.barangNama,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaksi.label,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '|',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.slateText.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      transaksi.tanggal,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.slateText,
                      ),
                    ),
                  ],
                ),
                if (transaksi.keterangan != null && transaksi.keterangan!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      transaksi.keterangan!,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.slateText.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${transaksi.jumlah > 0 ? '+' : ''}${transaksi.jumlah}',
              style: AppTextStyles.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final int delay;

  const _ShimmerCard({this.delay = 0});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmer = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        return Opacity(opacity: _shimmer.value, child: child);
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
