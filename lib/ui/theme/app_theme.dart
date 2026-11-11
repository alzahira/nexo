import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de diseño centralizado de AppHome.
///
/// Paleta cálida y suave (crema, salvia y melocotón) pensada para una app
/// familiar: fondos claros, tarjetas blancas y texto oscuro con buen
/// contraste. Los nombres históricos (`bgDark`, `accent`...) se mantienen
/// para no romper las pantallas existentes.
class AppTheme {
  // --- Paleta de colores ---
  static const Color bgDark        = Color(0xFFF8F4EE); // fondo principal (crema)
  static const Color bgSurface     = Color(0xFFFFFDF9); // barras y superficies
  static const Color bgCard        = Color(0xFFFFFFFF); // tarjetas
  static const Color accent        = Color(0xFF6F9480); // verde salvia
  static const Color accentLight   = Color(0xFFA9C4B2); // salvia clara
  static const Color accentGlow    = Color(0xFF5C7F6C);
  static const Color textPrimary   = Color(0xFF2E3A34); // verde muy oscuro
  static const Color textSecondary = Color(0xFF66736B);
  static const Color borderColor   = Color(0xFFE8E0D3);
  static const Color successGreen  = Color(0xFF6FAE8B);
  static const Color warningOrange = Color(0xFFD9A441);
  static const Color dangerRed     = Color(0xFFC4675A);

  // Tonos de apoyo para tarjetas y detalles
  static const Color softMint      = Color(0xFFE7F0EA);
  static const Color softPeach     = Color(0xFFFBEDE7);
  static const Color softSky       = Color(0xFFE3EEF4);
  static const Color softLilac     = Color(0xFFEDE7F3);
  static const Color softSand      = Color(0xFFF6EEDF);

  // --- Gradientes ---
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFA9C4B2), Color(0xFFF3C9B8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente para botones con texto blanco (más profundo que el decorativo).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6F9480), Color(0xFF52705F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFFCF9F4), Color(0xFFF3EEE5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFFE7F0EA), Color(0xFFF7EFE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFFBEDE7), Color(0xFFF6EEDF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Sombras ---
  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.18),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF2E3A34).withValues(alpha: 0.07),
      blurRadius: 18,
      offset: const Offset(0, 6),
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
    gradient: mintGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: borderColor, width: 1),
  );

  // --- Tipografía ---
  static String get _font => GoogleFonts.nunito().fontFamily ?? 'Nunito';

  static TextTheme get _textTheme {
    final base = ThemeData.light().textTheme.apply(
      fontFamily: _font,
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );
    return base.copyWith(
      displayLarge: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, height: 1.15),
      displayMedium: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary, height: 1.15),
      headlineSmall: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary, height: 1.2),
      titleLarge: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, height: 1.2),
      titleMedium: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary, height: 1.25),
      titleSmall: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary),
      bodyLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.35),
      bodyMedium: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary, height: 1.35),
      bodySmall: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary, height: 1.3),
      labelLarge: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary),
      labelMedium: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary),
    );
  }

  // --- Tema de la app ---
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: bgDark,
    primaryColor: accent,
    fontFamily: _font,

    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: accent,
      secondary: Color(0xFFE8B4A2),
      surface: bgSurface,
      onSurface: textPrimary,
      onPrimary: Colors.white,
      error: dangerRed,
    ),

    textTheme: _textTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: bgDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: 0.1,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      actionsIconTheme: const IconThemeData(color: textPrimary),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgSurface,
      selectedItemColor: accent,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: bgCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderColor),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: CircleBorder(),
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
        borderSide: const BorderSide(color: accent, width: 1.6),
      ),
      labelStyle: GoogleFonts.nunito(color: textSecondary, fontSize: 14),
      hintStyle: GoogleFonts.nunito(color: textSecondary, fontSize: 14),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: bgCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: textPrimary),
      contentTextStyle: GoogleFonts.nunito(fontSize: 15, color: textSecondary, height: 1.35),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF33413A),
      contentTextStyle: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    dividerTheme: const DividerThemeData(color: borderColor, thickness: 1, space: 1),
    iconTheme: const IconThemeData(color: textSecondary),
    listTileTheme: const ListTileThemeData(
      textColor: textPrimary,
      iconColor: textSecondary,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: softSand,
      labelStyle: GoogleFonts.nunito(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
      side: const BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: accent,
      selectionColor: Color(0x556F9480),
      selectionHandleColor: accent,
    ),
  );

  /// Alias de compatibilidad con las referencias antiguas.
  static ThemeData get dark => light;
}
