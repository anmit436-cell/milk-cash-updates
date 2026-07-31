class DeviceMetrics {
  final int batteryLevel;
  final bool isCharging;
  final double availableStorageMB;
  final String architecture;
  final int androidVersion;
  final String deviceUuid;

  DeviceMetrics({
    required this.batteryLevel,
    required this.isCharging,
    required this.availableStorageMB,
    required this.architecture,
    required this.androidVersion,
    required this.deviceUuid,
  });

  bool get isBatteryLow => batteryLevel < 15 && !isCharging;
}
