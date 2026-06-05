import 'package:flutter/material.dart';

class AppTheme {
  // Kiso-aligned palette: calm, clinical, trustworthy
  static const Color primary = Color(0xFF2C6E8A); // deep teal
  static const Color primaryLight = Color(0xFFE8F4F8);
  static const Color accent = Color(0xFF5BA08A); // muted sage green
  static const Color warning = Color(0xFFE8944A); // amber warning
  static const Color danger = Color(0xFFD95F5F); // soft red
  static const Color surface = Color(0xFFF7F8FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF6B7A8D);
  static const Color border = Color(0xFFE2E8EF);

  // Symptom dimension colors
  static const Color positiveSymptom = Color(0xFFD95F5F); // red-ish (elevated = bad)
  static const Color negativeSymptom = Color(0xFF7B8FA8); // muted blue (withdrawal)
  static const Color sleepColor = Color(0xFF6B7FCC); // indigo
  static const Color stressColor = Color(0xFFE8944A); // amber
  static const Color socialColor = Color(0xFF5BA08A); // sage

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          surface: surface,
          onSurface: textPrimary,
        ),
        scaffoldBackgroundColor: surface,
        fontFamily: 'SF Pro Display', // falls back to system sans
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: primary,
          inactiveTrackColor: primaryLight,
          thumbColor: primary,
          overlayColor: primary.withOpacity(0.12),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        ),
      );
}
