import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color carbon950 = Color(0xFF0A0A0A);
  static const Color carbon900 = Color(0xFF1A1A1A);
  static const Color carbon800 = Color(0xFF2D2D2D);
  static const Color carbon700 = Color(0xFF3D3D3D);
  static const Color carbon600 = Color(0xFF4A4A4A);
  static const Color carbon400 = Color(0xFF8A8A8A);
  static const Color carbon200 = Color(0xFFD4D4D4);
  static const Color carbon100 = Color(0xFFE8E8E8);
  static const Color carbon50  = Color(0xFFF5F5F5);

  static const Color gold500 = Color(0xFFC9A84C);
  static const Color gold400 = Color(0xFFD4B85C);
  static const Color gold300 = Color(0xFFE0C96E);
  static const Color gold600 = Color(0xFFB8943F);
  static const Color gold100 = Color(0xFFF5ECD0);

  static const Color success = Color(0xFF4ADE80);
  static const Color danger  = Color(0xFFF87171);
  static const Color info    = Color(0xFF60A5FA);
  static const Color warning = Color(0xFFFBBF24);
}

class AppTheme {
  // Legacy — kept for backward compat
  static const Color primary = AppColors.gold500;
  static const Color textColor = AppColors.carbon100;

  static ThemeData get darkTheme {
    final inter = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.gold500,
      scaffoldBackgroundColor: AppColors.carbon900,
      textTheme: inter.copyWith(
        bodyLarge: inter.bodyLarge?.copyWith(color: AppColors.carbon100),
        bodyMedium: inter.bodyMedium?.copyWith(color: AppColors.carbon200),
        titleLarge: inter.titleLarge?.copyWith(
          color: AppColors.carbon50,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02 * 22,
        ),
        titleMedium: inter.titleMedium?.copyWith(
          color: AppColors.carbon50,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.carbon950,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.carbon50,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.36,
        ),
        iconTheme: const IconThemeData(color: AppColors.gold500),
      ),
      cardTheme: CardThemeData(
        color: AppColors.carbon800,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha:0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold500,
          foregroundColor: AppColors.carbon950,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold500,
          side: const BorderSide(color: AppColors.gold500),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.carbon800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.carbon700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.carbon700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: const TextStyle(color: AppColors.carbon400),
        labelStyle: const TextStyle(color: AppColors.carbon200),
        prefixIconColor: AppColors.carbon400,
        suffixIconColor: AppColors.carbon400,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.carbon950,
        selectedItemColor: AppColors.gold500,
        unselectedItemColor: AppColors.carbon400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.carbon700,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.carbon200),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold500,
        secondary: AppColors.gold400,
        surface: AppColors.carbon800,
        error: AppColors.danger,
        onPrimary: AppColors.carbon950,
        onSecondary: AppColors.carbon950,
        onSurface: AppColors.carbon100,
        onError: AppColors.carbon50,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.carbon800,
        contentTextStyle: GoogleFonts.inter(color: AppColors.carbon100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.gold500, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
