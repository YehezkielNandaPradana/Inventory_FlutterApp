import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../models/barang_model.dart';

class ItemCard extends StatefulWidget {
  final Barang barang;
  final VoidCallback? onTap;
  final int animationDelay;

  const ItemCard({
    super.key,
    required this.barang,
    this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  Color get _statusColor {
    switch (widget.barang.status) {
      case 'Habis':
        return AppColors.dangerRed;
      case 'Menipis':
        return AppColors.warningAmber;
      default:
        return const Color.fromARGB(
          255,
          15,
          167,
          70,
        ); // hijau untuk status "Aman"
    }
  }

  IconData get _kategoriIcon {
    switch (widget.barang.kategori) {
      case 'Alat Tulis':
        return Icons.edit_outlined;
      case 'Perlengkapan Kantor':
        return Icons.business_center_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
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
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: child,
          ),
        );
      },
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primaryBlue.withOpacity(0.08),
        highlightColor: AppColors.primaryBlue.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.lightBlueBg,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status accent bar
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              _buildImage(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.barang.nama,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _kategoriIcon,
                          size: 13,
                          color: AppColors.slateText.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.barang.kategori,
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildStockProgress(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.barang.stok}',
                    style: AppTextStyles.stockNumber.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyText,
                    ),
                  ),
                  Text(
                    'pcs',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.slateText,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildStatusBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockProgress() {
    final percentage = widget.barang.persentaseStok;
    final statusColor = _statusColor;

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              // Track
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.lightBlueBg,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Fill with gradient
              FractionallySizedBox(
                widthFactor: percentage * _progressAnimation.value,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.7),
                        statusColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.barang.status,
        style: AppTextStyles.caption.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildImage() {
    final gambar = widget.barang.gambar;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: (gambar != null && gambar.isNotEmpty)
          ? Image.network(
              gambar,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _placeholder(loading: true);
              },
            )
          : _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightBlueBg,
            AppColors.primaryBlue.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: loading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue.withOpacity(0.6),
                ),
              ),
            )
          : Icon(_kategoriIcon, color: AppColors.primaryBlue, size: 24),
    );
  }
}
