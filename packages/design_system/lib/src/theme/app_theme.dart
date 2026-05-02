import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/tokens/app_radius.dart';
import 'package:design_system/src/typography/app_typography.dart';
import 'package:flutter/material.dart';

/// Construtor unico do ThemeData. Use [AppTheme.dark] como default e
/// [AppTheme.light] no toggle.
abstract final class AppTheme {
  static ThemeData dark() => _build(AppColorScheme.dark, Brightness.dark);
  static ThemeData light() => _build(AppColorScheme.light, Brightness.light);

  static ThemeData _build(AppColorScheme scheme, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      secondary: scheme.accent,
      onSecondary: scheme.onAccent,
      surface: scheme.surface,
      onSurface: scheme.onSurface,
      error: scheme.error,
      onError: scheme.onPrimary,
      outline: scheme.border,
      surfaceContainerHighest: scheme.surfaceMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scheme.background,
      canvasColor: scheme.background,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      dividerTheme: DividerThemeData(color: scheme.border, thickness: 1),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: scheme.border),
        ),
        margin: EdgeInsets.zero,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColorsExtension(scheme),
      ],
    );
  }
}
