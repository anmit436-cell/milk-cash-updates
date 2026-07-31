import 'package:flutter/material.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/widgets/gradient_button.dart';

/// Bottom action buttons: Reset, Share, Save
class BottomActions extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const BottomActions({
    super.key,
    required this.onReset,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Reset Button
          Expanded(
            flex: 1,
            child: GradientButton(
              label: 'Reset',
              icon: Icons.refresh_outlined,
              height: 52,
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              ),
              onPressed: onReset,
            ),
          ),
          const SizedBox(width: 10),

          // Share Button
          Expanded(
            flex: 1,
            child: GradientButton(
              label: 'Share',
              icon: Icons.ios_share_outlined,
              height: 52,
              gradient: AppColors.shareButtonGradient,
              onPressed: onShare,
            ),
          ),
          const SizedBox(width: 10),

          // Save Button
          Expanded(
            flex: 1,
            child: GradientButton(
              label: 'Save',
              icon: Icons.save_outlined,
              height: 52,
              gradient: AppColors.saveButtonGradient,
              onPressed: onSave,
            ),
          ),
        ],
      ),
    );
  }
}
