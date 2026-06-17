import 'package:flutter/material.dart';

/// Escala tipografica do design system. Familia unica IBMPlexSans bundlada
/// como asset em apps/landing — substituta open-source proxima a Kraken-Product
/// (DESIGN.md §3 fallback canonico). Display e UI compartilham a familia,
/// diferenciados por weight/size.
abstract final class AppTypography {
  static const String _displayFamily = 'IBMPlexSans';
  static const List<String> _displayFallback = <String>[
    'Helvetica Neue',
    'Helvetica',
    'Arial',
  ];

  static const String _uiFamily = 'IBMPlexSans';
  static const List<String> _uiFallback = <String>[
    'Helvetica Neue',
    'Helvetica',
    'Arial',
  ];

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _displayFamily,
      fontFamilyFallback: _displayFallback,
      fontSize: 64,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -1.2,
    ),
    displayMedium: TextStyle(
      fontFamily: _displayFamily,
      fontFamilyFallback: _displayFallback,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.8,
    ),
    displaySmall: TextStyle(
      fontFamily: _displayFamily,
      fontFamilyFallback: _displayFallback,
      fontSize: 36,
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: -0.4,
    ),

    headlineLarge: TextStyle(
      fontFamily: _displayFamily,
      fontFamilyFallback: _displayFallback,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.2,
    ),
    headlineMedium: TextStyle(
      fontFamily: _displayFamily,
      fontFamilyFallback: _displayFallback,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    headlineSmall: TextStyle(
      fontFamily: _displayFamily,
      fontFamilyFallback: _displayFallback,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),

    titleLarge: TextStyle(
      fontFamily: _uiFamily,
      fontFamilyFallback: _uiFallback,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
    titleMedium: TextStyle(
      fontFamily: _uiFamily,
      fontFamilyFallback: _uiFallback,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontFamily: _uiFamily,
      fontFamilyFallback: _uiFallback,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),

    bodyLarge: TextStyle(
      fontFamily: _uiFamily,
      fontFamilyFallback: _uiFallback,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.55,
    ),
    bodyMedium: TextStyle(
      fontFamily: _uiFamily,
      fontFamilyFallback: _uiFallback,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.55,
    ),
    bodySmall: TextStyle(
      fontFamily: _uiFamily,
      fontFamilyFallback: _uiFallback,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),

    labelLarge: TextStyle(
      fontFamily: _uiFamily,
      fontFamilyFallback: _uiFallback,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
    ),
    labelMedium: TextStyle(
      fontFamily: _uiFamily,
      fontFamilyFallback: _uiFallback,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
    ),
    labelSmall: TextStyle(
      fontFamily: _uiFamily,
      fontFamilyFallback: _uiFallback,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.4,
    ),
  );
}
