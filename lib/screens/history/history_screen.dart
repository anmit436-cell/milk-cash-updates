import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';
import 'package:mishra_milk_cash/core/utils/number_to_words.dart';
import 'package:mishra_milk_cash/core/widgets/glass_card.dart';
import 'package:mishra_milk_cash/core/widgets/gradient_button.dart';
import 'package:mishra_milk_cash/models/denomination.dart';
import 'package:mishra_milk_cash/models/transaction_record.dart';
import 'package:mishra_milk_cash/providers/history_provider.dart';
import 'package:mishra_milk_cash/screens/history/widgets/premium_transaction_card.dart';

/// History page showing all saved transactions
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Set<String> _expandedIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        final transactions = history.filteredTransactions;

        return Column(
          children: [
            // ── Search & Filters Header ──
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: history.showFilters
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingOuter, vertical: 8),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: history.setSearchQuery,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by name, amount, or payment type...',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.textMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  history.setSearchQuery('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.backgroundCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildDropdownFilter(
                            value: history.dateFilter,
                            items: const ['All Time', 'Today', 'Yesterday', 'Last 7 Days', 'Last 30 Days', 'This Month', 'Last Month'],
                            onChanged: (val) {
                              if (val != null) history.setDateFilter(val);
                            },
                            icon: Icons.calendar_today,
                          ),
                          const SizedBox(width: 8),
                          _buildDropdownFilter(
                            value: history.paymentFilter,
                            items: const ['All', 'Cash', 'Online', 'Mixed', 'Due'],
                            onChanged: (val) {
                              if (val != null) history.setPaymentFilter(val);
                            },
                            icon: Icons.payment,
                          ),
                          const SizedBox(width: 8),
                          _buildDropdownFilter(
                            value: history.sortBy,
                            items: const ['Latest', 'Oldest', 'Highest Amount', 'Lowest Amount', 'Customer Name'],
                            onChanged: (val) {
                              if (val != null) history.setSortBy(val);
                            },
                            icon: Icons.sort,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Summary Cards ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingOuter),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Sales',
                      _formatIndian(history.totalSales),
                      AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Today\'s Sales',
                      _formatIndian(history.todaysSales),
                      AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Action Buttons ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingOuter),
              child: Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      label: history.isSelectMode ? 'Clear Selection' : 'Select',
                      icon: Icons.check_box_outlined,
                      height: 44,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                      ),
                      onPressed: () {
                        if (history.isSelectMode) {
                          history.clearSelection();
                        } else if (transactions.isNotEmpty) {
                          history.selectAll();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (history.isSelectMode)
                    Expanded(
                      child: GradientButton(
                        label: 'Delete Selected',
                        icon: Icons.delete_outline,
                        height: 44,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF991B1B), Color(0xFFEF4444)],
                        ),
                        onPressed: () => _showBulkDeleteDialog(context, history),
                      ),
                    )
                  else
                    Expanded(
                      child: GradientButton(
                        label: 'Clear All',
                        icon: Icons.delete_outline,
                        height: 44,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF991B1B), Color(0xFFEF4444)],
                        ),
                        onPressed: transactions.isNotEmpty
                            ? () => _showClearAllDialog(context, history)
                            : null,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Transaction List ──
            Expanded(
              child: transactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: transactions.length,
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 80),
                      itemBuilder: (context, index) {
                        final txn = transactions[index];
                        final number = history.getTransactionNumber(txn.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PremiumTransactionCard(
                            transaction: txn,
                            number: number,
                            isExpanded: _expandedIds.contains(txn.id),
                            isSelected: history.selectedIds.contains(txn.id),
                            isSelectionMode: history.isSelectMode,
                            onTap: () {
                              if (history.isSelectMode) {
                                history.toggleSelect(txn.id);
                              } else {
                                setState(() {
                                  if (_expandedIds.contains(txn.id)) {
                                    _expandedIds.remove(txn.id);
                                  } else {
                                    _expandedIds.add(txn.id);
                                  }
                                });
                              }
                            },
                            onLongPress: () => history.toggleSelect(txn.id),
                            onEdit: () => _editTransaction(context, txn),
                            onShare: () => _shareTransaction(txn),
                            onDownloadPdf: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('PDF generation coming soon!'),
                                  backgroundColor: AppColors.surface,
                                ),
                              );
                            },
                            onDelete: () => _softDeleteWithUndo(context, txn, history),
                            onDuplicate: () => history.duplicateTransaction(txn.id),
                            onFavorite: () => history.toggleFavorite(txn.id),
                          ),
                        ).animate(delay: (index * 40).ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownFilter({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
          dropdownColor: AppColors.backgroundCard,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 14, color: AppColors.primaryPurple),
                  const SizedBox(width: 8),
                  Text(item),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      gradient: LinearGradient(
        colors: [
          accent.withValues(alpha: 0.15),
          AppColors.surface.withValues(alpha: 0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹$value',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isSearching = _searchController.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              isSearching ? Icons.search_off_rounded : Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? 'No Search Results' : 'No Transactions Yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching 
                ? 'Try adjusting your search or filters'
                : 'Your saved transactions will appear here.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _softDeleteWithUndo(BuildContext context, TransactionRecord txn, HistoryProvider history) {
    history.softDeleteTransaction(txn.id);
    _expandedIds.remove(txn.id);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${txn.customerName}\'s transaction deleted.'),
        backgroundColor: AppColors.backgroundCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryBlue,
          onPressed: () {
            history.restoreTransaction(txn.id);
          },
        ),
      ),
    );
  }

  void _showBulkDeleteDialog(BuildContext context, HistoryProvider history) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text('Delete Selected?', style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          'Delete ${history.selectedIds.length} transactions?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              history.deleteSelected();
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, HistoryProvider history) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text('Clear All History?', style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          'This will permanently delete all transaction history. This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              history.clearAll();
              Navigator.pop(ctx);
            },
            child: Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _editTransaction(BuildContext context, TransactionRecord txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditTransactionSheet(
        transaction: txn,
        onSave: (updated) {
          context.read<HistoryProvider>().updateTransaction(updated);
          Navigator.pop(ctx);
          setState(() {
            _expandedIds.remove(txn.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text('Transaction updated!'),
                ],
              ),
              backgroundColor: AppColors.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _shareTransaction(TransactionRecord txn) async {
    final dt = txn.dateTime;
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[dt.weekday - 1];
    final date = '${dt.day}/${dt.month}/${dt.year}';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')} $amPm';

    // Calculate notes count
    int notesCount = 0;
    for (final d in txn.denominations) {
      if (!d.isCoin && !d.isOnline && !d.isBaaki) {
        notesCount += d.quantity;
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('*MISHRA CASH COUNTER*');
    buffer.writeln('*CASH MANAGEMENT*');
    buffer.writeln('');
    buffer.writeln('🧑 *Customer:* ${txn.customerName}');
    buffer.writeln('');
    buffer.writeln('📅 *Day:* $dayName');
    buffer.writeln('');
    buffer.writeln('📅 *Date:* $date');
    buffer.writeln('');
    buffer.writeln('🕐 *Time:* $time');
    buffer.writeln('');

    buffer.writeln('💰 *NOTE BREAKDOWN:*');
    for (final d in txn.denominations) {
      if (d.quantity > 0 && !d.isCoin && !d.isOnline && !d.isBaaki) {
        buffer.writeln('₹${d.value} x ${d.quantity} = ₹${d.amount}');
      }
    }
    buffer.writeln('');

    if (txn.coinsTotal > 0) {
      buffer.writeln('🪙 *COINS:*');
      buffer.writeln('Coins = ₹${txn.coinsTotal}');
      buffer.writeln('');
    }

    if (txn.onlineTotal > 0) {
      buffer.writeln('💳 *ONLINE PAYMENT:*');
      buffer.writeln('Digital Payment = ₹${txn.onlineTotal}');
      buffer.writeln('');
    }

    if (txn.baakiTotal > 0) {
      buffer.writeln('📋 *BAAKI (DUE):*');
      buffer.writeln('Due Amount = ₹${txn.baakiTotal}');
      buffer.writeln('');
    }

    buffer.writeln('💵 *Total Notes Count:* $notesCount Notes');
    buffer.writeln('');
    buffer.writeln('💰 *Grand Total:* ₹${txn.grandTotal}');
    if (txn.amountInWords.isNotEmpty) {
      buffer.writeln('(${txn.amountInWords})');
    }
    buffer.writeln('');
    buffer.writeln('Thank you for your business! 🙏');

    final text = buffer.toString();
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
}

/// Full-screen edit sheet that looks like the Counter page
class _EditTransactionSheet extends StatefulWidget {
  final TransactionRecord transaction;
  final ValueChanged<TransactionRecord> onSave;

  const _EditTransactionSheet({
    required this.transaction,
    required this.onSave,
  });

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late List<Denomination> _denominations;
  late TextEditingController _customerController;
  late List<TextEditingController> _qtyControllers;

  @override
  void initState() {
    super.initState();
    _denominations = widget.transaction.denominations
        .map((d) => d.copyWith())
        .toList();
    _customerController = TextEditingController(
      text: widget.transaction.customerName,
    );
    _qtyControllers = _denominations.map((d) {
      return TextEditingController(text: d.quantity.toString());
    }).toList();
  }

  @override
  void dispose() {
    _customerController.dispose();
    for (final c in _qtyControllers) {
      c.dispose();
    }
    super.dispose();
  }

  int get _grandTotal {
    int total = 0;
    for (final d in _denominations) {
      total += d.amount;
    }
    return total;
  }


  String get _paymentType {
    bool hasCash = false;
    bool hasOnline = false;
    for (final d in _denominations) {
      if (!d.isCoin && !d.isOnline && !d.isBaaki && d.quantity > 0) hasCash = true;
      if (d.isCoin && d.quantity > 0) hasCash = true;
      if (d.isOnline && d.quantity > 0) hasOnline = true;
    }
    if (hasCash && hasOnline) return 'Mixed';
    if (hasOnline) return 'Online';
    return 'Cash';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle Bar ──
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Edit Transaction',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // ── Scrollable Content ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // Customer name
                TextField(
                  controller: _customerController,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppColors.textMuted, size: 20),
                    filled: true,
                    fillColor: AppColors.backgroundCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primaryPurple, width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Denomination rows
                ...List.generate(_denominations.length, (index) {
                  final d = _denominations[index];
                  final isSpecial = d.isCoin || d.isOnline || d.isBaaki;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        // Badge
                        Container(
                          width: 40,
                          height: 30,
                          decoration: BoxDecoration(
                            color: d.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: d.color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Center(
                            child: isSpecial
                                ? Icon(d.icon, color: d.color, size: 16)
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: Text(
                                        d.badgeText,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: d.color,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Label
                        SizedBox(
                          width: 46,
                          child: Text(
                            d.label,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: d.color,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Minus
                        GestureDetector(
                          onTap: () {
                            if (d.quantity > 0) {
                              setState(() {
                                d.quantity--;
                                _qtyControllers[index].text =
                                    d.quantity.toString();
                              });
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.buttonMinus.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.buttonMinus.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Icon(Icons.remove,
                                color: AppColors.buttonMinus, size: 16),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Quantity input
                        SizedBox(
                          width: 56,
                          height: 36,
                          child: TextField(
                            controller: _qtyControllers[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(7),
                            ],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 4,
                              ),
                              filled: true,
                              fillColor: AppColors.backgroundCard,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryPurple, width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                d.quantity = int.tryParse(val) ?? 0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Plus
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              d.quantity++;
                              _qtyControllers[index].text =
                                  d.quantity.toString();
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.buttonPlus.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.buttonPlus.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Icon(Icons.add,
                                color: AppColors.buttonPlus, size: 16),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Amount
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              '₹${d.amount}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // Grand total
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.grandTotalGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹$_grandTotal',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // ── Save Button ──
          Padding(
            padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 12,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Calculate totals
                  int notesTotal = 0;
                  int coinsTotal = 0;
                  int onlineTotal = 0;
                  int baakiTotal = 0;
                  for (final d in _denominations) {
                    if (d.isCoin) {
                      coinsTotal = d.quantity;
                    } else if (d.isOnline) {
                      onlineTotal = d.quantity;
                    } else if (d.isBaaki) {
                      baakiTotal = d.quantity;
                    } else {
                      notesTotal += d.amount;
                    }
                  }

                  final updated = widget.transaction.copyWith(
                    customerName: _customerController.text.isEmpty
                        ? 'Customer'
                        : _customerController.text,
                    denominations: _denominations,
                    notesTotal: notesTotal,
                    coinsTotal: coinsTotal,
                    onlineTotal: onlineTotal,
                    baakiTotal: baakiTotal,
                    grandTotal: _grandTotal,
                    amountInWords: _grandTotal > 0
                        ? NumberToWords.convert(_grandTotal)
                        : '',
                    paymentType: _paymentType,
                  );
                  widget.onSave(updated);
                },
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  'Save Changes',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
