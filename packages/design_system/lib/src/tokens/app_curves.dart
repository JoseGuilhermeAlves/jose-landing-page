import 'package:flutter/animation.dart';

/// Curvas reutilizaveis em transicoes. Padronizar curvas evita um app que
/// "pisca" entre easings diferentes.
abstract final class AppCurves {
  /// Default para a maioria das transicoes — natural sem ser tedioso.
  static const Curve standard = Curves.easeOutCubic;

  /// Para entradas (slide-in, fade-in).
  static const Curve enter = Curves.easeOutQuart;

  /// Para saidas (dismissal, fade-out).
  static const Curve exit = Curves.easeInCubic;

  /// Para movimentos com sensacao de "spring" sutil.
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
}
