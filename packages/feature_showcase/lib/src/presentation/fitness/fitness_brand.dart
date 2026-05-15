import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Marca ficticia do mock de fitness — narrativa propria pra que o
/// demo nao pareca extensao da landing. "Pulso" e um nome curto e
/// energetico em pt-br.
///
/// Paleta **light/warm** intencionalmente oposta ao dark da landing —
/// inspiracao Strava/Nike Run Club: cream pra superficies, laranja
/// vibrante pra energia/CTA, slate escuro pra texto. Toda a paleta e
/// tema sao locais ao demo via `Theme` widget; widgets internos que
/// leem `context.colors` recebem a paleta da marca sem propagacao.
abstract final class FitnessBrand {
  static const String name = 'Pulso';
  static const String tagline = 'Treino sem friccao.';

  /// Paleta cream/laranja — referencia: Strava, Nike Run Club,
  /// Apple Fitness. Laranja como primary (intensidade, energia),
  /// cream como background (leveza, conforto visual fora do treino).
  static const AppColorScheme palette = AppColorScheme(
    primary: Color(0xFFFF5722),
    primaryHover: Color(0xFFFF7043),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF0F172A),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFFFF7F2),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF5EDE3),
    border: Color(0xFFE5DACA),
    onSurface: Color(0xFF1E293B),
    onSurfaceMuted: Color(0xFF64748B),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFDC2626),
    info: Color(0xFF0EA5E9),
  );

  /// Constroi um `ThemeData` a partir do tema corrente, substituindo
  /// a `AppColorsExtension` e os hooks de Material que leem cor
  /// (scaffold/canvas/tabbar) pra que tudo dentro do demo herde a
  /// identidade da marca. Forca `brightness: light` no colorScheme
  /// pra que widgets Material (modais, ripples, etc.) tratem o demo
  /// como tema claro mesmo quando a landing esta em dark.
  static ThemeData buildTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        secondary: palette.accent,
        onSecondary: palette.onAccent,
        surface: palette.surface,
        onSurface: palette.onSurface,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.onSurface,
        unselectedLabelColor: palette.onSurfaceMuted,
        indicatorColor: palette.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        unselectedLabelStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
      iconTheme: IconThemeData(color: palette.onSurface),
      textTheme: base.textTheme.apply(
        bodyColor: palette.onSurface,
        displayColor: palette.onSurface,
      ),
      // ignore: prefer_const_constructors
      extensions: <ThemeExtension<dynamic>>[AppColorsExtension(palette)],
    );
  }
}
