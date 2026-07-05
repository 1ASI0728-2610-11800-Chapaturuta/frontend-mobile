import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Soft-purple, light "SaaS" identity.
///
/// The palette keeps its historical field names so the whole app re-skins from here,
/// but the meaning is semantic, not literal:
///   • `carbon*` is a light neutral scale — HIGH numbers are the lightest surfaces
///     (backgrounds, app bar, cards, and the contrast foreground on accent buttons),
///     LOW numbers are the darkest text. (This is the light-theme inversion of the
///     old dark scale, which is why every screen flips cleanly.)
///   • `gold*` is the soft-violet accent used for primary actions, icons and highlights.
class AppColors {
  // Light neutral scale (violet-tinted). 950 = brightest surface … 50 = darkest ink.
  static const Color carbon950 = Color(0xFFFFFFFF); // app bar / nav / accent-button text
  static const Color carbon900 = Color(0xFFF5F3FC); // app background (soft lavender)
  static const Color carbon800 = Color(0xFFFFFFFF); // cards / surfaces
  static const Color carbon700 = Color(0xFFE7E2F5); // borders / dividers
  static const Color carbon600 = Color(0xFFCFC7E6); // strong border / disabled
  static const Color carbon400 = Color(0xFF8B83A6); // muted / secondary text & icons
  static const Color carbon200 = Color(0xFF565073); // secondary text
  static const Color carbon100 = Color(0xFF39344F); // body text
  static const Color carbon50  = Color(0xFF201C31); // headings (near-black violet)

  // Soft-violet accent scale.
  static const Color gold500 = Color(0xFF8B7BF0); // primary
  static const Color gold400 = Color(0xFFA594F2); // lighter
  static const Color gold300 = Color(0xFFBFB2F7); // lightest
  static const Color gold600 = Color(0xFF7863E0); // darker / gradient start / pressed
  static const Color gold100 = Color(0xFFEDE9FC); // very light tint

  // Semantic colors, tuned to read well on light surfaces (and inside alpha badges).
  static const Color success = Color(0xFF16A34A);
  static const Color danger  = Color(0xFFE5484D);
  static const Color info    = Color(0xFF3B6FF0);
  static const Color warning = Color(0xFFD97706);
}

class AppTheme {
  // Legacy aliases — kept for backward compat.
  static const Color primary = AppColors.gold500;
  static const Color textColor = AppColors.carbon100;

  static ThemeData get theme {
    final inter = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.gold500,
      scaffoldBackgroundColor: AppColors.carbon900,
      splashColor: AppColors.gold500.withValues(alpha: 0.10),
      highlightColor: AppColors.gold500.withValues(alpha: 0.06),
      textTheme: inter.copyWith(
        bodyLarge: inter.bodyLarge?.copyWith(color: AppColors.carbon100),
        bodyMedium: inter.bodyMedium?.copyWith(color: AppColors.carbon200),
        titleLarge: inter.titleLarge?.copyWith(
          color: AppColors.carbon50,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: inter.titleMedium?.copyWith(
          color: AppColors.carbon50,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.carbon950,
        foregroundColor: AppColors.carbon50,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: AppColors.gold600.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.carbon700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold500,
          foregroundColor: AppColors.carbon950,
          disabledBackgroundColor: AppColors.carbon600,
          disabledForegroundColor: AppColors.carbon950,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: 0.3),
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.gold500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.carbon900,
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
      colorScheme: const ColorScheme.light(
        primary: AppColors.gold500,
        secondary: AppColors.gold400,
        surface: AppColors.carbon800,
        error: AppColors.danger,
        onPrimary: AppColors.carbon950,
        onSecondary: AppColors.carbon950,
        onSurface: AppColors.carbon100,
        onError: AppColors.carbon950,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.carbon800,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.carbon50,
        contentTextStyle: GoogleFonts.inter(color: AppColors.carbon950),
        actionTextColor: AppColors.gold300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.gold500,
        selectionColor: AppColors.gold500.withValues(alpha: 0.22),
        selectionHandleColor: AppColors.gold500,
      ),
    );
  }

  /// Backwards-compatible alias (the theme is now light, not dark).
  static ThemeData get darkTheme => theme;
}
