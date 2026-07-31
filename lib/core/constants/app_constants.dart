/// App-wide constants for Mishra Milk Cash
class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = 'MISHRA MILK CENTER';
  static const String appSubtitle = 'CASH MANAGEMENT';
  static const String appVersion = '1.0.0';
  static const String currency = '₹';
  static const String companyName = 'Mishra Milk Center';

  // ── Spacing ──
  static const double paddingOuter = 20.0;
  static const double paddingCard = 16.0;
  static const double paddingInternal = 14.0;
  static const double paddingButton = 12.0;
  static const double spacingCard = 12.0;

  // ── Border Radius ──
  static const double radiusLarge = 22.0;
  static const double radiusMedium = 18.0;
  static const double radiusSmall = 14.0;
  static const double radiusButton = 16.0;
  static const double radiusCircle = 100.0;

  // ── Sizes ──
  static const double buttonHeight = 56.0;
  static const double inputHeight = 52.0;
  static const double denomCardHeight = 64.0;
  static const double tabBarHeight = 48.0;
  static const double appBarHeight = 80.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeSmall = 20.0;

  // ── Denomination Values ──
  static const List<int> denominationValues = [500, 200, 100, 50, 20, 10];

  // ── Animation Durations ──
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Hive Box Names ──
  static const String hiveTransactions = 'transactions';
  static const String hiveCustomers = 'customers';
  static const String hiveBaaki = 'baaki';
  static const String hiveSettings = 'settings';
}
