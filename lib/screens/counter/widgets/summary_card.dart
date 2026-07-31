import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';

/// Summary card showing Notes, Coins, Online, and Baaki totals
class SummaryCard extends StatelessWidget {
  final int notesCount;
  final int coinsTotal;
  final int onlineTotal;
  final int baakiTotal;

  const SummaryCard({
    super.key,
    required this.notesCount,
    required this.coinsTotal,
    required this.onlineTotal,
    required this.baakiTotal,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            gradient: AppColors.summaryGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              _buildItem('Notes', notesCount.toString(), AppColors.primaryBlue),
              _buildDivider(),
              _buildItem('Coins', '₹$coinsTotal', AppColors.denomCoins),
              _buildDivider(),
              _buildItem('Online', '₹$onlineTotal', AppColors.denomOnline),
              _buildDivider(),
              _buildItem('Baaki', '₹$baakiTotal', AppColors.denomBaaki),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.glassBorder,
    );
  }
}
