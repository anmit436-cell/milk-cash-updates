import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';

/// Premium grand total card with blue-purple-pink gradient
/// Shows the large total amount and amount in words
class GrandTotalCard extends StatefulWidget {
  final int grandTotal;
  final String amountInWords;

  const GrandTotalCard({
    super.key,
    required this.grandTotal,
    required this.amountInWords,
  });

  @override
  State<GrandTotalCard> createState() => _GrandTotalCardState();
}

class _GrandTotalCardState extends State<GrandTotalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.grandTotalGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '₹${_formatGrandTotal(widget.grandTotal)}',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
              ),
              if (widget.amountInWords.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.amountInWords,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),

          // Sparkle Icon (animated rotation)
          Positioned(
            top: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _sparkleController.value * 2 * pi,
                  child: Opacity(
                    opacity: 0.5 + (sin(_sparkleController.value * 2 * pi) * 0.3),
                    child: child,
                  ),
                );
              },
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatGrandTotal(int amount) {
    if (amount == 0) return '0';
    
    final str = amount.toString();
    if (str.length <= 3) return str;
    
    // Indian numbering system: last 3 digits, then groups of 2
    String result = str.substring(str.length - 3);
    String remaining = str.substring(0, str.length - 3);
    
    while (remaining.isNotEmpty) {
      if (remaining.length > 2) {
        result = '${remaining.substring(remaining.length - 2)},$result';
        remaining = remaining.substring(0, remaining.length - 2);
      } else {
        result = '$remaining,$result';
        remaining = '';
      }
    }
    
    return result;
  }
}
