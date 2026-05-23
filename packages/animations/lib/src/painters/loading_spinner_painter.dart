import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Spinner customizado usado nas trocas de rota e fetches mockados.
/// Substitui `CircularProgressIndicator` padrao para manter identidade
/// visual e provar o controle sobre Custom Painter (PROJECT.md §5.6).
///
/// Desenha um arco que cresce/encolhe como um snake cycle e gira no eixo:
/// - [progress] vai de 0 a 1 e representa o ciclo da animacao;
/// - O arco oscila entre um angulo minimo (`_minSweep`) e o circulo cheio
///   menos uma fresta — sensacao de "respirar" enquanto gira.
///
/// Ele cacheia o [Paint] em campo final pra nao alocar dentro de `paint()`
/// e marca `willChange = true` (anima continuamente) e `isComplex = false`
/// (geometria leve, nao vale a pena rasterizar em layer).
class LoadingSpinnerPainter extends CustomPainter {
  LoadingSpinnerPainter({
    required double progress,
    required this.color,
    this.strokeWidth = 3,
  }) : progress = progress.clamp(0.0, 1.0);

  /// Fase do ciclo (0..1). Externamente alimentado por um
  /// [AnimationController] em loop.
  final double progress;
  final Color color;
  final double strokeWidth;

  /// Pintura do arco — cacheada como campo pra evitar `Paint()` dentro de
  /// `paint()` (regra invariavel dos painters do projeto).
  late final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..color = color
    ..strokeWidth = strokeWidth;

  static const double _minSweep = 0.18; // ~10% do circulo
  static const double _maxSweep = 0.92; // arco quase completo

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final radius = (shortest - strokeWidth) / 2;
    if (radius <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Comprimento do arco oscila como uma onda — cresce, decresce.
    final t = progress * 2 * math.pi;
    final sweepFraction =
        _minSweep + (_maxSweep - _minSweep) * (0.5 - 0.5 * math.cos(t));

    // Rotacao continua. Usamos `progress` direto pra rodada completa por
    // ciclo do controller.
    final startAngle = progress * 2 * math.pi - math.pi / 2;
    final sweepAngle = sweepFraction * 2 * math.pi;

    canvas.drawArc(rect, startAngle, sweepAngle, false, _strokePaint);
  }

  @override
  bool shouldRepaint(covariant LoadingSpinnerPainter old) {
    return old.progress != progress ||
        old.color != color ||
        old.strokeWidth != strokeWidth;
  }

  /// Hint para o `CustomPaint` host: geometria leve, nao vale rasterizar.
  bool get isComplex => false;

  /// Hint para o `CustomPaint` host: anima continuamente.
  bool get willChange => true;
}
