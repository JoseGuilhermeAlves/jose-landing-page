import 'package:design_system/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Gradientes da marca. Centralize aqui pra evitar drift entre call
/// sites — qualquer componente que precise de "cor de destaque" puxa
/// daqui em vez de inventar `LinearGradient(colors: [primary, accent])`
/// no widget.
abstract final class AppGradients {
  /// Gradiente diagonal primary -> accent. Usado em texto de destaque
  /// (`GradientText`), botoes primarios, bordas de cards de prestigio
  /// e no avatar do About.
  static LinearGradient brand(AppColorScheme scheme) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [scheme.primary, scheme.accent],
      );

  /// Variante mais suave do brand — usada em fundos sutis (botoes
  /// hover state, glow em volta de cards).
  static LinearGradient brandSoft(AppColorScheme scheme) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scheme.primary.withValues(alpha: 0.18),
          scheme.accent.withValues(alpha: 0.12),
        ],
      );

  /// Glow radial pra fundo de secao. Alpha decresce do centro pra
  /// borda — vira "neblina" quando sobreposto ao background dark.
  static RadialGradient glow(
    Color color, {
    double opacity = 0.22,
    double radius = 0.6,
    Alignment center = Alignment.center,
  }) =>
      RadialGradient(
        center: center,
        radius: radius,
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ],
      );
}
