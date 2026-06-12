import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Badge animado de confirmacao compartilhado pelos mocks (Vitral,
/// Solar) — circulo preenchido com check em duas linhas crescendo de
/// 30% a 100% da animacao. Cada marca parametriza as cores via tema.
/// Painter recebe controller direto via `super(repaint:)` pra pular
/// build e layout no pipeline (ver CLAUDE.md).
class ShowcaseConfirmationBadge extends StatefulWidget {
  const ShowcaseConfirmationBadge({
    required this.fillColor,
    required this.checkColor,
    required this.ringColor,
    this.size = 96,
    super.key,
  });

  final Color fillColor;
  final Color checkColor;
  final Color ringColor;
  final double size;

  @override
  State<ShowcaseConfirmationBadge> createState() =>
      _ShowcaseConfirmationBadgeState();
}

class _ShowcaseConfirmationBadgeState extends State<ShowcaseConfirmationBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ShowcaseConfirmationBadgePainter(
            controller: _controller,
            fillColor: widget.fillColor,
            checkColor: widget.checkColor,
            ringColor: widget.ringColor,
          ),
        ),
      ),
    );
  }
}

class _ShowcaseConfirmationBadgePainter extends CustomPainter {
  _ShowcaseConfirmationBadgePainter({
    required this.controller,
    required this.fillColor,
    required this.checkColor,
    required this.ringColor,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final Color fillColor;
  final Color checkColor;
  final Color ringColor;

  late final Paint _fillPaint = Paint()
    ..color = fillColor
    ..style = PaintingStyle.fill;

  late final Paint _ringPaint = Paint()
    ..color = ringColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  late final Paint _checkPaint = Paint()
    ..color = checkColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final t = controller.value.clamp(0.0, 1.0);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 6;

    // Pulse de escala 0 -> 1.08 -> 1.0.
    final scale = t < 0.6
        ? 1.08 * Curves.easeOutBack.transform(t / 0.6)
        : (1.08 - 0.08 * ((t - 0.6) / 0.4));

    canvas
      ..save()
      ..translate(cx, cy)
      ..scale(scale)
      ..translate(-cx, -cy)
      ..drawCircle(Offset(cx, cy), radius * 0.78, _fillPaint)
      ..drawCircle(Offset(cx, cy), radius, _ringPaint);

    final checkProgress = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    if (checkProgress > 0) {
      final start = Offset(cx - radius * 0.35, cy + radius * 0.02);
      final mid = Offset(cx - radius * 0.05, cy + radius * 0.30);
      final end = Offset(cx + radius * 0.42, cy - radius * 0.26);
      if (checkProgress <= 0.5) {
        final p1 = Offset.lerp(start, mid, checkProgress / 0.5)!;
        canvas.drawLine(start, p1, _checkPaint);
      } else {
        canvas
          ..drawLine(start, mid, _checkPaint)
          ..drawLine(
            mid,
            Offset.lerp(mid, end, (checkProgress - 0.5) / 0.5)!,
            _checkPaint,
          );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShowcaseConfirmationBadgePainter old) {
    return old.fillColor != fillColor ||
        old.checkColor != checkColor ||
        old.ringColor != ringColor;
  }
}
