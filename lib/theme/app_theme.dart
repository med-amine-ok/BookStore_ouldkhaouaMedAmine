import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF7B4E20); // Deep, rich brown
  static const Color primaryBackgroundLight = Color(0xFFF7F3EE);
  static const Color cardSurfaceLight = Color(0xFFFFFFFF);
  static const Color CafeAccent = Color(0xFF7B4E20); // Premium metallic tone
  static const Color textPrimary = Color(0xFF2C2C2C); // High contrast dark gray
  static const Color textSecondary = Color(0xFF6B6B6B); // Medium gray
  static const Color textMuted = Color(0xFF9E9E9E); // Light gray
  static const Color successGreen = Color(0xFF4CAF50); // Standard success
  static const Color errorRed = Color(0xFFF44336); // Clear error communication
  static const Color borderSubtle = Color(
    0xFFE8E8E8,
  ); // Minimal border definition
  static const Color shadowBase = Color(0x10000000); // Ultra-subtle shadow

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: CafeAccent,
      onPrimary: cardSurfaceLight,
      primaryContainer: CafeAccent.withAlpha(26),
      onPrimaryContainer: textPrimary,
      secondary: textSecondary,
      onSecondary: cardSurfaceLight,
      secondaryContainer: textSecondary.withAlpha(26),
      onSecondaryContainer: textPrimary,
      tertiary: CafeAccent,
      onTertiary: cardSurfaceLight,
      tertiaryContainer: CafeAccent.withAlpha(13),
      onTertiaryContainer: textPrimary,
      error: errorRed,
      onError: cardSurfaceLight,
      surface: cardSurfaceLight,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: borderSubtle,
      outlineVariant: borderSubtle.withAlpha(128),
      shadow: shadowBase,
      scrim: shadowBase,
      inverseSurface: textPrimary,
      onInverseSurface: cardSurfaceLight,
      inversePrimary: textPrimary,
    ),
    scaffoldBackgroundColor: primaryBackgroundLight,
    cardColor: cardSurfaceLight,
    dividerColor: borderSubtle,

    textTheme: _buildTextTheme(isLight: true),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return CafeAccent;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(cardSurfaceLight),
      side: const BorderSide(color: borderSubtle, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: cardSurfaceLight,
      ),
      actionTextColor: CafeAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: cardSurfaceLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: cardSurfaceLight,
      elevation: 8,
      shadowColor: shadowBase,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
    ),
  );

  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHighEmphasis = textPrimary;
    final Color textMediumEmphasis = textSecondary;
    final Color textLowEmphasis = textMuted;

    return TextTheme(
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textHighEmphasis,
        letterSpacing: 0,
        height: 1.33,
      ),

      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHighEmphasis,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMediumEmphasis,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles - For buttons, form labels, and captions
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHighEmphasis,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMediumEmphasis,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textLowEmphasis,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }
}
