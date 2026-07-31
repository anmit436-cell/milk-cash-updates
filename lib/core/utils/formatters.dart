import 'package:intl/intl.dart';

/// Currency and date formatting utilities
class Formatters {
  Formatters._();

  /// Format number as Indian currency: ₹1,23,456
  static String currency(num amount) {
    if (amount == 0) return '₹0';
    
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    
    // Indian number system formatting
    final String formatted;
    if (absAmount >= 100000) {
      // Format lakhs and above
      final lakhs = absAmount ~/ 100000;
      final remainder = absAmount % 100000;
      if (remainder == 0) {
        formatted = '${_formatWithCommas(lakhs)},00,000';
      } else {
        final remainderStr = remainder.toInt().toString().padLeft(5, '0');
        final lastThree = remainderStr.substring(2);
        final middle = remainderStr.substring(0, 2);
        if (int.parse(middle) == 0) {
          formatted = '${_formatWithCommas(lakhs)},00,$lastThree';
        } else {
          formatted = '${_formatWithCommas(lakhs)},${middle.replaceAll(RegExp(r'^0+'), '')},$lastThree';
        }
      }
    } else {
      formatted = _indianFormat(absAmount.toInt());
    }
    
    return isNegative ? '-₹$formatted' : '₹$formatted';
  }

  static String _indianFormat(int number) {
    if (number < 1000) return number.toString();
    
    final lastThree = (number % 1000).toString().padLeft(3, '0');
    int remaining = number ~/ 1000;
    
    String result = lastThree;
    while (remaining > 0) {
      final part = remaining % 100;
      remaining ~/= 100;
      result = '$part,$result';
    }
    
    // Remove leading zeros from first group
    return result.replaceFirst(RegExp(r'^0+'), '');
  }

  static String _formatWithCommas(num n) {
    return n.toInt().toString();
  }

  /// Format date as "21 Jul 2026"
  static String date(DateTime dt) {
    return DateFormat('dd MMM yyyy').format(dt);
  }

  /// Format time as "12:44"
  static String time(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }

  /// Format date and time as "21 Jul 2026, 12:44"
  static String dateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  /// Format as compact date "21 Jul"
  static String dateShort(DateTime dt) {
    return DateFormat('dd MMM').format(dt);
  }
}
