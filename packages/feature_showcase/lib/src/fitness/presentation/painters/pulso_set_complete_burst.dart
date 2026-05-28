import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pequena explosao de particulas pra celebrar set concluido. Wrapper
/// stateful — dispara animacao on construct e remove via callback ao
/// terminar. Cores derivam do strain accumulado (passado por param).
class PulsoSetCompleteBurst extends StatefulWidget {
  const PulsoSetCompleteBurst({
    required this.color,
    this.onCompleted,
    this.diameter = 80,
    super.key,
  });

  final Color color;
  final VoidCallback? onCompleted;
  final double diameter;

  @override
  State<PulsoSetCompleteBurst> createState() => _PulsoSetCompleteBurstState();
}

class _PulsoSetCompleteBurstState extends State<PulsoSetCompleteBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward().whenComplete(() => widget.onCompleted?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.diameter,
          child: CustomPaint(
            painter: _BurstPainter(color: widget.color, progress: _controller),
          ),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.color, required this.progress})
    : super(repaint: progress);

  final Color color;
  final Animation<double> progress;

  static const int _count = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t >= 1) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.shortestSide / 2;
    final eased = Curves.easeOutCubic.transform(t);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < _count; i++) {
      final angle = (i / _count) * math.pi * 2 + t * 0.6;
      final dist = maxR * eased * (0.7 + 0.3 * math.sin(i.toDouble()));
      final pos = Offset(
        center.dx + math.cos(angle) * dist,
        center.dy + math.sin(angle) * dist,
      );
      paint.color = color.withValues(alpha: 1 - eased);
      canvas.drawCircle(pos, 3 * (1 - eased * 0.6), paint);
    }

    // Anel pulsante.
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 1 - eased)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * (1 - eased);
    canvas.drawCircle(center, maxR * eased * 0.9, ringPaint);
  }

  @override
  bool shouldRepaint(_BurstPainter old) => false;
}
