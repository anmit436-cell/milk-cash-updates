import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import '../providers/update_provider.dart';
import 'widgets/download_progress_card.dart';
import 'widgets/release_history_card.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateProvider>(
      builder: (context, provider, child) {
        final info = provider.updateInfo;
        if (info == null) return const SizedBox.shrink();

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundCard.withValues(alpha: 0.95),
                  AppColors.backgroundCard.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.system_update_rounded, color: AppColors.primaryBlue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update Available',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Version ${info.latestVersion}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                if (provider.state == UpdateState.available) ...[
                  Text(
                    "What's New",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200, // Fixed height for scrollable release notes
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: info.categorizedChangelog.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ReleaseHistoryCard(
                              category: entry.key,
                              items: entry.value,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (!info.forceUpdate)
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textMuted,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Later',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      if (!info.forceUpdate) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => provider.startDownload(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Update Now (${info.fileSize})',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (provider.state == UpdateState.lowBattery) ...[
                   _buildWarningState(
                     context: context,
                     provider: provider,
                     icon: Icons.battery_alert,
                     title: 'Low Battery',
                     message: 'Your battery is below 15%. Downloading might drain it further. Please connect to a charger or download later.',
                     actionText: 'Download Anyway',
                     onAction: () => provider.forceDownloadAnyway(),
                   ),
                ] else if (provider.state == UpdateState.insufficientStorage) ...[
                   _buildWarningState(
                     context: context,
                     provider: provider,
                     icon: Icons.storage,
                     title: 'Storage Full',
                     message: 'You need at least ${info.fileSize} x 2 of free space to download and install this update.',
                     actionText: 'Check Again',
                     onAction: () => provider.startDownload(),
                   ),
                ] else if (provider.state == UpdateState.error) ...[
                   _buildWarningState(
                     context: context,
                     provider: provider,
                     icon: Icons.error_outline,
                     title: 'Update Failed',
                     message: provider.downloadState.errorMessage ?? 'An unknown error occurred.',
                     actionText: 'Retry',
                     onAction: () => provider.resetError(),
                   ),
                ] else if (provider.state == UpdateState.readyToInstall) ...[
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Update Ready!',
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => provider.installUpdate(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Install Now', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const DownloadProgressCard(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningState({
    required BuildContext context,
    required UpdateProvider provider,
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 50),
        const SizedBox(height: 12),
        Text(title, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  if (provider.updateInfo?.forceUpdate == false) {
                     Navigator.pop(context);
                  } else {
                     provider.resetError();
                  }
                },
                child: Text(provider.updateInfo?.forceUpdate == false ? 'Cancel' : 'Back', style: GoogleFonts.poppins()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(actionText, style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
