import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF111827);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 2.0,
        shadowColor: Color(0x0D000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
      ),
    );
  }
}