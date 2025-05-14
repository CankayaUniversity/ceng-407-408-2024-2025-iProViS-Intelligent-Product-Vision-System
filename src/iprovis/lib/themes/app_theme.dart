import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF6750A4),
      secondary: const Color(0xFF03DAC6),
      surface: const Color(0xFFF0F0F0),
      background: const Color(0xFFF5F5F5),
      error: const Color(0xFFB00020),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF6750A4),
      secondary: const Color(0xFF03DAC6),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      error: const Color(0xFFCF6679),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2C2C2C),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF6750A4),
        side: const BorderSide(color: Color(0xFF6750A4)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}