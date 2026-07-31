import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';
import 'package:mishra_milk_cash/providers/counter_provider.dart';
import 'package:mishra_milk_cash/providers/history_provider.dart';
import 'package:mishra_milk_cash/screens/counter/widgets/customer_card.dart';
import 'package:mishra_milk_cash/screens/counter/widgets/denomination_card.dart';
import 'package:mishra_milk_cash/screens/counter/widgets/summary_card.dart';
import 'package:mishra_milk_cash/screens/counter/widgets/grand_total_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishra_milk_cash/screens/counter/widgets/bottom_actions.dart';
import 'package:mishra_milk_cash/screens/counter/widgets/tally_cash_panel.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  final List<FocusNode> _focusNodes = [];

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _getFocusNode(int index) {
    while (_focusNodes.length <= index) {
      _focusNodes.add(FocusNode());
    }
    return _focusNodes[index];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
      builder: (context, counter, _) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingOuter,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 12),

                  // ── Customer Card ──
                  const CustomerCard(),
                  const SizedBox(height: 16),

                  // ── Denomination Cards ──
                  ...List.generate(counter.denominations.length, (index) {
                    final isLast = index == counter.denominations.length - 1;
                    return DenominationCard(
                      denomination: counter.denominations[index],
                      index: index,
                      focusNode: _getFocusNode(index),
                      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
                      onSubmitted: (_) {
                        if (isLast) {
                          FocusScope.of(context).unfocus();
                        } else {
                          FocusScope.of(context).requestFocus(_getFocusNode(index + 1));
                        }
                      },
                      onQuantityChanged: (qty) =>
                          counter.updateQuantity(index, qty),
                      onIncrement: () => counter.increment(index),
                      onDecrement: () => counter.decrement(index),
                    );
                  }),

                  const SizedBox(height: 12),

                  // ── Summary Card ──
                  SummaryCard(
                    notesCount: counter.notesCount,
                    coinsTotal: counter.coinsTotal,
                    onlineTotal: counter.onlineTotal,
                    baakiTotal: counter.baakiTotal,
                  ),

                  // ── Tally Cash Panel (Animated) ──
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: counter.isTallyOpen ? const TallyCashPanel() : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 16),

                  // ── Grand Total Card ──
                  GrandTotalCard(
                    grandTotal: counter.grandTotal,
                    amountInWords: counter.amountInWords,
                  ),

                  const SizedBox(height: 16),

                  // ── Bottom Actions ──
                  BottomActions(
                    onReset: () => _showResetDialog(context, counter),
                    onShare: () => _shareReport(context, counter),
                    onSave: () => _saveTransaction(context, counter),
                  ),

                  // Extra bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, CounterProvider counter) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          'Reset All?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'This will clear all denomination values and customer name.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              counter.reset();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All values reset'),
                  backgroundColor: AppColors.surface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              'Reset',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReport(BuildContext context, CounterProvider counter) async {
    HapticFeedback.lightImpact();
    if (counter.grandTotal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nothing to share. Add some values first.'),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final text = counter.generateShareText();
    final encodedText = Uri.encodeComponent(text);
    final whatsappUrl = Uri.parse("whatsapp://send?text=$encodedText");
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        SharePlus.instance.share(ShareParams(text: text));
      }
    } catch (e) {
      SharePlus.instance.share(ShareParams(text: text));
    }
  }

  Future<void> _saveTransaction(
      BuildContext context, CounterProvider counter) async {
    HapticFeedback.mediumImpact();
    if (counter.grandTotal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nothing to save. Add some values first.'),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    try {
      await counter.save();

      // Refresh history
      if (context.mounted) {
        context.read<HistoryProvider>().loadTransactions();
      }

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (ctx.mounted) Navigator.pop(ctx);
            });
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 80,
                      )
                          .animate()
                          .scale(duration: 400.ms, curve: Curves.easeOutBack)
                          .fadeIn(),
                      const SizedBox(height: 24),
                      Text(
                        'Transaction Saved!',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                          .animate(delay: 200.ms)
                          .slideY(begin: 0.5, end: 0, duration: 300.ms)
                          .fadeIn(),
                    ],
                  ),
                ).animate().scale(duration: 300.ms, curve: Curves.easeOutQuad),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
