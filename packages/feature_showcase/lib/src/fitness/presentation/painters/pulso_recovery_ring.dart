import 'dart:math' as math;

import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:flutter/material.dart';

/// Anel de recovery Whoop-style. Numeral grande centralizado e arco
/// stroked com a cor da banda de recovery (red/amber/green).
/// Recebe `animation` opcional pra animar entrada (0..1).
class PulsoRecoveryRing extends StatelessWidget {
  const PulsoRecoveryRing({
    required this.percent,
    this.label = 'Recovery',
    this.diameter = 240,
    this.animation,
    super.key,
  });

  /// 0..100 — banda colorida via [FitnessBrand.recoveryColor].
  final double percent;
  final String label;
  final double diameter;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: diameter,
      child: CustomPaint(
        painter: _RecoveryRingPainter(
          percent: percent,
          label: label,
          progress: animation,
        ),
      ),
    );
  }
}

class _RecoveryRingPainter extends CustomPainter {
  _RecoveryRingPainter({
    required this.percent,
    required this.label,
    required this.progress,
  }) : super(repaint: progress);

  final double percent;
  final String label;
  final Animation<double>? progress;

  static const double _startAngle = -math.pi / 2; // topo (12h)
  static const double _sweepFull = math.pi * 2;

  static final Paint _trackPaint = Paint()
    ..color = const Color(0xFF1A1A22)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 18
    ..strokeCap = StrokeCap.round;

  static final Paint _arcPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 18
    ..strokeCap = StrokeCap.round;

  static final Paint _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 30
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, 0, _sweepFull, false, _trackPaint);

    final t = progress?.value ?? 1.0;
    final color = FitnessBrand.recoveryColor(percent);
    final sweep = _sweepFull * (percent / 100).clamp(0, 1).toDouble() * t;

    if (sweep > 0.001) {
      // Glow externo discreto.
      _glowPaint.color = color.withValues(alpha: 0.28);
      canvas.drawArc(rect, _startAngle, sweep, false, _glowPaint);

      _arcPaint.color = color;
      canvas.drawArc(rect, _startAngle, sweep, false, _arcPaint);
    }

    _drawCenter(canvas, size, center, color, t);
  }

  void _drawCenter(
    Canvas canvas,
    Size size,
    Offset center,
    Color color,
    double t,
  ) {
    final value = (percent * t).round();
    final numberStyle = TextStyle(
      color: color,
      fontSize: 80,
      fontWeight: FontWeight.w600,
      letterSpacing: -1.5,
      fontFamily: FitnessBrand.displayMonoFontFamily,
      fontFeatures: FitnessBrand.numFeatures,
    );
    final big = TextPainter(
      text: TextSpan(text: '$value', style: numberStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    big.paint(
      canvas,
      Offset(center.dx - big.width / 2, center.dy - big.height / 2 - 10),
    );

    final pct = TextPainter(
      text: const TextSpan(
        text: '%',
        style: TextStyle(
          color: Color(0xFF7E7E8A),
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pct.paint(
      canvas,
      Offset(center.dx + big.width / 2 + 2, center.dy - big.height / 2 + 14),
    );

    final caption = TextPainter(
      text: TextSpan(
        text: label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF7E7E8A),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    caption.paint(
      canvas,
      Offset(center.dx - caption.width / 2, center.dy + big.height / 2 - 4),
    );
  }

  @override
  bool shouldRepaint(_RecoveryRingPainter old) =>
      old.percent != percent || old.label != label;
}
