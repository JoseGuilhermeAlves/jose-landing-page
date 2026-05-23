import 'package:flutter/material.dart';

/// Linha temporal animada — usada na secao About (PROJECT.md §4.4, §5.2).
/// Desenha uma linha vertical conectando [markerCount] marcadores
/// circulares equidistantes. A linha **se revela progressivamente**
/// (extractPath), e cada marcador aparece quando a linha atravessa seu
/// centro.
///
/// Performance:
/// - Paints cacheados como campos finais;
/// - `shouldRepaint` so volta `true` quando algo do estado visual muda;
/// - `isComplex = false` (poucas formas), `willChange = true`.
class AnimatedTimelinePainter extends CustomPainter {
  AnimatedTimelinePainter({
    required double progress,
    required this.markerCount,
    required this.lineColor,
    required this.markerColor,
    this.lineWidth = 2,
    this.markerRadius = 5,
  }) : progress = progress.clamp(0.0, 1.0);

  /// 0 = linha invisivel; 1 = linha completa, todos os marcadores visiveis.
  final double progress;
  final int markerCount;
  final Color lineColor;
  final Color markerColor;
  final double lineWidth;
  final double markerRadius;

  late final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..color = lineColor
    ..strokeWidth = lineWidth;

  late final Paint _markerFill = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true
    ..color = markerColor;

  late final Paint _markerStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = lineWidth
    ..isAntiAlias = true
    ..color = lineColor;

  /// Centros de cada marcador para o tamanho dado. Distribuicao vertical
  /// equidistante na coluna esquerda, com folga em cima/embaixo.
  @visibleForTesting
  List<Offset> debugMarkerCenters(Size size) => _markerCenters(size);

  List<Offset> _markerCenters(Size size) {
    if (markerCount <= 0 || size.isEmpty) return const [];

    final x = markerRadius + lineWidth / 2;
    if (markerCount == 1) {
      return [Offset(x, size.height / 2)];
    }

    final topPadding = markerRadius;
    final bottomPadding = markerRadius;
    final usableHeight = size.height - topPadding - bottomPadding;
    final step = usableHeight / (markerCount - 1);

    return [
      for (var i = 0; i < markerCount; i++) Offset(x, topPadding + step * i),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || progress == 0) return;

    final centers = _markerCenters(size);
    if (centers.isEmpty) return;

    // Linha conectando o primeiro ao ultimo marcador.
    if (centers.length >= 2) {
      final path = Path()
        ..moveTo(centers.first.dx, centers.first.dy)
        ..lineTo(centers.last.dx, centers.last.dy);

      final metrics = path.computeMetrics().toList(growable: false);
      final revealed = Path();
      for (final metric in metrics) {
        revealed.addPath(
          metric.extractPath(0, metric.length * progress),
          Offset.zero,
        );
      }
      canvas.drawPath(revealed, _linePaint);
    }

    // Cada marcador aparece quando a linha passa por ele.
    final span = centers.last.dy - centers.first.dy;
    final lineEndY = centers.first.dy + span * progress;
    for (final c in centers) {
      // tolerancia de 1px pra arredondamento
      if (c.dy <= lineEndY + 1) {
        canvas
          ..drawCircle(c, markerRadius, _markerFill)
          ..drawCircle(c, markerRadius, _markerStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedTimelinePainter old) {
    return old.progress != progress ||
        old.markerCount != markerCount ||
        old.lineColor != lineColor ||
        old.markerColor != markerColor ||
        old.lineWidth != lineWidth ||
        old.markerRadius != markerRadius;
  }

  /// Hint para o `CustomPaint` host: poucas formas, nao vale rasterizar.
  bool get isComplex => false;

  /// Hint para o `CustomPaint` host: anima continuamente ao entrar na view.
  bool get willChange => true;
}
