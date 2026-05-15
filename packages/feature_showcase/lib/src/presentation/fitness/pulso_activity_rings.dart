import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Tres aneis de atividade concentricos no estilo Apple Fitness —
/// cada um representa uma metrica do dia. Os valores chegam ja
/// normalizados (0..1) do caller; cada anel anima de 0 ate o valor
/// final uma vez no mount (e quando os progresses mudam).
///
/// Acompanha textos abaixo com labels e valores absolutos (ex.: "0/13
/// SETS"). E o "vital sign" da home do Pulso.
class PulsoActivityRings extends StatefulWidget {
  const PulsoActivityRings({
    required this.outerProgress,
    required this.middleProgress,
    required this.innerProgress,
    required this.outerColor,
    required this.middleColor,
    required this.innerColor,
    this.size = 180,
    super.key,
  });

  /// Progresso 0..1 do anel mais externo. Convenção do mock: sets.
  final double outerProgress;

  /// Progresso 0..1 do anel do meio. Convenção: tempo / minutos.
  final double middleProgress;

  /// Progresso 0..1 do anel mais interno. Convenção: exercicios.
  final double innerProgress;

  final Color outerColor;
  final Color middleColor;
  final Color innerColor;

  final double size;

  @override
  State<PulsoActivityRings> createState() => _PulsoActivityRingsState();
}

class _PulsoActivityRingsState extends State<PulsoActivityRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.standard,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant PulsoActivityRings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.outerProgress != widget.outerProgress ||
        oldWidget.middleProgress != widget.middleProgress ||
        oldWidget.innerProgress != widget.innerProgress) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RepaintBoundary(
      child: SizedBox(
        key: const Key('pulso-activity-rings'),
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final t = _animation.value;
            return CustomPaint(
              painter: _PulsoActivityRingsPainter(
                outerProgress: widget.outerProgress * t,
                middleProgress: widget.middleProgress * t,
                innerProgress: widget.innerProgress * t,
                outerColor: widget.outerColor,
                middleColor: widget.middleColor,
                innerColor: widget.innerColor,
                trackColor: colors.surfaceMuted,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PulsoActivityRingsPainter extends CustomPainter {
  _PulsoActivityRingsPainter({
    required this.outerProgress,
    required this.middleProgress,
    required this.innerProgress,
    required this.outerColor,
    required this.middleColor,
    required this.innerColor,
    required this.trackColor,
  });

  static const double _strokeWidth = 14;
  static const double _gap = 4;

  final double outerProgress;
  final double middleProgress;
  final double innerProgress;
  final Color outerColor;
  final Color middleColor;
  final Color innerColor;
  final Color trackColor;

  late final Paint _trackPaint = Paint()
    ..color = trackColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth;

  late final Paint _activePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - _strokeWidth / 2;

    // Tres raios: externo, meio, interno. `gap` separa visualmente.
    final outerRadius = maxRadius;
    final middleRadius = maxRadius - _strokeWidth - _gap;
    final innerRadius = maxRadius - 2 * (_strokeWidth + _gap);

    if (innerRadius <= 0) return;

    _drawRing(canvas, center, outerRadius, outerProgress, outerColor);
    _drawRing(canvas, center, middleRadius, middleProgress, middleColor);
    _drawRing(canvas, center, innerRadius, innerProgress, innerColor);
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
    Color color,
  ) {
    // Track fica em alpha baixo da cor do ring — da unidade visual
    // mesmo nos zeros.
    _trackPaint.color = color.withValues(alpha: 0.15);
    canvas.drawCircle(center, radius, _trackPaint);
    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    _activePaint.color = color;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, _activePaint);
  }

  @override
  bool shouldRepaint(_PulsoActivityRingsPainter old) {
    return old.outerProgress != outerProgress ||
        old.middleProgress != middleProgress ||
        old.innerProgress != innerProgress ||
        old.outerColor != outerColor;
  }
}
