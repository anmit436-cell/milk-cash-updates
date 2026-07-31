import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/utils/formatters.dart';
import 'package:mishra_milk_cash/models/transaction_record.dart';
import 'dart:ui';

class PremiumTransactionCard extends StatefulWidget {
  final TransactionRecord transaction;
  final int number;
  final bool isExpanded;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDownloadPdf;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onFavorite;

  const PremiumTransactionCard({
    super.key,
    required this.transaction,
    required this.number,
    required this.isExpanded,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onShare,
    required this.onDownloadPdf,
    required this.onDelete,
    required this.onDuplicate,
    required this.onFavorite,
  });

  @override
  State<PremiumTransactionCard> createState() => _PremiumTransactionCardState();
}

class _PremiumTransactionCardState extends State<PremiumTransactionCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  Color _paymentColor(String type) {
    if (widget.transaction.baakiTotal > 0) return AppColors.error; // Due
    switch (type) {
      case 'Cash':
        return AppColors.success;
      case 'Online':
        return AppColors.denomOnline;
      case 'Mixed':
        return AppColors.primaryPurple;
      default:
        return AppColors.textMuted;
    }
  }
  
  String _paymentLabel(String type) {
    if (widget.transaction.baakiTotal > 0) return 'Due';
    return type;
  }

  String _formatIndian(int amount) {
    if (amount == 0) return '0';
    final str = amount.toString();
    if (str.length <= 3) return str;
    
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

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.98 : 1.0;
    
    return Slidable(
      key: ValueKey(widget.transaction.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => widget.onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              bottomLeft: Radius.circular(22),
            ),
          ),
          SlidableAction(
            onPressed: (_) => widget.onShare(),
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            icon: Icons.share_outlined,
            label: 'Share',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => widget.onEdit(),
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => widget.onDuplicate(),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            icon: Icons.copy_outlined,
            label: 'Duplicate',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          widget.onLongPress();
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: const Color(0xFF0F172A).withValues(alpha: 0.6), // Dark navy glassmorphism
                border: Border.all(
                  color: widget.isSelected 
                      ? AppColors.primaryPurple 
                      : const Color(0xFF3B82F6).withValues(alpha: (_isHovered || widget.isExpanded) ? 0.5 : 0.2), // Semi-transparent blue glow
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: (_isHovered || widget.isExpanded) ? 0.15 : 0.05),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    children: [
                      // ── Collapsed Layout ──
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Selection Checkbox
                            if (widget.isSelectionMode) ...[
                              Icon(
                                widget.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: widget.isSelected ? AppColors.primaryPurple : AppColors.textMuted,
                              ),
                              const SizedBox(width: 12),
                            ],
                            
                            // Left: Transaction Number & Avatar
                            Column(
                              children: [
                                Text(
                                  '#${widget.number.toString().padLeft(3, '0')}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.person_outline, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            
                            // Center: Customer Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                        widget.transaction.customerName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (widget.transaction.isFavorite)
                                        const Icon(Icons.star, color: Colors.amber, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      const Icon(Icons.calendar_today, size: 10, color: AppColors.textMuted),
                                      Text(
                                        Formatters.date(widget.transaction.dateTime),
                                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.access_time, size: 10, color: AppColors.textMuted),
                                      Text(
                                        Formatters.time(widget.transaction.dateTime),
                                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Right: Payment Badge & Amount
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: _paymentColor(widget.transaction.paymentType).withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: _paymentColor(widget.transaction.paymentType).withValues(alpha: 0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _paymentColor(widget.transaction.paymentType).withValues(alpha: 0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _paymentLabel(widget.transaction.paymentType),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _paymentColor(widget.transaction.paymentType),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Amount
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '₹${_formatIndian(widget.transaction.grandTotal)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Arrow
                                AnimatedRotation(
                                  turns: widget.isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.textMuted,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // ── Expanded Content ──
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: widget.isExpanded 
                          ? _buildExpandedDetails() 
                          : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedDetails() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        border: const Border(
          top: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          // Breakdown
          ...widget.transaction.denominations.where((d) => d.quantity > 0).map((d) {
            String leftLabel;
            if (d.isCoin) {
              leftLabel = 'Coins';
            } else if (d.isOnline) {
              leftLabel = 'Online Payment';
            } else if (d.isBaaki) {
              leftLabel = 'Baaki';
            } else {
              leftLabel = '₹${d.value} × ${d.quantity}';
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    leftLabel,
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  Text(
                    '₹${_formatIndian(d.amount)}',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 12),
          Container(height: 1, decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
          const SizedBox(height: 16),
          
          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${_formatIndian(widget.transaction.grandTotal)}',
                      style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (widget.transaction.amountInWords.isNotEmpty)
                      Text(
                        widget.transaction.amountInWords,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: _GlassButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                  onTap: widget.onEdit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GlassButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  gradient: AppColors.shareButtonGradient,
                  onTap: widget.onShare,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GlassButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'PDF',
                  gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)]),
                  onTap: widget.onDownloadPdf,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GlassButton(
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  gradient: const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFFDC2626)]),
                  onTap: widget.onDelete,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GlassButton(
                  icon: Icons.copy_outlined,
                  label: 'Duplicate',
                  gradient: const LinearGradient(colors: [Color(0xFF374151), Color(0xFF4B5563)]),
                  onTap: widget.onDuplicate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GlassButton(
                  icon: widget.transaction.isFavorite ? Icons.star : Icons.star_border,
                  label: widget.transaction.isFavorite ? 'Unfavorite' : 'Favorite',
                  gradient: const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFF59E0B)]),
                  onTap: widget.onFavorite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
