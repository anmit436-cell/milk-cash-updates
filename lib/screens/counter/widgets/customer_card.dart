import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';
import 'package:mishra_milk_cash/core/widgets/glass_card.dart';
import 'package:mishra_milk_cash/providers/counter_provider.dart';
import 'package:mishra_milk_cash/services/hive_service.dart';

/// Customer name input card with dropdown search
class CustomerCard extends StatefulWidget {
  const CustomerCard({super.key});

  @override
  State<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;
  List<String> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _controller.text.toLowerCase();
    final customers = HiveService.getCustomers();
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = customers;
      } else {
        _filteredCustomers = customers
            .where((c) => c.toLowerCase().contains(query))
            .toList();
      }
    });

    // Update provider
    context.read<CounterProvider>().setCustomerName(_controller.text);
  }

  void _toggleDropdown() {
    setState(() {
      _showDropdown = !_showDropdown;
      if (_showDropdown) {
        _filteredCustomers = HiveService.getCustomers();
      }
    });
  }

  void _selectCustomer(String name) {
    _controller.text = name;
    setState(() => _showDropdown = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Customer Name (Optional)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Input Field with Dropdown ──
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter customer name...',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundCard,
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
                        color: AppColors.primaryPurple,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Dropdown toggle
              GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: AnimatedRotation(
                    turns: _showDropdown ? 0.5 : 0,
                    duration: AppConstants.animFast,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Dropdown List ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildDropdownList(),
            crossFadeState: _showDropdown
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppConstants.animFast,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownList() {
    if (_filteredCustomers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'No saved customers',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _filteredCustomers.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _selectCustomer(_filteredCustomers[index]),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                _filteredCustomers[index],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
