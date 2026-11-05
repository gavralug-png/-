import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const navy = Color(0xFF071B3B);
  static const deepBlue = Color(0xFF102F59);
  static const gold = Color(0xFFD6B56D);
  static const lightGold = Color(0xFFF1D99B);
  static const white = Color(0xFFFFFFFF);
  static const parchment = Color(0xFFF5F0E5);
  static const success = Color(0xFF3E8E5A);
  static const error = Color(0xFFB5483F);
  static const _darkGold = Color(0xFF9A7525);

  /// Золото, читаемое на текущем фоне (в светлой теме — более тёмный оттенок).
  static Color goldOn(Brightness b) => b == Brightness.dark ? gold : _darkGold;

  static Color goldFor(BuildContext context) =>
      goldOn(Theme.of(context).brightness);
}

class AppTheme {
  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  /// Заголовочный стиль (гарнитура с засечками).
  static TextStyle heading(
    BuildContext context, {
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: weight,
      height: 1.25,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final gold = AppColors.goldOn(b);
    final scheme = ColorScheme(
      brightness: b,
      primary: dark ? AppColors.gold : AppColors.deepBlue,
      onPrimary: dark ? AppColors.navy : AppColors.white,
      secondary: gold,
      onSecondary: dark ? AppColors.navy : AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: dark ? AppColors.deepBlue : AppColors.parchment,
      onSurface: dark ? AppColors.white : AppColors.navy,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final textTheme = GoogleFonts.ptSansTextTheme(base.textTheme)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return base.copyWith(
      scaffoldBackgroundColor: dark ? AppColors.navy : AppColors.parchment,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(88, 54),
          shape: buttonShape,
          textStyle:
              GoogleFonts.ptSans(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(88, 54),
          side: BorderSide(color: gold.withAlpha(190), width: 1.3),
          shape: buttonShape,
          textStyle:
              GoogleFonts.ptSans(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gold,
          textStyle:
              GoogleFonts.ptSans(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.navy.withAlpha(120) : AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: gold.withAlpha(150)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: gold.withAlpha(150)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: gold, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? AppColors.gold : AppColors.deepBlue,
        contentTextStyle: GoogleFonts.ptSans(
          fontSize: 15,
          color: dark ? AppColors.navy : AppColors.white,
        ),
      ),
    );
  }
}
