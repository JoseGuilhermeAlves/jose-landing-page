import 'package:flutter/material.dart';

/// Desenha uma borda arredondada que **se revela progressivamente**
/// quando o usuario passa o mouse — usado pelos cards de servico
/// (PROJECT.md §4.2). Em hover, a borda cresce de 0 ate o perimetro
/// completo; em exit, recolhe.
///
/// Usa `PathMetrics.extractPath` para extrair uma fracao do path total,
/// tecnica recomendada pra animar contornos sem precisar redesenhar
/// segmento por segmento.
///
/// Performance:
/// - `Paint` cacheado em campo final;
/// - `shouldRepaint` so volta `true` quando algo do estado visual muda;
/// - `isComplex = false` (geometria leve, ~1 path) e `willChange = true`.
class AnimatedBorderPainter extends CustomPainter {
  AnimatedBorderPainter({
    required double progress,
    required this.color,
    this.strokeWidth = 1.5,
    this.borderRadius = 12,
  }) : progress = progress.clamp(0.0, 1.0);

  /// Quanto da borda esta visivel — 0 (escondida) ate 1 (perimetro completo).
  final double progress;
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  late final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..color = color
    ..strokeWidth = strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || progress == 0) return;

    // Recolhe um pouco a borda pra ficar dentro dos limites do widget,
    // evitando que metade do trace caia fora ao usar StrokeCap.round.
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    if (rect.isEmpty) return;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);

    // Extrai apenas a fracao desejada do contorno.
    final metrics = path.computeMetrics().toList(growable: false);
    final revealed = Path();
    for (final metric in metrics) {
      revealed.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }

    canvas.drawPath(revealed, _strokePaint);
  }

  @override
  bool shouldRepaint(covariant AnimatedBorderPainter old) {
    return old.progress != progress ||
        old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.borderRadius != borderRadius;
  }

  /// Hint para o `CustomPaint` host: geometria leve, nao vale rasterizar.
  bool get isComplex => false;

  /// Hint para o `CustomPaint` host: anima continuamente em hover.
  bool get willChange => true;
}
