import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';
import 'package:mishra_milk_cash/core/widgets/glass_card.dart';
import 'package:mishra_milk_cash/core/utils/formatters.dart';
import 'package:mishra_milk_cash/models/transaction_record.dart';
import 'package:mishra_milk_cash/providers/history_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';


/// Baaki (Dues) page showing customers with outstanding amounts
class BaakiScreen extends StatefulWidget {
  const BaakiScreen({super.key});

  @override
  State<BaakiScreen> createState() => _BaakiScreenState();
}

class _BaakiScreenState extends State<BaakiScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, history, _) {
        // Build dues map from transactions
        final duesMap = _buildDuesMap(history.transactions);
        final filteredDues = _filterDues(duesMap);

        final totalOutstanding = duesMap.values.fold<int>(
          0, (sum, info) => sum + info.totalDue,
        );
        final customersWithDues = duesMap.length;

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

                  // ── Summary Cards ──
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Outstanding',
                          '₹${_formatIndian(totalOutstanding)}',
                          AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Customers with Dues',
                          customersWithDues.toString(),
                          AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Search Bar ──
                  TextField(
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search customers...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: const BorderSide(color: AppColors.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: const BorderSide(color: AppColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        borderSide: const BorderSide(
                          color: AppColors.primaryPurple, width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),

                  const SizedBox(height: 16),

                  // ── Customer Due Cards ──
                  if (filteredDues.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredDues.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCustomerDueCard(entry.key, entry.value),
                      );
                    }),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ],
        );
      },
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
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

  Widget _buildCustomerDueCard(String customer, _DueInfo info) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Name & details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${info.dueCount} dues',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          Formatters.dateShort(info.lastDate),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Due amount
              Text(
                '₹${_formatIndian(info.totalDue)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  Icons.history_outlined,
                  'View History',
                  const LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  ),
                  () {
                    // TODO: Navigate to filtered history
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  Icons.send_outlined,
                  'Send Reminder',
                  const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                  ),
                  () => _sendReminder(customer, info.totalDue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon, String label, Gradient gradient, VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No outstanding dues',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All customers have cleared their dues',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textMuted.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _sendReminder(String customer, int amount) async {
    final message = 'Hello $customer,\n\n'
        'This is a reminder from Mishra Milk Center.\n\n'
        'Your outstanding balance is\n₹${_formatIndian(amount)}\n\n'
        'Kindly clear it at your earliest convenience.\n\nThank you.';

    final encodedText = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse("whatsapp://send?text=$encodedText");
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        SharePlus.instance.share(ShareParams(text: message));
      }
    } catch (e) {
      SharePlus.instance.share(ShareParams(text: message));
    }
  }

  /// Build a map of customer → due info from transactions
  Map<String, _DueInfo> _buildDuesMap(List<TransactionRecord> transactions) {
    final Map<String, _DueInfo> dues = {};

    for (final txn in transactions) {
      if (txn.baakiTotal > 0) {
        if (dues.containsKey(txn.customerName)) {
          dues[txn.customerName]!.totalDue += txn.baakiTotal;
          dues[txn.customerName]!.dueCount++;
          if (txn.dateTime.isAfter(dues[txn.customerName]!.lastDate)) {
            dues[txn.customerName]!.lastDate = txn.dateTime;
          }
        } else {
          dues[txn.customerName] = _DueInfo(
            totalDue: txn.baakiTotal,
            dueCount: 1,
            lastDate: txn.dateTime,
          );
        }
      }
    }

    return dues;
  }

  Map<String, _DueInfo> _filterDues(Map<String, _DueInfo> dues) {
    if (_searchQuery.isEmpty) return dues;
    final query = _searchQuery.toLowerCase();
    return Map.fromEntries(
      dues.entries.where((e) => e.key.toLowerCase().contains(query)),
    );
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

class _DueInfo {
  int totalDue;
  int dueCount;
  DateTime lastDate;

  _DueInfo({
    required this.totalDue,
    required this.dueCount,
    required this.lastDate,
  });
}
