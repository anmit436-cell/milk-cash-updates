class UpdateInfo {
  final String latestVersion;
  final int versionCode;
  final String minimumVersion;
  final String apkUrl;
  final String fileSize;
  final String sha256;
  final String packageName;
  final String status; // Active, Deprecated, Blocked, Rollback, Maintenance
  final bool forceUpdate;
  final int rolloutPercentage;
  final String releaseChannel; // Stable, Beta, Internal
  final Map<String, List<String>> categorizedChangelog;
  
  // Device Compatibility
  final int minAndroidVersion;
  final int maxAndroidVersion;
  final List<String> supportedArchitectures;
  final int minFreeStorageMB;

  // Maintenance & Scheduling
  final String? maintenanceMessage;
  final DateTime? maintenanceEndTime;
  final DateTime? scheduledReleaseDate;

  // Modular Downloads
  final Map<String, String>? modularDownloads;

  UpdateInfo({
    required this.latestVersion,
    required this.versionCode,
    required this.minimumVersion,
    required this.apkUrl,
    required this.fileSize,
    required this.sha256,
    required this.packageName,
    required this.status,
    required this.forceUpdate,
    required this.rolloutPercentage,
    required this.releaseChannel,
    required this.categorizedChangelog,
    required this.minAndroidVersion,
    required this.maxAndroidVersion,
    required this.supportedArchitectures,
    required this.minFreeStorageMB,
    this.maintenanceMessage,
    this.maintenanceEndTime,
    this.scheduledReleaseDate,
    this.modularDownloads,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latestVersion'] ?? '1.0.0',
      versionCode: json['versionCode'] ?? 1,
      minimumVersion: json['minimumVersion'] ?? '1.0.0',
      apkUrl: json['apkUrl'] ?? '',
      fileSize: json['fileSize'] ?? '0 MB',
      sha256: json['sha256'] ?? '',
      packageName: json['packageName'] ?? '',
      status: json['status'] ?? 'Active',
      forceUpdate: json['forceUpdate'] ?? false,
      rolloutPercentage: json['rolloutPercentage'] ?? 100,
      releaseChannel: json['releaseChannel'] ?? 'Stable',
      categorizedChangelog: (json['categorizedChangelog'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ?? {},
      minAndroidVersion: json['minAndroidVersion'] ?? 21,
      maxAndroidVersion: json['maxAndroidVersion'] ?? 99,
      supportedArchitectures: List<String>.from(json['supportedArchitectures'] ?? []),
      minFreeStorageMB: json['minFreeStorageMB'] ?? 50,
      maintenanceMessage: json['maintenanceMessage'],
      maintenanceEndTime: json['maintenanceEndTime'] != null ? DateTime.tryParse(json['maintenanceEndTime']) : null,
      scheduledReleaseDate: json['scheduledReleaseDate'] != null ? DateTime.tryParse(json['scheduledReleaseDate']) : null,
      modularDownloads: (json['modularDownloads'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
    );
  }
}
