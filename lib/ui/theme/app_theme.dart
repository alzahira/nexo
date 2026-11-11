import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de diseño centralizado de AppHome
class AppTheme {
  // --- Paleta de colores ---
  static const Color bgDark        = Color(0xFF1C1E2E); // Antes 0F0F1A, ahora más claro
  static const Color bgSurface     = Color(0xFF252838); // Antes 1A1A2E
  static const Color bgCard        = Color(0xFF2A2D42); // Antes 16213E
  static const Color accent        = Color(0xFF6C63FF);
  static const Color accentLight   = Color(0xFFA78BFA);
  static const Color accentGlow    = Color(0xFF4F46E5);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color borderColor   = Color(0xFF2A2A4A);
  static const Color successGreen  = Color(0xFF34D399);
  static const Color warningOrange = Color(0xFFFBBF24);
  static const Color dangerRed     = Color(0xFFF87171);

  // --- Gradientes ---
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- Sombras ---
  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // --- Decoración de tarjetas ---
  static BoxDecoration cardDecoration = BoxDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: borderColor, width: 1),
    boxShadow: cardShadow,
  );

  static BoxDecoration accentCardDecoration = BoxDecoration(
    gradient: accentGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: glowShadow,
  );

  // --- Tema de la app ---
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: accent,

    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accentLight,
      surface: bgSurface,
      onSurface: textPrimary,
      onPrimary: textPrimary,
    ),

    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
      titleLarge:   GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
      titleMedium:  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      bodyMedium:   GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
      bodySmall:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(color: accentLight),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgSurface,
      selectedItemColor: accent,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderColor),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
      hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
    ),

    iconTheme: const IconThemeData(color: textSecondary),
    dividerColor: borderColor,
    useMaterial3: false,
  );
}
