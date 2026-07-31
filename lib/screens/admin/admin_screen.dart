import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';
import 'package:mishra_milk_cash/core/constants/app_constants.dart';
import 'package:mishra_milk_cash/services/hive_service.dart';

import 'package:mishra_milk_cash/update/screens/diagnostics_screen.dart';
import 'package:provider/provider.dart';
import 'package:mishra_milk_cash/update/providers/update_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<String> _qrList = [];
  final ImagePicker _picker = ImagePicker();
  String _currentVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadQrs();
    _loadVersion();
  }

  void _loadQrs() {
    setState(() {
      _qrList = HiveService.getBankQrs();
    });
  }
  
  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = '${info.version} (${info.buildNumber})';
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        final base64String = base64Encode(bytes);
        
        final List<String> newList = List.from(_qrList)..add(base64String);
        await HiveService.saveBankQrs(newList);
        _loadQrs();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('QR Code uploaded successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading QR: \$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteQr(int index) async {
    final List<String> newList = List.from(_qrList)..removeAt(index);
    await HiveService.saveBankQrs(newList);
    _loadQrs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Admin Settings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingOuter),
        children: [
          // UPDATE SETTINGS
          Text(
            'System Updates',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Consumer<UpdateProvider>(
              builder: (context, updateProvider, _) {
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                      title: Text('Current Version', style: GoogleFonts.poppins(color: Colors.white)),
                      trailing: Text(_currentVersion, style: GoogleFonts.poppins(color: AppColors.textMuted)),
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cloud_download_outlined, color: AppColors.primaryBlue),
                      title: Text('Release Channel', style: GoogleFonts.poppins(color: Colors.white)),
                      trailing: DropdownButton<String>(
                        value: updateProvider.releaseChannel,
                        dropdownColor: AppColors.backgroundCard,
                        underline: const SizedBox(),
                        style: GoogleFonts.poppins(color: AppColors.textPrimary),
                        items: ['Stable', 'Beta', 'Internal'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) updateProvider.setReleaseChannel(val);
                        },
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.system_update_alt, color: AppColors.primaryBlue),
                      title: Text('Check for Updates', style: GoogleFonts.poppins(color: Colors.white)),
                      trailing: updateProvider.state == UpdateState.checking
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : ElevatedButton(
                              onPressed: () => updateProvider.checkForUpdates(force: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Check'),
                            ),
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.bug_report_outlined, color: Colors.orangeAccent),
                      title: Text('System Diagnostics', style: GoogleFonts.poppins(color: Colors.white)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticsScreen()));
                      },
                    ),
                  ],
                );
              }
            ),
          ),
          const SizedBox(height: 32),
          
          // QR SETTINGS
          Text(
            'QR Codes',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: const Text('Upload Bank QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_qrList.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No QR codes uploaded yet.',
                  style: GoogleFonts.poppins(color: AppColors.textMuted),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _qrList.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.memory(
                            base64Decode(_qrList[index]),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: AppColors.glassBorder)),
                        ),
                        child: TextButton.icon(
                          onPressed: () => _deleteQr(index),
                          icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                          label: Text(
                            'Delete',
                            style: GoogleFonts.poppins(color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

