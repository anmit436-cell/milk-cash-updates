import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/update_info.dart';
import '../models/device_metrics.dart';
import '../services/update_service.dart';
import '../services/download_service.dart';
import '../services/environmental_service.dart';

enum UpdateState {
  initial,
  checking,
  available,
  downloading,
  paused,
  readyToInstall,
  maintenance,
  blocked,
  insufficientStorage,
  lowBattery,
  error,
}

class UpdateProvider with ChangeNotifier {
  final UpdateService _updateService = UpdateService();
  final DownloadService _downloadService = DownloadService();
  final EnvironmentalService _environmentalService = EnvironmentalService();

  UpdateState _state = UpdateState.initial;
  UpdateState get state => _state;

  UpdateInfo? _updateInfo;
  UpdateInfo? get updateInfo => _updateInfo;

  DeviceMetrics? _metrics;
  DeviceMetrics? get metrics => _metrics;

  DownloadState _downloadState = DownloadState();
  DownloadState get downloadState => _downloadState;

  String _releaseChannel = 'Stable';
  String get releaseChannel => _releaseChannel;

  UpdateProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _releaseChannel = prefs.getString('update_channel') ?? 'Stable';
    _downloadService.progressStream.listen((state) {
      _downloadState = state;
      if (state.hasError) {
        _setState(UpdateState.error);
      } else if (state.isCompleted) {
        _setState(UpdateState.readyToInstall);
      } else if (state.isPaused) {
        _setState(UpdateState.paused);
      } else {
        _setState(UpdateState.downloading);
      }
      notifyListeners();
    });
  }

  Future<void> setReleaseChannel(String channel) async {
    _releaseChannel = channel;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('update_channel', channel);
    notifyListeners();
    checkForUpdates(force: true);
  }

  Future<void> checkForUpdates({bool force = false}) async {
    _setState(UpdateState.checking);
    try {
      _metrics = await _environmentalService.getMetrics();
      _updateInfo = await _updateService.checkForUpdates(
        channel: _releaseChannel,
        metrics: _metrics!,
        forceCheck: force,
      );

      if (_updateInfo != null) {
        if (_updateInfo!.status == 'Maintenance') {
          _setState(UpdateState.maintenance);
        } else if (_updateInfo!.status == 'Blocked' || _updateInfo!.status == 'Deprecated') {
          _setState(UpdateState.blocked);
        } else {
          _setState(UpdateState.available);
        }
      } else {
        _setState(UpdateState.initial);
      }
    } catch (e) {
      // Don't interrupt user on network failure unless forced
      if (force) {
        _downloadState = DownloadState(hasError: true, errorMessage: 'Failed to check for updates: \$e');
        _setState(UpdateState.error);
      } else {
        _setState(UpdateState.initial);
      }
    }
  }

  Future<void> startDownload() async {
    if (_updateInfo == null || _metrics == null) return;
    
    // Environmental validation before downloading
    if (_metrics!.isBatteryLow) {
      _setState(UpdateState.lowBattery);
      return;
    }

    final double requiredSpaceMB = double.tryParse(_updateInfo!.fileSize.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 50.0;
    if (_metrics!.availableStorageMB < requiredSpaceMB * 2) {
      _setState(UpdateState.insufficientStorage);
      return;
    }

    _setState(UpdateState.downloading);
    await _downloadService.startDownload(_updateInfo!);
  }
  
  void forceDownloadAnyway() {
    _setState(UpdateState.downloading);
    if (_updateInfo != null) {
      _downloadService.startDownload(_updateInfo!);
    }
  }

  void pauseDownload() {
    _downloadService.pauseDownload();
  }

  void resumeDownload() {
    if (_updateInfo != null) {
      _downloadService.resumeDownload(_updateInfo!);
    }
  }

  void cancelDownload() {
    _downloadService.cancelDownload();
    _setState(UpdateState.available);
  }

  Future<void> installUpdate() async {
    if (_updateInfo == null) return;
    try {
      final dir = await getExternalStorageDirectory();
      final path = '${dir!.path}/update_${_updateInfo!.latestVersion}.apk';
      if (File(path).existsSync()) {
        await OpenFilex.open(path);
      } else {
        _downloadState = DownloadState(hasError: true, errorMessage: 'APK file not found.');
        _setState(UpdateState.error);
      }
    } catch (e) {
      _downloadState = DownloadState(hasError: true, errorMessage: 'Failed to install update: $e');
      _setState(UpdateState.error);
    }
  }

  void resetError() {
    if (_updateInfo != null) {
      _setState(UpdateState.available);
    } else {
      _setState(UpdateState.initial);
    }
  }

  void _setState(UpdateState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _downloadService.dispose();
    super.dispose();
  }
}
