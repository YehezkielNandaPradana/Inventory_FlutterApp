import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/barang_model.dart';
import '../../models/user_model.dart';
import '../../services/inventory_api.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<Barang> _barangList = [];
  int _totalBarang = 0;
  int _stokMenipis = 0;
  int _totalKategori = 0;
  UserModel? _user;

  // Animation controllers
  late AnimationController _headerController;
  late Animation<double> _headerSlide;
  late Animation<double> _headerFade;

  late AnimationController _sectionController;
  late Animation<double> _sectionFade;
  late Animation<Offset> _sectionSlide;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _headerSlide = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Section animation for "Barang Terbaru" title
    _sectionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _sectionFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sectionController, curve: Curves.easeOut),
    );
    _sectionSlide =
        Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _sectionController,
            curve: Curves.easeOutCubic,
          ),
        );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _sectionController.forward();
    });

    _loadData();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (_user == null && args is UserModel) {
      _user = args;
    }
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
          color: AppColors.primaryBlue,
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
          if (index == _selectedNavIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.barangList);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.barangForm);
              break;
            case 3:
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.profile,
                arguments: _user,
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlide.value),
          child: Opacity(opacity: _headerFade.value, child: child),
        );
      },
      child: Container(
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
              AppColors.skyBlue,
              AppColors.primaryBlue.withOpacity(0.85),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Avatar with gradient ring
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.pureWhite.withOpacity(0.6),
                        AppColors.pureWhite.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _user != null && _user!.name.isNotEmpty
                          ? _user!.name[0].toUpperCase()
                          : 'N',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.pureWhite,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                       'Halo, ${_user?.name ?? 'Admin'}',
                       style: AppTextStyles.h1.copyWith(
                         color: AppColors.pureWhite,
                         fontSize: 22,
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
            // Notification bell with badge
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.pureWhite.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.pureWhite.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.pureWhite,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  if (_stokMenipis > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.dangerRed,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    if (_isLoading) {
      return Row(
        children: const [
          Expanded(
            child: StatCard(
              title: 'Total Barang',
              value: '-',
              accentColor: AppColors.primaryBlue,
              animationDelay: 200,
            ),
          ),
          SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: StatCard(
              title: 'Stok Menipis',
              value: '-',
              accentColor: AppColors.warningAmber,
              animationDelay: 350,
            ),
          ),
          SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: StatCard(
              title: 'Kategori',
              value: '-',
              accentColor: AppColors.primaryBlue,
              animationDelay: 500,
            ),
          ),
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
            icon: Icons.inventory_2_outlined,
            animationDelay: 200,
          ),
        ),
        const SizedBox(width: AppConstants.spacing16),
        Expanded(
          child: StatCard(
            title: 'Stok Menipis',
            value: _stokMenipis.toString(),
            accentColor: _stokMenipis > 0
                ? AppColors.warningAmber
                : AppColors.successGreen,
            icon: _stokMenipis > 0
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            animationDelay: 350,
          ),
        ),
        const SizedBox(width: AppConstants.spacing16),
        Expanded(
          child: StatCard(
            title: 'Kategori',
            value: _totalKategori.toString(),
            accentColor: AppColors.skyBlue,
            icon: Icons.category_outlined,
            animationDelay: 500,
          ),
        ),
      ],
    );
  }

  Widget _buildBarangTerbaru() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlideTransition(
          position: _sectionSlide,
          child: FadeTransition(
            opacity: _sectionFade,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Barang Terbaru', style: AppTextStyles.h2),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.barangList,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        if (_isLoading)
          _buildShimmerList()
        else if (_errorMessage != null && _barangList.isEmpty)
          _buildErrorState()
        else if (_barangList.isEmpty)
          _buildEmptyState()
        else
          _buildBarangList(),
      ],
    );
  }

  Widget _buildShimmerList() {
    return Container(
      width: double.infinity,
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
        children: List.generate(3, (index) => _ShimmerItem(delay: index * 150)),
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.dangerRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 32,
              color: AppColors.dangerRed.withOpacity(0.7),
            ),
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 32,
              color: AppColors.slateText.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text('Belum ada barang', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 8),
          Text('Tambahkan barang pertama kamu', style: AppTextStyles.caption),
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
            color: AppColors.primaryBlue.withOpacity(0.06),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, thickness: 1, color: AppColors.lightBlueBg),
        ),
        itemBuilder: (context, index) {
          return ItemCard(
            barang: _barangList[index],
            animationDelay: 600 + (index * 120),
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

/// Shimmer loading placeholder with pulsing animation
class _ShimmerItem extends StatefulWidget {
  final int delay;

  const _ShimmerItem({this.delay = 0});

  @override
  State<_ShimmerItem> createState() => _ShimmerItemState();
}

class _ShimmerItemState extends State<_ShimmerItem>
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
      end: 0.8,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBg.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
