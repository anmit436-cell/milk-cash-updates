import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import '../providers/update_provider.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Diagnostics', style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<UpdateProvider>(
        builder: (context, provider, child) {
          final metrics = provider.metrics;
          final info = provider.updateInfo;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection('Device Metrics', [
                _buildRow('UUID', metrics?.deviceUuid ?? 'Unknown'),
                _buildRow('Architecture', metrics?.architecture ?? 'Unknown'),
                _buildRow('Android Version', 'API \${metrics?.androidVersion ?? "Unknown"}'),
                _buildRow('Battery', '\${metrics?.batteryLevel ?? 0}% (\${metrics?.isCharging == true ? "Charging" : "Discharging"})'),
                _buildRow('Available Storage', '\${metrics?.availableStorageMB.toStringAsFixed(2) ?? 0} MB'),
              ]),
              const SizedBox(height: 16),
              _buildSection('Update Server Info', [
                _buildRow('Status', info?.status ?? 'Unknown'),
                _buildRow('Channel', provider.releaseChannel),
                _buildRow('Latest Version', info?.latestVersion ?? 'Unknown'),
                _buildRow('Version Code', info?.versionCode.toString() ?? 'Unknown'),
                _buildRow('Force Update', info?.forceUpdate.toString() ?? 'Unknown'),
                _buildRow('Rollout %', '\${info?.rolloutPercentage ?? 0}%'),
              ]),
              const SizedBox(height: 16),
              _buildSection('Download State', [
                _buildRow('State', provider.state.name),
                _buildRow('Progress', '\${(provider.downloadState.progress * 100).toStringAsFixed(1)}%'),
                _buildRow('Speed', provider.downloadState.speed),
                _buildRow('Error', provider.downloadState.errorMessage ?? 'None'),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(color: Colors.white24, height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
          Flexible(child: Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
