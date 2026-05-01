import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Couleurs Burkina Faso
  static const rouge  = Color(0xFFC8102E);
  static const vert   = Color(0xFF009A44);
  static const or     = Color(0xFFF4A900);

  // Neutres
  static const noir   = Color(0xFF111318);
  static const blanc  = Color(0xFFF7F5F0);
  static const gris0  = Color(0xFFFAFAF8);
  static const gris1  = Color(0xFFF0EDE6);
  static const gris2  = Color(0xFFDDD9D0);
  static const gris3  = Color(0xFFA8A49C);
  static const text   = Color(0xFF1C1C20);
  static const sub    = Color(0xFF6B6860);

  // Statuts
  static const valide        = Color(0xFF009A44);
  static const revoque       = Color(0xFFC8102E);
  static const attente       = Color(0xFFB87800);
  static const valideBg      = Color(0x1F009A44);
  static const revoqueBg     = Color(0x1FC8102E);
  static const attenteBg     = Color(0x1FF4A900);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.rouge,
      primary: AppColors.rouge,
      secondary: AppColors.vert,
      tertiary: AppColors.or,
      background: AppColors.blanc,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.blanc,
    textTheme: GoogleFonts.epilogueTextTheme().copyWith(
      displayLarge: GoogleFonts.syne(fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.syne(fontWeight: FontWeight.w800),
      displaySmall: GoogleFonts.syne(fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.syne(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.syne(fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.syne(fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.syne(fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.syne(fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.syne(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.syne(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rouge,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.gris2, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.gris2, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.rouge, width: 1.5),
      ),
      hintStyle: GoogleFonts.epilogue(color: AppColors.gris3, fontSize: 13),
    ),
  );
}
