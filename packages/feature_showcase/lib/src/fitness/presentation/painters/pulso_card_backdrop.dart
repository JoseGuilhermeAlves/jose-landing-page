import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Backdrop animado pro card de preview do Pulso no showcase grid.
/// Grid dark com varredura vertical lenta + glow verde no centro
/// (apela pra leitura de monitor cardiaco / Whoop dial). Leve o
/// suficiente pra rodar paralelo aos outros 4 cards sem comer frame.
class PulsoCardBackdrop extends StatefulWidget {
  const PulsoCardBackdrop({super.key});

  @override
  State<PulsoCardBackdrop> createState() => _PulsoCardBackdropState();
}

class _PulsoCardBackdropState extends State<PulsoCardBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _PulsoCardBackdropPainter(progress: _controller),
        size: Size.infinite,
      ),
    );
  }
}

class _PulsoCardBackdropPainter extends CustomPainter {
  _PulsoCardBackdropPainter({required this.progress})
    : super(repaint: progress);

  final Animation<double> progress;

  static final Paint _bgPaint = Paint()..color = const Color(0xFF08080B);
  static final Paint _gridPaint = Paint()
    ..color = const Color(0xFF1A1A22)
    ..strokeWidth = 1;
  static final Paint _sweepPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _glowPaint = Paint()
    ..color = const Color(0xFF00D982).withValues(alpha: 0.18)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _bgPaint);

    // Grid de hairlines.
    const step = 18.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _gridPaint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }

    // Glow central pulsante.
    final t = progress.value;
    final pulse = 0.7 + 0.3 * math.sin(t * math.pi * 2);
    canvas.save();
    canvas.translate(size.width * 0.62, size.height * 0.52);
    canvas.scale(pulse);
    canvas.drawCircle(Offset.zero, 60, _glowPaint);
    canvas.restore();

    // Sweep horizontal lento — varre uma faixa luminosa de cima a baixo.
    final sweepY = (t * size.height * 1.4) - 30;
    _sweepPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF00D982).withValues(alpha: 0),
        const Color(0xFF00D982).withValues(alpha: 0.16),
        const Color(0xFF00D982).withValues(alpha: 0),
      ],
    ).createShader(Rect.fromLTWH(0, sweepY, size.width, 38));
    canvas.drawRect(Rect.fromLTWH(0, sweepY, size.width, 38), _sweepPaint);

    // EKG-style cursor ponto no canto inferior direito.
    final cursorX = size.width * 0.9;
    final cursorY = size.height * 0.78;
    final cursorPulse = (math.sin(t * math.pi * 4) + 1) / 2;
    final cursorPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF5AC8FA),
        const Color(0xFF00D982),
        cursorPulse,
      )!;
    canvas.drawCircle(
      Offset(cursorX, cursorY),
      3 + cursorPulse * 2,
      cursorPaint,
    );
  }

  @override
  bool shouldRepaint(_PulsoCardBackdropPainter old) => false;
}
