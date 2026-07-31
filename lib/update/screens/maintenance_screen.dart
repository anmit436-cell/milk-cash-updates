import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import '../providers/update_provider.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<UpdateProvider>(
        builder: (context, provider, child) {
          final info = provider.updateInfo;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.build_circle_outlined, size: 100, color: AppColors.primaryBlue),
                const SizedBox(height: 32),
                Text(
                  'Under Maintenance',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  info?.maintenanceMessage ?? 'We are upgrading our systems to serve you better. Please check back later.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textMuted),
                ),
                if (info?.maintenanceEndTime != null) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Text('Estimated Completion', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '\${info!.maintenanceEndTime!.toLocal().toString().substring(0, 16)}',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => provider.checkForUpdates(force: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Retry Now', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
