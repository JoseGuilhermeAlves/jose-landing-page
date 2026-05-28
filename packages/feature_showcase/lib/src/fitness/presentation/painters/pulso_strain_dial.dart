import 'dart:math' as math;

import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:flutter/material.dart';

/// Dial de strain inspirado no Whoop. Arco principal vai de
/// `valueRange.start` (canto inferior esquerdo) a `valueRange.end`
/// (canto inferior direito) — ~270 graus uteis. Gradiente azul ->
/// roxo -> magenta acompanha intensidade. Numeral monospace
/// centralizado mostra o valor acumulado.
class PulsoStrainDial extends StatelessWidget {
  const PulsoStrainDial({
    required this.value,
    required this.target,
    this.label = 'Strain',
    this.diameter = 220,
    super.key,
  });

  /// Strain acumulado (0..21).
  final double value;

  /// Strain alvo (0..21) — desenhado como marca no arco.
  final double target;

  final String label;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: diameter,
      child: CustomPaint(
        painter: _StrainDialPainter(value: value, target: target, label: label),
        isComplex: true,
      ),
    );
  }
}

class _StrainDialPainter extends CustomPainter {
  _StrainDialPainter({
    required this.value,
    required this.target,
    required this.label,
  });

  final double value;
  final double target;
  final String label;

  // Constantes geometricas (rad). Arco desenha de 135 (canto inf esq)
  // ate 405 (canto inf dir) — 270 graus uteis.
  static const double _startAngle = math.pi * 0.75;
  static const double _sweepFull = math.pi * 1.5;
  static const double _maxStrain = 21;

  static final Paint _trackPaint = Paint()
    ..color = const Color(0xFF1F1F28)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 14
    ..strokeCap = StrokeCap.round;

  static final Paint _arcPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 14
    ..strokeCap = StrokeCap.round;

  static final Paint _tickPaint = Paint()
    ..color = const Color(0xFF7E7E8A)
    ..strokeWidth = 2;

  static final Paint _targetPaint = Paint()
    ..color = const Color(0xFFF2F2F5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track de fundo cheio.
    canvas.drawArc(rect, _startAngle, _sweepFull, false, _trackPaint);

    // Ticks principais a cada 7 unidades (0, 7, 14, 21).
    for (var i = 0; i <= 3; i++) {
      final t = i / 3;
      final angle = _startAngle + _sweepFull * t;
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - 22),
        center.dy + math.sin(angle) * (radius - 22),
      );
      final outer = Offset(
        center.dx + math.cos(angle) * (radius - 6),
        center.dy + math.sin(angle) * (radius - 6),
      );
      canvas.drawLine(inner, outer, _tickPaint);
    }

    // Arco de strain colorido — gradient varia por intensidade.
    final progress = (value / _maxStrain).clamp(0, 1).toDouble();
    if (progress > 0.001) {
      final sweep = _sweepFull * progress;
      final shader = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + sweep,
        colors: [
          const Color(0xFF5AC8FA),
          const Color(0xFF7B8FFF),
          const Color(0xFFB47BFF),
          const Color(0xFFFF5CC8),
        ],
        stops: const [0.0, 0.45, 0.78, 1.0],
        transform: GradientRotation(_startAngle),
      ).createShader(rect);
      _arcPaint.shader = shader;
      canvas.drawArc(rect, _startAngle, sweep, false, _arcPaint);
    }

    // Marca do target — pequeno tracinho branco no arco.
    if (target > 0 && target <= _maxStrain) {
      final t = target / _maxStrain;
      final angle = _startAngle + _sweepFull * t;
      final innerR = radius - 18;
      final outerR = radius + 4;
      final start = Offset(
        center.dx + math.cos(angle) * innerR,
        center.dy + math.sin(angle) * innerR,
      );
      final end = Offset(
        center.dx + math.cos(angle) * outerR,
        center.dy + math.sin(angle) * outerR,
      );
      canvas.drawLine(start, end, _targetPaint);
    }

    // Numeral centralizado — usa monospace pra leitura tipo display.
    _drawCenterText(canvas, size, center);
  }

  void _drawCenterText(Canvas canvas, Size size, Offset center) {
    final big = TextPainter(
      text: TextSpan(
        text: value.toStringAsFixed(1),
        style: TextStyle(
          color: FitnessBrand.strainColor(value),
          fontSize: 56,
          fontWeight: FontWeight.w300,
          letterSpacing: -2,
          fontFamily: FitnessBrand.displayMonoFontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    big.paint(
      canvas,
      Offset(center.dx - big.width / 2, center.dy - big.height / 2 - 6),
    );

    final captionStyle = TextStyle(
      color: const Color(0xFF7E7E8A),
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.6,
    );
    final caption = TextPainter(
      text: TextSpan(text: label.toUpperCase(), style: captionStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    caption.paint(
      canvas,
      Offset(center.dx - caption.width / 2, center.dy + big.height / 2 - 8),
    );

    final targetLabel = TextPainter(
      text: TextSpan(
        text: 'alvo  ${target.toStringAsFixed(1)}',
        style: const TextStyle(
          color: Color(0xFF7E7E8A),
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    targetLabel.paint(
      canvas,
      Offset(
        center.dx - targetLabel.width / 2,
        center.dy + big.height / 2 + 12,
      ),
    );
  }

  @override
  bool shouldRepaint(_StrainDialPainter old) =>
      old.value != value || old.target != target || old.label != label;
}
