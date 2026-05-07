import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Marca ficticia do mock de fitness — narrativa propria pra que o
/// demo nao pareca extensao da landing. "Pulso" e um nome curto e
/// energetico em pt-br; pode ser trocado sem impacto tecnico.
///
/// Toda a paleta e tema sao locais ao demo: o `Theme` widget aplica
/// a `AppColorsExtension` da marca, entao todos os widgets internos
/// que leem `context.colors` ja recebem a paleta lime/navy
/// automaticamente — sem propagacao manual.
abstract final class FitnessBrand {
  static const String name = 'Pulso';
  static const String tagline = 'Treino sem friccao.';

  /// Paleta lime/navy — referencia: Whoop, Strava, Hevy. Lime como
  /// primary (energia, foco), navy como background (premium, foco
  /// noturno na hora do treino).
  static const AppColorScheme palette = AppColorScheme(
    primary: Color(0xFFB8FF4A),
    primaryHover: Color(0xFFC8FF6E),
    onPrimary: Color(0xFF0B1118),
    accent: Color(0xFFFF6B35),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFF0B1118),
    surface: Color(0xFF141B26),
    surfaceMuted: Color(0xFF1E2632),
    border: Color(0xFF2A3340),
    onSurface: Color(0xFFF5F7FA),
    onSurfaceMuted: Color(0xFF7E8A9C),
    success: Color(0xFFB8FF4A),
    warning: Color(0xFFFFB347),
    error: Color(0xFFFF6B6B),
    info: Color(0xFF4DD0E1),
  );

  /// Constroi um `ThemeData` a partir do tema corrente, substituindo
  /// a `AppColorsExtension` e os hooks de Material que leem cor
  /// (scaffold/canvas/tabbar) pra que tudo dentro do demo herde a
  /// identidade da marca.
  static ThemeData buildTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      colorScheme: base.colorScheme.copyWith(
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
      // ignore: prefer_const_constructors
      extensions: <ThemeExtension<dynamic>>[
        AppColorsExtension(palette),
      ],
    );
  }
}
