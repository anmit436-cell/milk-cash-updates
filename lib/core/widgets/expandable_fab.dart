import 'package:flutter/material.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableFab extends StatefulWidget {
  final VoidCallback onQuickCalculator;
  final VoidCallback onScanQr;
  final VoidCallback onTallyCash;

  const ExpandableFab({
    super.key,
    required this.onQuickCalculator,
    required this.onScanQr,
    required this.onTallyCash,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: AppConstants.animMedium,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          _buildActionButtons(),
          _buildMainFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return _isOpen
        ? GestureDetector(
            onTap: _toggle,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ActionItem(
          icon: Icons.qr_code_scanner,
          label: 'Show QRs',
          animation: _expandAnimation,
          onPressed: () {
            _toggle();
            widget.onScanQr();
          },
        ),
        _ActionItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Tally Cash',
          animation: _expandAnimation,
          onPressed: () {
            _toggle();
            widget.onTallyCash();
          },
        ),
        _ActionItem(
          icon: Icons.calculate_outlined,
          label: 'Quick Calculator',
          animation: _expandAnimation,
          onPressed: () {
            _toggle();
            widget.onQuickCalculator();
          },
        ),
        const SizedBox(height: 70), // Space for main FAB
      ],
    );
  }

  Widget _buildMainFab() {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 4), // Optional tweak
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppColors.primaryPurple,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * (3.14159 / 4), // 45 degrees
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Animation<double> animation;
  final VoidCallback onPressed;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.animation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.small(
                heroTag: null, // Avoid hero tag conflicts
                onPressed: onPressed,
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primaryBlue,
                child: Icon(icon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
