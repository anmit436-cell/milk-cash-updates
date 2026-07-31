import 'package:flutter/material.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';

/// Represents a single denomination entry with its value, quantity, and color.
/// No code generation — Hive serialization handled manually via maps.
class Denomination {
  final int value;
  int quantity;
  final String label;
  final bool isCoin;
  final bool isOnline;
  final bool isBaaki;

  Denomination({
    required this.value,
    this.quantity = 0,
    required this.label,
    this.isCoin = false,
    this.isOnline = false,
    this.isBaaki = false,
  });

  /// Computed total amount for this denomination
  int get amount {
    // For coins/online/baaki, quantity IS the amount (₹1 × qty)
    if (isCoin || isOnline || isBaaki) return quantity;
    return value * quantity;
  }

  /// Get the badge color for this denomination
  Color get color {
    if (isCoin) return AppColors.denomCoins;
    if (isOnline) return AppColors.denomOnline;
    if (isBaaki) return AppColors.denomBaaki;
    switch (value) {
      case 500: return AppColors.denom500;
      case 200: return AppColors.denom200;
      case 100: return AppColors.denom100;
      case 50: return AppColors.denom50;
      case 20: return AppColors.denom20;
      case 10: return AppColors.denom10;
      default: return AppColors.primaryBlue;
    }
  }

  /// Get the badge icon for special types
  IconData get icon {
    if (isCoin) return Icons.monetization_on_outlined;
    if (isOnline) return Icons.credit_card_outlined;
    if (isBaaki) return Icons.receipt_outlined;
    return Icons.currency_rupee;
  }

  /// Display label for the badge
  String get badgeText {
    if (isCoin || isOnline || isBaaki) return '';
    return '₹$value';
  }

  /// Create a copy with a new quantity
  Denomination copyWith({int? quantity}) {
    return Denomination(
      value: value,
      quantity: quantity ?? this.quantity,
      label: label,
      isCoin: isCoin,
      isOnline: isOnline,
      isBaaki: isBaaki,
    );
  }

  /// Serialize to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'quantity': quantity,
      'label': label,
      'isCoin': isCoin,
      'isOnline': isOnline,
      'isBaaki': isBaaki,
    };
  }

  /// Deserialize from Map
  factory Denomination.fromMap(Map<String, dynamic> map) {
    return Denomination(
      value: map['value'] as int,
      quantity: map['quantity'] as int? ?? 0,
      label: map['label'] as String,
      isCoin: map['isCoin'] as bool? ?? false,
      isOnline: map['isOnline'] as bool? ?? false,
      isBaaki: map['isBaaki'] as bool? ?? false,
    );
  }

  /// Standard denomination list used in the Counter page
  static List<Denomination> defaultList() {
    return [
      Denomination(value: 500, label: '₹500'),
      Denomination(value: 200, label: '₹200'),
      Denomination(value: 100, label: '₹100'),
      Denomination(value: 50, label: '₹50'),
      Denomination(value: 20, label: '₹20'),
      Denomination(value: 10, label: '₹10'),
      Denomination(value: 1, label: 'Coins', isCoin: true),
      Denomination(value: 1, label: 'Online\nPayment', isOnline: true),
      Denomination(value: 1, label: 'Baaki (Due)', isBaaki: true),
    ];
  }
}
