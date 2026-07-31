import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';
import 'package:mishra_milk_cash/models/denomination.dart';

/// A single denomination row with badge, +/- buttons, quantity input, and total.
/// Fully responsive — uses Expanded to prevent any overflow.
class DenominationCard extends StatefulWidget {
  final Denomination denomination;
  final int index;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const DenominationCard({
    super.key,
    required this.denomination,
    required this.index,
    required this.onQuantityChanged,
    required this.onIncrement,
    required this.onDecrement,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<DenominationCard> createState() => _DenominationCardState();
}

class _DenominationCardState extends State<DenominationCard>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.denomination.quantity.toString(),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(DenominationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.denomination.quantity.toString();
    if (_controller.text != newText) {
      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onButtonPress(bool isIncrement) {
    HapticFeedback.lightImpact();
    _pulseController.forward().then((_) => _pulseController.reverse());
    if (isIncrement) {
      widget.onIncrement();
    } else {
      widget.onDecrement();
    }
  }

  @override
  Widget build(BuildContext context) {
    final denom = widget.denomination;
    final isSpecial = denom.isCoin || denom.isOnline || denom.isBaaki;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          // ── Left: Badge + Label (fixed but compact) ──
          _buildBadge(denom, isSpecial),
          const SizedBox(width: 6),
          SizedBox(
            width: 48,
            child: Text(
              denom.label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: denom.color,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 4),

          // ── Middle: Minus | Input | Plus ──
          _buildCircleButton(
            icon: Icons.remove,
            color: AppColors.buttonMinus,
            onPressed: () => _onButtonPress(false),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 60,
            height: 38,
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[-0-9.,]*'),
                ),
                LengthLimitingTextInputFormatter(7),
              ],
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 2, vertical: 6,
                ),
                filled: true,
                fillColor: AppColors.backgroundCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primaryPurple, width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) {
                final qty = int.tryParse(value) ?? 0;
                widget.onQuantityChanged(qty);
              },
              onTap: () {
                _controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _controller.text.length,
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          _buildCircleButton(
            icon: Icons.add,
            color: AppColors.buttonPlus,
            onPressed: () => _onButtonPress(true),
          ),

          const SizedBox(width: 6),

          // ── Right: Amount (Expanded to take remaining space, no overflow) ──
          Expanded(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.05),
                  child: child,
                );
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '₹${_formatAmount(denom.amount)}',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(Denomination denom, bool isSpecial) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: denom.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: denom.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Center(
        child: isSpecial
            ? Icon(denom.icon, color: denom.color, size: 16)
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    denom.badgeText,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: denom.color,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount == 0) return '0';
    if (amount < 1000) return amount.toString();

    // Indian numbering: last 3 digits, then groups of 2
    final str = amount.toString();
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
