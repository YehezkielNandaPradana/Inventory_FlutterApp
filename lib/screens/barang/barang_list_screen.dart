import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../models/barang_model.dart';
import '../../services/inventory_api.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';

class BarangListScreen extends StatefulWidget {
  const BarangListScreen({super.key});

  @override
  State<BarangListScreen> createState() => _BarangListScreenState();
}

class _BarangListScreenState extends State<BarangListScreen>
    with TickerProviderStateMixin {
  final InventoryApi _api = InventoryApi();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _selectedNavIndex = 1;
  bool _isLoading = true;
  String? _errorMessage;
  List<Barang> _barangList = [];
  List<Barang> _filteredBarangList = [];
  Timer? _debounce;

  // Animations
  late AnimationController _headerAnimController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  late AnimationController _searchAnimController;
  late Animation<double> _searchFade;
  late Animation<double> _searchScale;

  late AnimationController _fabAnimController;
  late Animation<double> _fabScale;

  // Selected filter
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();

    // Header animation
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headerAnimController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerAnimController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Search animation
    _searchAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _searchFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _searchAnimController, curve: Curves.easeOut),
    );
    _searchScale = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _searchAnimController, curve: Curves.easeOutBack),
    );

    // FAB animation
    _fabAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.elasticOut),
    );

    // Stagger animations
    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _searchAnimController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabAnimController.forward();
    });

    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _headerAnimController.dispose();
    _searchAnimController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredBarangList = _barangList.where((barang) {
        final matchesSearch =
            query.isEmpty ||
            barang.nama.toLowerCase().contains(query) ||
            barang.kategori.toLowerCase().contains(query);
        final matchesFilter =
            _selectedFilter == 'Semua' || barang.status == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final barangList = await _api.fetchBarangList();
      if (!mounted) return;
      setState(() {
        _barangList = barangList;
        _filteredBarangList = List.from(barangList);
        _isLoading = false;
      });
      _applyFilters();
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

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    setState(() => _selectedNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        // Stay on current page (BarangListScreen)
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.barangForm);
        break;
      case 3:
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primaryBlue,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAnimatedAppBar(),
              SliverPadding(
                padding: EdgeInsets.only(
                  left: AppConstants.spacing24,
                  right: AppConstants.spacing24,
                  top: AppConstants.spacing16,
                  bottom:
                      AppConstants.spacing32 +
                      MediaQuery.of(context).padding.bottom,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSearchField(),
                    const SizedBox(height: AppConstants.spacing16),
                    _buildFilterChips(),
                    const SizedBox(height: AppConstants.spacing20),
                    _buildSectionHeader(),
                    const SizedBox(height: AppConstants.spacing16),
                    if (_isLoading)
                      _buildLoadingState()
                    else if (_errorMessage != null && _barangList.isEmpty)
                      _buildErrorState()
                    else if (_filteredBarangList.isEmpty)
                      _buildEmptyState()
                    else
                      _buildBarangList(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: _buildAnimatedFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.pureWhite,
      elevation: 0,
      floating: true,
      snap: true,
      toolbarHeight: 64,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      automaticallyImplyLeading: false,
      flexibleSpace: SlideTransition(
        position: _headerSlide,
        child: FadeTransition(
          opacity: _headerFade,
          child: FlexibleSpaceBar(
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
                    Icons.inventory_2_rounded,
                    color: AppColors.pureWhite,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Barang', style: AppTextStyles.h1.copyWith(fontSize: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return AnimatedBuilder(
      animation: _searchAnimController,
      builder: (context, child) {
        return Transform.scale(
          scale: _searchScale.value,
          child: Opacity(opacity: _searchFade.value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari barang atau kategori...',
            hintStyle: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.slateText.withOpacity(0.5),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                size: 22,
                color: AppColors.primaryBlue.withOpacity(0.7),
              ),
            ),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlueBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.slateText,
                      ),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.primaryBlue.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AppTextStyles.body.copyWith(color: AppColors.navyText),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'Aman', 'Menipis', 'Habis'];
    final filterColors = {
      'Semua': AppColors.primaryBlue,
      'Aman': const Color.fromARGB(255, 15, 167, 70),
      'Menipis': AppColors.warningAmber,
      'Habis': AppColors.dangerRed,
    };

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          final color = filterColors[filter] ?? AppColors.primaryBlue;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedFilter = filter);
                  _applyFilters();
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : const Color.fromARGB(
                              255,
                              90,
                              108,
                              145,
                            ).withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (filter != 'Semua') ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.pureWhite : color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        filter,
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.pureWhite
                              : AppColors.slateText,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    final total = _isLoading ? '-' : _filteredBarangList.length.toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _selectedFilter == 'Semua'
              ? 'Semua Barang'
              : 'Status: $_selectedFilter',
          style: AppTextStyles.h2,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Container(
            key: ValueKey(total),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.12),
                  AppColors.skyBlue.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$total item',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ShimmerItemCard(delay: index * 120),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.dangerRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: AppColors.dangerRed.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Koneksi Terputus',
            style: AppTextStyles.h3.copyWith(color: AppColors.navyText),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Gagal memuat data',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchController.text.isEmpty
                  ? Icons.inventory_2_outlined
                  : Icons.search_off_rounded,
              size: 36,
              color: AppColors.slateText.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchController.text.isEmpty
                ? 'Belum ada barang'
                : 'Barang tidak ditemukan',
            style: AppTextStyles.h3.copyWith(color: AppColors.navyText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Tambahkan barang pertama kamu'
                : 'Coba kata kunci atau filter lain',
            style: AppTextStyles.caption.copyWith(color: AppColors.slateText),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.barangForm);
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah Barang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.pureWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBarangList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredBarangList.length,
      itemBuilder: (context, index) {
        final barang = _filteredBarangList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ItemCard(
            barang: barang,
            animationDelay: 100 + (index * 80),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.barangDetail,
                arguments: barang,
              );
            },
          ),
        );
      },
    );
  }

  Widget? _buildAnimatedFab() {
    return ScaleTransition(
      scale: _fabScale,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.barangForm);
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, color: AppColors.pureWhite),
        label: const Text(
          'Tambah',
          style: TextStyle(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading card placeholder with pulsing animation
class _ShimmerItemCard extends StatefulWidget {
  final int delay;

  const _ShimmerItemCard({this.delay = 0});

  @override
  State<_ShimmerItemCard> createState() => _ShimmerItemCardState();
}

class _ShimmerItemCardState extends State<_ShimmerItemCard>
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightBlueBg, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.lightBlueBg,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 52,
              height: 52,
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
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBg.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 10),
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
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 30,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlueBg.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
