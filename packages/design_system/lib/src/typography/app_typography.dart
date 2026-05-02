import 'package:flutter/material.dart';

/// Escala tipografica do design system. Os tamanhos seguem uma progressao
/// modular (ratio ~1.25) tipica de sites tecnicos modernos.
///
/// Sem `google_fonts` agora — Flutter usa o sans-serif padrao do sistema.
/// Etapa 13 (polish) bundla Inter local para preload via index.html.
abstract final class AppTypography {
  static const String _fontFamily = 'sans-serif';

  static const TextTheme textTheme = TextTheme(
    // Hero / titulo de pagina
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 64,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: -1.2,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.8,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: -0.4,
    ),

    // Headlines de secao
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.2,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),

    // Titulos de cards / listas
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),

    // Texto corrido
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.55,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.55,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),

    // Labels de botao, chip, badge
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.4,
    ),
  );
}
