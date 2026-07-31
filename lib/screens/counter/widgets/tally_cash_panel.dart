import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/providers/counter_provider.dart';

class TallyCashPanel extends StatefulWidget {
  const TallyCashPanel({super.key});

  @override
  State<TallyCashPanel> createState() => _TallyCashPanelState();
}

class _TallyCashPanelState extends State<TallyCashPanel> {
  final TextEditingController _controller = TextEditingController();
  int _expectedCash = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
      setState(() {
        _expectedCash = int.tryParse(text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _expectedCash = 0;
    });
  }

  void _close(BuildContext context) {
    _clear();
    context.read<CounterProvider>().closeTallyPanel();
  }

  String _formatIndianCurrency(int amount) {
    String value = amount.abs().toString();
    if (value.length > 3) {
      String lastThree = value.substring(value.length - 3);
      String otherNumbers = value.substring(0, value.length - 3);
      if (otherNumbers.isNotEmpty) {
        otherNumbers = otherNumbers.replaceAllMapped(RegExp(r'.{1,2}(?=(.{2})+(?!.))'), (Match m) => '${m[0]},');
        value = '$otherNumbers,$lastThree';
      }
    }
    return '₹$value';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
      builder: (context, counter, _) {
        final countedCash = counter.grandTotal;
        final difference = countedCash - _expectedCash;
        final hasInput = _controller.text.isNotEmpty;

        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withValues(alpha: 0.1),
                AppColors.primaryPurple.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Tally Cash',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Input Field
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  hintText: 'Enter Expected Cash',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryBlue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ).animate(target: hasInput ? 1 : 0).shimmer(duration: 500.ms, color: AppColors.primaryBlue.withValues(alpha: 0.2)),
              
              if (hasInput) ...[
                const SizedBox(height: 16),
                _buildResultCard(_expectedCash, countedCash, difference),
              ],
              
              const SizedBox(height: 16),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clear,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundCard,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.glassBorder),
                        ),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _close(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.15),
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultCard(int expected, int counted, int diff) {
    Color cardColor;
    IconData icon;
    String title;
    
    if (diff == 0) {
      cardColor = AppColors.success;
      icon = Icons.check_circle;
      title = 'Cash Tallied Perfectly';
    } else if (diff < 0) {
      cardColor = AppColors.error;
      icon = Icons.arrow_downward;
      title = 'Cash Short';
    } else {
      cardColor = AppColors.primaryPurple;
      icon = Icons.arrow_upward;
      title = 'Extra Cash Found';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor.withValues(alpha: 0.2),
            cardColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: cardColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cardColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          _buildRow('Expected Cash', expected, Colors.white),
          const SizedBox(height: 4),
          _buildRow('Counted Cash', counted, Colors.white),
          const SizedBox(height: 4),
          _buildRow(
            'Difference', 
            diff, 
            cardColor,
            showSign: true,
          ),
        ],
      ),
    ).animate(key: ValueKey(diff)).fadeIn(duration: 300.ms).scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildRow(String label, int value, Color color, {bool showSign = false}) {
    String formattedValue = _formatIndianCurrency(value);
    if (showSign) {
      if (value > 0) formattedValue = '+$formattedValue';
      else if (value < 0) formattedValue = '-$formattedValue';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          formattedValue,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ).animate(key: ValueKey(value)).slideY(begin: 0.5, end: 0, duration: 200.ms).fadeIn(duration: 200.ms),
      ],
    );
  }
}
