import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Onda circular que se expande a partir de [center] — usada em botoes
/// e cards (PROJECT.md §5.4). Reage a eventos de mouse: o widget host
/// captura o `onEnter`/`onHover` e dispara o controller.
///
/// O anel cresce de raio 0 ate [maxRadius] (ou ate o canto mais
/// distante do canvas, quando null) e o alpha decai linearmente — da
/// sensacao de "onda de luz" se afastando do ponto.
///
/// Performance:
/// - `Paint` cacheado em campo;
/// - `shouldRepaint` minimo (so reage a mudancas relevantes);
/// - desenha 1 stroke por frame.
class RippleHoverPainter extends CustomPainter {
  RippleHoverPainter({
    required this.center,
    required double progress,
    required this.color,
    this.maxRadius,
    this.strokeWidth = 1.5,
  }) : progress = progress.clamp(0.0, 1.0);

  /// Centro da onda — geralmente vem do `localPosition` do
  /// `MouseRegion.onHover`.
  final Offset center;

  /// Fase do ripple (0..1). 0 = oculto; 1 = anel no raio maximo,
  /// alpha zero (sumindo).
  final double progress;

  final Color color;

  /// Raio final. Quando null, o painter usa a distancia do centro ate
  /// o canto mais distante do canvas (cobre area inteira).
  final double? maxRadius;

  final double strokeWidth;

  late final Paint _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..strokeWidth = strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || progress == 0) return;

    final reach = maxRadius ?? _farCorner(center, size);
    if (reach <= 0) return;

    final radius = reach * progress;
    // Alpha decai linearmente: cheio em progress=0, zero em progress=1.
    final alpha = (1 - progress).clamp(0.0, 1.0);
    if (alpha <= 0) return;

    _ringPaint.color = color.withValues(alpha: color.a * alpha);
    canvas.drawCircle(center, radius, _ringPaint);
  }

  /// Distancia do ponto [p] ao canto mais distante do retangulo
  /// [0, 0, size.width, size.height]. Garante cobertura total.
  static double _farCorner(Offset p, Size size) {
    final dx = math.max(p.dx.abs(), (size.width - p.dx).abs());
    final dy = math.max(p.dy.abs(), (size.height - p.dy).abs());
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool shouldRepaint(covariant RippleHoverPainter old) {
    return old.progress != progress ||
        old.center != center ||
        old.color != color ||
        old.maxRadius != maxRadius ||
        old.strokeWidth != strokeWidth;
  }

  /// Hint para o `CustomPaint` host: 1 forma simples.
  bool get isComplex => false;

  /// Hint para o `CustomPaint` host: anima durante o hover.
  bool get willChange => true;
}
