import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/update_info.dart';

class DownloadState {
  final double progress;
  final String speed;
  final String downloadedSize;
  final String totalSize;
  final String timeRemaining;
  final bool isPaused;
  final bool isCompleted;
  final bool hasError;
  final String? errorMessage;

  DownloadState({
    this.progress = 0.0,
    this.speed = '0 B/s',
    this.downloadedSize = '0 B',
    this.totalSize = '0 B',
    this.timeRemaining = '--:--',
    this.isPaused = false,
    this.isCompleted = false,
    this.hasError = false,
    this.errorMessage,
  });
}

class DownloadService {
  final Dio _dio = Dio();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  CancelToken? _cancelToken;
  StreamSubscription? _connectivitySub;
  String? _savePath;
  int _downloadedBytes = 0;
  
  StreamController<DownloadState> _progressController = StreamController<DownloadState>.broadcast();
  Stream<DownloadState> get progressStream => _progressController.stream;

  DateTime? _lastUpdate;
  int _lastBytes = 0;

  DownloadService() {
    _initNotifications();
  }

  void _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> startDownload(UpdateInfo info) async {
    try {
      _cancelToken = CancelToken();
      final dir = await getExternalStorageDirectory();
      _savePath = '${dir!.path}/update_${info.latestVersion}.apk';

      _checkExistingFile();
      
      _progressController.add(DownloadState(isPaused: false));
      
      // Auto pause/resume on connection change
      _connectivitySub = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
        if (results.contains(ConnectivityResult.none)) {
          pauseDownload();
        } else {
          if (_cancelToken?.isCancelled ?? false) {
             resumeDownload(info);
          }
        }
      });

      await _doDownload(info.apkUrl);
      
      // Verify SHA256 in isolate
      final isValid = await compute(_verifySha256, {'path': _savePath!, 'expectedHash': info.sha256});
      if (isValid) {
        _progressController.add(DownloadState(isCompleted: true, progress: 1.0));
        _showNotification('Update Ready', 'Version ${info.latestVersion} is ready to install', 100, false);
      } else {
        File(_savePath!).deleteSync();
        _progressController.add(DownloadState(hasError: true, errorMessage: 'Corrupted APK downloaded. Hash mismatch.'));
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        _progressController.add(DownloadState(isPaused: true, progress: _downloadedBytes / 1000000)); // Rough progress
      } else {
        _progressController.add(DownloadState(hasError: true, errorMessage: e.toString()));
      }
    }
  }
  
  void _checkExistingFile() {
    if (File(_savePath!).existsSync()) {
      _downloadedBytes = File(_savePath!).lengthSync();
    } else {
      _downloadedBytes = 0;
    }
  }

  Future<void> _doDownload(String url) async {
    Options options = Options(
      responseType: ResponseType.stream,
    );
    
    if (_downloadedBytes > 0) {
      options.headers = {'range': 'bytes=$_downloadedBytes-'};
    }

    final response = await _dio.get(url, options: options, cancelToken: _cancelToken);
    
    final raf = File(_savePath!).openSync(mode: FileMode.append);
    final stream = response.data.stream;
    
    int totalBytes = _downloadedBytes + (int.tryParse(response.headers.value(HttpHeaders.contentLengthHeader) ?? '0') ?? 0);
    
    _lastUpdate = DateTime.now();
    _lastBytes = _downloadedBytes;

    await for (final chunk in stream) {
      if (_cancelToken!.isCancelled) {
        raf.closeSync();
        return;
      }
      raf.writeFromSync(chunk);
      _downloadedBytes += (chunk as List<int>).length;
      
      _calculateAndEmitProgress(_downloadedBytes, totalBytes);
    }
    
    raf.closeSync();
  }

  void _calculateAndEmitProgress(int downloaded, int total) {
    final now = DateTime.now();
    if (_lastUpdate != null) {
      final diff = now.difference(_lastUpdate!).inMilliseconds;
      if (diff > 500) { // Update every 500ms
        final bytesSinceLast = downloaded - _lastBytes;
        final speedBps = (bytesSinceLast / (diff / 1000)).round();
        final speedStr = (speedBps / 1048576).toStringAsFixed(1) + ' MB/s';
        
        final progress = downloaded / total;
        final remainingBytes = total - downloaded;
        final timeRemainingSeconds = speedBps > 0 ? (remainingBytes / speedBps).round() : 0;
        
        _progressController.add(DownloadState(
          progress: progress,
          speed: speedStr,
          downloadedSize: (downloaded / 1048576).toStringAsFixed(1) + ' MB',
          totalSize: (total / 1048576).toStringAsFixed(1) + ' MB',
          timeRemaining: '${timeRemainingSeconds ~/ 60}:${(timeRemainingSeconds % 60).toString().padLeft(2, '0')}',
        ));
        
        _showNotification('Downloading Update', '${(progress * 100).toInt()}% • $speedStr', (progress * 100).toInt(), true);
        
        _lastUpdate = now;
        _lastBytes = downloaded;
      }
    } else {
      _lastUpdate = now;
      _lastBytes = downloaded;
    }
  }

  void pauseDownload() {
    _cancelToken?.cancel();
  }

  void resumeDownload(UpdateInfo info) {
    startDownload(info);
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    if (_savePath != null && File(_savePath!).existsSync()) {
      File(_savePath!).deleteSync();
    }
    _progressController.add(DownloadState(hasError: true, errorMessage: 'Cancelled by user'));
  }

  void dispose() {
    _connectivitySub?.cancel();
    _progressController.close();
  }

  Future<void> _showNotification(String title, String body, int progress, bool showProgress) async {
    final androidDetails = AndroidNotificationDetails(
      'update_channel',
      'App Updates',
      channelDescription: 'Notifications for app updates',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: showProgress,
      maxProgress: 100,
      progress: progress,
      ongoing: showProgress,
    );
    final details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(0, title, body, details);
  }

  static Future<bool> _verifySha256(Map<String, dynamic> args) async {
    final path = args['path'] as String;
    final expectedHash = args['expectedHash'] as String;
    
    if (expectedHash.isEmpty) return true; // Skip if no hash provided

    final file = File(path);
    if (!file.existsSync()) return false;
    
    final hash = await sha256.bind(file.openRead()).first;
    return hash.toString().toLowerCase() == expectedHash.toLowerCase();
  }
}
