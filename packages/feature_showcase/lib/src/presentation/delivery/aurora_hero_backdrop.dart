import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Backdrop animado do hero da home Aurora — ondulacoes verdes
/// suaves (camadas de senoides) com folhas estilizadas flutuando.
/// Performance: paints cacheados, `super(repaint: ...)` direto pro
/// controller. Vive em `RepaintBoundary` no caller.
class AuroraHeroBackdrop extends StatefulWidget {
  const AuroraHeroBackdrop({
    required this.waveColor,
    required this.leafColor,
    super.key,
  });

  /// Cor base das ondas (geralmente primary com alpha baixo).
  final Color waveColor;

  /// Cor das folhas flutuantes (geralmente accent com alpha medio).
  final Color leafColor;

  @override
  State<AuroraHeroBackdrop> createState() => _AuroraHeroBackdropState();
}

class _AuroraHeroBackdropState extends State<AuroraHeroBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        isComplex: true,
        willChange: true,
        painter: _AuroraHeroBackdropPainter(
          controller: _controller,
          waveColor: widget.waveColor,
          leafColor: widget.leafColor,
        ),
      ),
    );
  }
}

class _AuroraHeroBackdropPainter extends CustomPainter {
  _AuroraHeroBackdropPainter({
    required this.controller,
    required this.waveColor,
    required this.leafColor,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final Color waveColor;
  final Color leafColor;

  // Posicoes estaticas das folhas (x, y, phaseOffset). Cada uma tem
  // bob proprio.
  static const List<(double, double, double)> _leaves = [
    (0.10, 0.18, 0.10),
    (0.78, 0.28, 0.55),
    (0.32, 0.72, 0.30),
    (0.86, 0.78, 0.85),
    (0.20, 0.48, 0.70),
  ];

  late final Paint _waveLightPaint = Paint()
    ..color = waveColor.withValues(alpha: 0.10)
    ..style = PaintingStyle.fill;

  late final Paint _waveMidPaint = Paint()
    ..color = waveColor.withValues(alpha: 0.16)
    ..style = PaintingStyle.fill;

  late final Paint _leafFill = Paint()
    ..color = leafColor
    ..style = PaintingStyle.fill;

  late final Paint _leafStroke = Paint()
    ..color = leafColor.withValues(alpha: 0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final phase = controller.value;

    // Duas senoides empilhadas pra dar "ondas do campo".
    _paintWave(canvas, size, baselineRatio: 0.65, amplitude: 18, wavelength: size.width * 0.6, phase: phase, paint: _waveLightPaint);
    _paintWave(canvas, size, baselineRatio: 0.78, amplitude: 26, wavelength: size.width * 0.8, phase: phase + 0.3, paint: _waveMidPaint);

    _paintLeaves(canvas, size, phase);
  }

  void _paintWave(
    Canvas canvas,
    Size size, {
    required double baselineRatio,
    required double amplitude,
    required double wavelength,
    required double phase,
    required Paint paint,
  }) {
    final baseline = size.height * baselineRatio;
    final path = Path()..moveTo(0, baseline);
    for (var x = 0.0; x <= size.width; x += 6) {
      final t = (x + phase * wavelength) / wavelength * 2 * math.pi;
      final y = baseline + amplitude * math.sin(t);
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintLeaves(Canvas canvas, Size size, double phase) {
    final unit = math.min(size.width, size.height);
    for (final leaf in _leaves) {
      final leafPhase = (phase + leaf.$3) % 1.0;
      // Bob suave vertical.
      final dy = math.sin(leafPhase * 2 * math.pi) * size.height * 0.025;
      final cx = leaf.$1 * size.width;
      final cy = leaf.$2 * size.height + dy;
      final r = unit * 0.04;

      canvas
        ..save()
        ..translate(cx, cy)
        ..rotate(leaf.$3 * math.pi);

      final path = Path()
        ..moveTo(0, -r * 1.8)
        ..quadraticBezierTo(r * 1.2, 0, 0, r * 1.8)
        ..quadraticBezierTo(-r * 1.2, 0, 0, -r * 1.8)
        ..close();

      canvas
        ..drawPath(path, _leafFill)
        ..drawLine(Offset(0, -r * 1.5), Offset(0, r * 1.5), _leafStroke)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_AuroraHeroBackdropPainter old) {
    return old.waveColor != waveColor || old.leafColor != leafColor;
  }
}
