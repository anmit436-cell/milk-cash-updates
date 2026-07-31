import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import '../../providers/update_provider.dart';

class DownloadProgressCard extends StatelessWidget {
  const DownloadProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateProvider>(
      builder: (context, provider, child) {
        final state = provider.downloadState;
        
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.isPaused ? 'Paused' : 'Downloading...',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                Text(
                  '\${(state.progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.progress,
                backgroundColor: Colors.white12,
                color: AppColors.primaryBlue,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('Size', '\${state.downloadedSize} / \${state.totalSize}'),
                _buildStatColumn('Speed', state.speed),
                _buildStatColumn('Time Left', state.timeRemaining),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => provider.cancelDownload(),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text('Cancel', style: GoogleFonts.poppins()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (state.isPaused) {
                        provider.resumeDownload();
                      } else {
                        provider.pauseDownload();
                      }
                    },
                    icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause, size: 18),
                    label: Text(state.isPaused ? 'Resume' : 'Pause', style: GoogleFonts.poppins(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
