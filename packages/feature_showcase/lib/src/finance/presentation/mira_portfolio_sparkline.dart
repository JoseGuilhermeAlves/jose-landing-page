import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Sparkline mini-chart do patrimonio nos ultimos 30 dias. Recebe
/// `endValueCents` (valor atual) e gera uma serie sintetica de 30
/// pontos via random walk com seed estavel — sobe ate o valor final
/// com volatilidade controlada pra parecer real.
///
/// Cor da linha: success (verde) quando ultimo > primeiro, error
/// (vermelho) quando contrario. Area sob a linha em alpha 0.10 +
/// glow dot piscando no endpoint.
class MiraPortfolioSparkline extends StatefulWidget {
  const MiraPortfolioSparkline({
    required this.endValueCents,
    this.height = 56,
    super.key,
  });

  final int endValueCents;
  final double height;

  @override
  State<MiraPortfolioSparkline> createState() => _MiraPortfolioSparklineState();
}

class _MiraPortfolioSparklineState extends State<MiraPortfolioSparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  late final List<double> _series;
  late final bool _isUp;

  @override
  void initState() {
    super.initState();
    _series = _generateSeries(widget.endValueCents);
    _isUp = _series.last >= _series.first;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Series sintetica de 30 pontos terminando em `endValueCents`. Seed
  /// derivada do proprio valor pra estabilidade entre rebuilds.
  static List<double> _generateSeries(int endValueCents) {
    final seed = (endValueCents * 13 + 7) & 0x7fffffff;
    final rng = math.Random(seed);
    final values = <double>[];
    var v = endValueCents * (0.88 + rng.nextDouble() * 0.06);
    for (var i = 0; i < 29; i++) {
      v *= 1 + (rng.nextDouble() - 0.45) * 0.018;
      values.add(v);
    }
    values.add(endValueCents.toDouble());
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lineColor = _isUp ? colors.success : colors.error;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(
        child: CustomPaint(
          isComplex: true,
          willChange: true,
          painter: _SparklinePainter(
            series: _series,
            lineColor: lineColor,
            pulse: _controller,
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.series,
    required this.lineColor,
    required this.pulse,
  }) : super(repaint: pulse);

  final List<double> series;
  final Color lineColor;
  final Animation<double> pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2 || size.width <= 0 || size.height <= 0) return;

    var min = series.first;
    var max = series.first;
    for (final v in series) {
      if (v < min) min = v;
      if (v > max) max = v;
    }
    final span = (max - min).clamp(0.0001, double.infinity);
    final stepX = size.width / (series.length - 1);

    double yFor(double v) =>
        size.height - ((v - min) / span) * size.height * 0.85 - 4;

    final path = Path()..moveTo(0, yFor(series.first));
    for (var i = 1; i < series.length; i++) {
      path.lineTo(i * stepX, yFor(series[i]));
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas
      ..drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withValues(alpha: 0.22),
              lineColor.withValues(alpha: 0.02),
            ],
          ).createShader(Offset.zero & size),
      )
      ..drawPath(
        path,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );

    // Endpoint glow pulsante.
    final endX = (series.length - 1) * stepX;
    final endY = yFor(series.last);
    final phase = 0.5 + 0.5 * math.sin(pulse.value * 2 * math.pi);
    canvas
      ..drawCircle(
        Offset(endX, endY),
        4 + phase * 2.5,
        Paint()
          ..color = lineColor.withValues(alpha: 0.20 * phase)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawCircle(Offset(endX, endY), 2.6, Paint()..color = lineColor);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) {
    return !identical(old.series, series) || old.lineColor != lineColor;
  }
}
