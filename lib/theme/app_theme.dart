import 'package:flutter/material.dart';

class AppColors {
  static const rojo     = Color(0xFFE8281A);
  static const naranja  = Color(0xFFF07100);
  static const amarillo = Color(0xFFF5C400);
  static const verde    = Color(0xFF2EAF4A);
  static const cafe     = Color(0xFF5C3317);
  static const mostaza  = Color(0xFFD4860A);
  static const crema    = Color(0xFFFFF8EC);
  static const blanco   = Color(0xFFFFFDF7);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.blanco,
    colorSchemeSeed: AppColors.rojo,
    brightness: Brightness.light,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.rojo,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rojo,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cafe,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
