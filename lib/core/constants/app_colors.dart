import 'package:flutter/material.dart';

/// Premium color palette for Mishra Milk Cash
/// Deep navy backgrounds with blue-purple accents and glassmorphism effects
class AppColors {
  AppColors._();

  // ── Background ──
  static const Color background = Color(0xFF0A0E21);
  static const Color backgroundLight = Color(0xFF0D1333);
  static const Color backgroundCard = Color(0xFF111638);
  static const Color surface = Color(0xFF151A3A);
  static const Color surfaceLight = Color(0xFF1A2044);

  // ── Primary Gradient ──
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPink = Color(0xFFD946EF);
  static const Color accentCyan = Color(0xFF06B6D4);

  // ── Text ──
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textAccent = Color(0xFFA78BFA);

  // ── Denomination Badge Colors ──
  static const Color denom500 = Color(0xFF8B5CF6);
  static const Color denom200 = Color(0xFF22C55E);
  static const Color denom100 = Color(0xFF3B82F6);
  static const Color denom50 = Color(0xFFEAB308);
  static const Color denom20 = Color(0xFFF97316);
  static const Color denom10 = Color(0xFFEF4444);
  static const Color denomCoins = Color(0xFFF59E0B);
  static const Color denomOnline = Color(0xFF06B6D4);
  static const Color denomBaaki = Color(0xFFEF4444);

  // ── Action Colors ──
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Glass Effects ──
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color glassBackground = Color(0x0DFFFFFF);
  static const Color glassSurface = Color(0x0AFFFFFF);

  // ── Button Colors ──
  static const Color buttonMinus = Color(0xFFEF4444);
  static const Color buttonPlus = Color(0xFF22C55E);
  static const Color buttonReset = Color(0xFF334155);
  static const Color buttonShare = Color(0xFF6366F1);
  static const Color buttonSave = Color(0xFF8B5CF6);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF151A3A), Color(0xFF1A1040)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient grandTotalGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFD946EF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient tabSelectedGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient shareButtonGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient saveButtonGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFD946EF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFF0D0A2E), backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient summaryGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF1A1040)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
