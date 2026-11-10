
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF16383B);
  static const Color accent = Color(0xFF007F73);
  static const Color support = Color(0xFFE1F0EB);
  static const Color background = Color(0xFFF5F8F7);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
    );
  }
}
