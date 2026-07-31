import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/device_metrics.dart';

class EnvironmentalService {
  final Battery _battery = Battery();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  Future<DeviceMetrics> getMetrics() async {
    int batteryLevel = 100;
    bool isCharging = true;
    
    try {
      batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;
      isCharging = batteryState == BatteryState.charging || batteryState == BatteryState.full;
    } catch (e) {
      // Ignore battery errors
    }

    double availableStorageMB = 1000.0;
    try {
      final diskSpace = await DiskSpace.getFreeDiskSpace;
      if (diskSpace != null) {
        availableStorageMB = diskSpace;
      }
    } catch (e) {
      // Ignore disk errors
    }

    String architecture = 'unknown';
    int androidVersion = 21;
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      architecture = androidInfo.supportedAbis.isNotEmpty ? androidInfo.supportedAbis.first : 'unknown';
      androidVersion = androidInfo.version.sdkInt;
    } catch (e) {
      // Ignore device info errors
    }

    final prefs = await SharedPreferences.getInstance();
    String? deviceUuid = prefs.getString('device_uuid');
    if (deviceUuid == null) {
      deviceUuid = const Uuid().v4();
      await prefs.setString('device_uuid', deviceUuid);
    }

    return DeviceMetrics(
      batteryLevel: batteryLevel,
      isCharging: isCharging,
      availableStorageMB: availableStorageMB,
      architecture: architecture,
      androidVersion: androidVersion,
      deviceUuid: deviceUuid,
    );
  }
}
