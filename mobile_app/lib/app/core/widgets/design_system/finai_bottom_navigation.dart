import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class FinaiBottomNavigationItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  FinaiBottomNavigationItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class FinaiBottomNavigation extends StatefulWidget {
  final List<FinaiBottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;

  const FinaiBottomNavigation({
    Key? key,
    required this.items,
    this.currentIndex = 0,
    this.onIndexChanged,
  }) : super(key: key);

  @override
  State<FinaiBottomNavigation> createState() => _FinaiBottomNavigationState();
}

class _FinaiBottomNavigationState extends State<FinaiBottomNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(FinaiBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          boxShadow: AppTheme.shadowStrong,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.items.length,
              (index) => _buildNavItem(
                index: index,
                item: widget.items[index],
                isActive: index == _currentIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required FinaiBottomNavigationItem item,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        widget.onIndexChanged?.call(index);
        item.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: AppColors.white,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                item.label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
