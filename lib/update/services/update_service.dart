import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/update_info.dart';
import '../models/device_metrics.dart';
import '../repositories/update_repository.dart';

class UpdateService {
  final UpdateRepository _repository = UpdateRepository();

  // Exponential backoff configurations
  int _retryCount = 0;
  final List<int> _backoffDelays = [5, 15, 30]; 

  Future<UpdateInfo?> checkForUpdates({
    required String channel, 
    required DeviceMetrics metrics,
    bool forceCheck = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Always check for updates on launch as requested
    final lastCheckStr = prefs.getString('last_update_check');

    UpdateInfo? updateInfo = await _fetchWithRetries(channel);
    
    if (updateInfo != null) {
      await prefs.setString('last_update_check', DateTime.now().toIso8601String());
      
      // Maintenance check
      if (updateInfo.status == 'Maintenance') {
        return updateInfo; // Provider will handle showing maintenance UI
      }
      
      // Rollout check
      if (!_isDeviceInRollout(metrics.deviceUuid, updateInfo.rolloutPercentage)) {
        return null; // Skip this device for now
      }

      // Schedule check
      if (updateInfo.scheduledReleaseDate != null && DateTime.now().isBefore(updateInfo.scheduledReleaseDate!)) {
        return null; // Not released yet
      }

      // Block check
      if (updateInfo.status == 'Blocked' || updateInfo.status == 'Deprecated') {
         return updateInfo; // Provider handles blocked screens
      }
      
      // Version and Compatibility check
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isVersionGreater(updateInfo.latestVersion, currentVersion)) {
        if (_isCompatible(updateInfo, metrics, packageInfo)) {
          return updateInfo;
        }
      } else if (updateInfo.status == 'Rollback' && updateInfo.latestVersion != currentVersion) {
         return updateInfo; // Support offering rollbacks
      }
    }

    return null;
  }

  Future<UpdateInfo?> _fetchWithRetries(String channel) async {
    _retryCount = 0;
    while (_retryCount <= _backoffDelays.length) {
      final info = await _repository.fetchUpdateInfo(channel: channel);
      if (info != null) return info;
      
      if (_retryCount < _backoffDelays.length) {
        await Future.delayed(Duration(seconds: _backoffDelays[_retryCount]));
      }
      _retryCount++;
    }
    return null;
  }

  bool _isDeviceInRollout(String uuid, int percentage) {
    if (percentage >= 100) return true;
    if (percentage <= 0) return false;
    // Calculate a consistent integer from the UUID hash
    final bytes = utf8.encode(uuid);
    final digest = sha256.convert(bytes);
    int sum = 0;
    for (var b in digest.bytes) {
      sum += b;
    }
    return (sum % 100) < percentage;
  }

  bool _isCompatible(UpdateInfo info, DeviceMetrics metrics, PackageInfo pkg) {
    // Basic checks
    if (info.packageName.isNotEmpty && info.packageName != pkg.packageName) return false;
    if (metrics.androidVersion < info.minAndroidVersion) return false;
    if (metrics.androidVersion > info.maxAndroidVersion) return false;
    // If architecture list is empty, assume all are supported
    if (info.supportedArchitectures.isNotEmpty && !info.supportedArchitectures.contains(metrics.architecture)) {
      return false;
    }
    return true;
  }

  bool _isVersionGreater(String newVersion, String currentVersion) {
    List<int> v1 = newVersion.split('.').map(int.parse).toList();
    List<int> v2 = currentVersion.split('.').map(int.parse).toList();
    for (int i = 0; i < v1.length && i < v2.length; i++) {
      if (v1[i] > v2[i]) return true;
      if (v1[i] < v2[i]) return false;
    }
    return v1.length > v2.length;
  }
}
