import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/text_styles.dart';
import '../../config/constants.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final Color accentColor;
  final IconData? icon;
  final int animationDelay;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.accentColor,
    this.icon,
    this.animationDelay = 0,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _countAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted) _controller.forward();
      });
    }
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    final numericValue = int.tryParse(widget.value);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: widget.accentColor.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon accent
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.accentColor.withOpacity(0.15),
                  widget.accentColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon ?? _defaultIcon,
              size: 18,
              color: widget.accentColor,
            ),
          ),
          const SizedBox(height: 12),
          // Animated count value
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              String displayValue;
              if (numericValue != null) {
                displayValue =
                    (numericValue * _countAnimation.value).round().toString();
              } else {
                displayValue = widget.value;
              }
              return Text(
                displayValue,
                style: AppTextStyles.h2.copyWith(
                  color: widget.accentColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            widget.title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.slateText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _defaultIcon {
    if (widget.title.toLowerCase().contains('total')) {
      return Icons.inventory_2_outlined;
    } else if (widget.title.toLowerCase().contains('menipis')) {
      return Icons.warning_amber_rounded;
    } else if (widget.title.toLowerCase().contains('kategori')) {
      return Icons.category_outlined;
    }
    return Icons.analytics_outlined;
  }
}
