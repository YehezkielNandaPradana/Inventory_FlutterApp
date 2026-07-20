import 'package:flutter/material.dart';
import '../../config/colors.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  static const List<_NavData> _items = [
    _NavData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Beranda',
    ),
    _NavData(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Barang',
    ),
    _NavData(
      icon: Icons.add_rounded,
      activeIcon: Icons.add_rounded,
      label: 'Tambah',
    ),
    _NavData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Bar dasar
          Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withAlpha(36),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      data: _items[0],
                      isActive: widget.selectedIndex == 0,
                      onTap: () => widget.onTap(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      data: _items[1],
                      isActive: widget.selectedIndex == 1,
                      onTap: () => widget.onTap(1),
                    ),
                  ),
                  const SizedBox(width: 64),
                  Expanded(
                    child: _NavItem(
                      data: _items[3],
                      isActive: widget.selectedIndex == 3,
                      onTap: () => widget.onTap(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tombol Tambah melayang di tengah
          Positioned(
            bottom: 32,
            child: _CenterButton(
              isActive: widget.selectedIndex == 2,
              onTap: () => widget.onTap(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final _NavData data;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      splashColor: AppColors.primaryBlue.withAlpha(26),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryBlue.withAlpha(26)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: isActive ? 1.18 : 1.0),
              duration: const Duration(milliseconds: 320),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                isActive ? data.activeIcon : data.icon,
                color: isActive ? AppColors.primaryBlue : AppColors.slateText,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              style: TextStyle(
                color: isActive ? AppColors.primaryBlue : AppColors.slateText,
                fontSize: isActive ? 12 : 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(data.label),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              height: 4,
              width: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CenterButton({required this.isActive, required this.onTap});

  @override
  State<_CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<_CenterButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.86);
  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withAlpha(184),
              ],
            ),
            border: Border.all(color: AppColors.pureWhite, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withAlpha(115),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: widget.isActive ? 0.125 : 0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, turns, child) => Transform.rotate(
              angle:
                  turns *
                  6.28319, // 1 turn penuh = 360 derajat (0.125 = 45 derajat)
              child: child,
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
