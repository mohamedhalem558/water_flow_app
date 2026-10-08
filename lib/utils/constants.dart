import 'package:flutter/material.dart';

class AppConstants {
  // Safe limits and thresholds
  static const double defaultSafeFlowThreshold = 25.0; // Liters per minute
  static const double maxFlowRateDisplay = 50.0; // L/min max scale
  static const double dailyVolumeQuota = 500.0; // Liters default daily budget

  // Units
  static const String flowRateUnit = 'L/min';
  static const String volumeUnit = 'L';
  static const String cubicMetersUnit = 'm³';

  // App Identity
  static const String appName = 'HydroFlow';
  static const String appTagline = 'Water Flow & Volume Monitor';

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 250);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration waveAnimationDuration = Duration(milliseconds: 2000);
}

class AppColors {
  // Brand Palette - Oceanic Theme
  static const Color oceanPrimary = Color(0xFF0284C7); // Sky Blue 600
  static const Color oceanDark = Color(0xFF0369A1); // Sky Blue 700
  static const Color cyanAccent = Color(0xFF06B6D4); // Cyan 500
  static const Color deepNavy = Color(0xFF0F172A); // Slate 900
  static const Color cardNavy = Color(0xFF1E293B); // Slate 800
  static const Color surfaceNavy = Color(0xFF182234); // Slate 850
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textLight = Color(0xFFF1F5F9); // Slate 100

  // Status Colors
  static const Color statusNormal = Color(0xFF10B981); // Emerald 500
  static const Color statusNormalBg = Color(0xFF064E3B);
  static const Color statusWarning = Color(0xFFEF4444); // Red 500
  static const Color statusWarningBg = Color(0xFF7F1D1D);
  static const Color statusCaution = Color(0xFFF59E0B); // Amber 500
  static const Color statusCautionBg = Color(0xFF78350F);

  // Gradients
  static const LinearGradient flowGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient volumeGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
