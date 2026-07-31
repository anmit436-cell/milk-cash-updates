import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';

/// Premium animated tab bar with gradient selected indicator, glow, and scale
class AnimatedTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const AnimatedTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  static const _tabs = [
    _TabItem(icon: Icons.currency_rupee_outlined, label: 'Counter'),
    _TabItem(icon: Icons.history_outlined, label: 'History'),
    _TabItem(icon: Icons.receipt_long_outlined, label: 'Baaki'),
    _TabItem(icon: Icons.calculate_outlined, label: 'Calculator'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingOuter),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = index == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: AppConstants.animMedium,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.tabSelectedGradient : null,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: AppConstants.animMedium,
                      child: Icon(
                        _tabs[index].icon,
                        size: 22,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tabs[index].label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;

  const _TabItem({required this.icon, required this.label});
}
