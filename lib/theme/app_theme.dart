import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepNavy,
      primaryColor: AppColors.oceanPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.oceanPrimary,
        secondary: AppColors.cyanAccent,
        surface: AppColors.cardNavy,
        error: AppColors.statusWarning,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textLight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardNavy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceNavy,
        selectedItemColor: AppColors.cyanAccent,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.cyanAccent,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.cyanAccent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardNavy,
        selectedColor: AppColors.oceanPrimary.withValues(alpha: 0.25),
        labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textLight,
          fontSize: 44,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          color: AppColors.textLight,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.textLight,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textLight,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
        ),
      ),
    );
  }

  // Custom Glassmorphism Box Decoration
  static BoxDecoration glassCardDecoration({
    Color? baseColor,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: baseColor ?? AppColors.cardNavy.withValues(alpha: 0.85),
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: border ??
          Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration glowCardDecoration({
    required Color glowColor,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.cardNavy,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: glowColor.withValues(alpha: 0.4),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
