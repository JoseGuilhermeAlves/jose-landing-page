import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Backdrop animado do hero card da aba "Hoje" do mock Pulso. Renderiza
/// uma linha de EKG (heart-rate-style) que rola continuamente da
/// direita pra esquerda, dando vida ao card sem competir com a copy.
///
/// Em dia de descanso, troca o pulso por uma onda senoidal calma —
/// mesma metafora "respiracao" mas com energia menor. A mudanca de
/// modo reinicia o controller pra evitar saltos abruptos.
///
/// Performance: a animacao roda em loop indefinido, mas o painter
/// vive dentro de `RepaintBoundary` pra isolar repaints; os `Paint`
/// sao cacheados como campos; `shouldRepaint` so retorna true quando
/// `phase` realmente avancou.
class PulsoHeroBackdrop extends StatefulWidget {
  const PulsoHeroBackdrop({required this.isRest, super.key});

  /// Quando true, renderiza a onda calma; caso contrario, EKG.
  final bool isRest;

  @override
  State<PulsoHeroBackdrop> createState() => _PulsoHeroBackdropState();
}

class _PulsoHeroBackdropState extends State<PulsoHeroBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _durationFor(widget.isRest),
  )..repeat();

  static Duration _durationFor(bool isRest) =>
      Duration(seconds: isRest ? 8 : 4);

  @override
  void didUpdateWidget(covariant PulsoHeroBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRest != widget.isRest) {
      _controller
        ..stop()
        ..duration = _durationFor(widget.isRest)
        ..forward(from: 0)
        ..repeat();
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            isComplex: true,
            willChange: true,
            painter: _PulsoHeroBackdropPainter(
              phase: _controller.value,
              isRest: widget.isRest,
              lineColor: colors.primary.withValues(
                alpha: widget.isRest ? 0.28 : 0.5,
              ),
              accentColor: colors.primary.withValues(
                alpha: widget.isRest ? 0.12 : 0.22,
              ),
              dotColor: colors.primary.withValues(alpha: 0.1),
            ),
          );
        },
      ),
    );
  }
}

class _PulsoHeroBackdropPainter extends CustomPainter {
  _PulsoHeroBackdropPainter({
    required this.phase,
    required this.isRest,
    required this.lineColor,
    required this.accentColor,
    required this.dotColor,
  });

  /// Pontos normalizados (x em [0..1], y em [-1..1]) de um ciclo de
  /// batimento estilizado P-Q-R-S-T. Tracado a mao pra parecer um EKG
  /// reconhecivel sem ser literal demais.
  static const List<(double, double)> _beatShape = <(double, double)>[
    (0.00, 0),
    (0.12, 0),
    (0.16, -0.08), // onda P pequena
    (0.20, 0),
    (0.26, 0),
    (0.28, 0.18), // Q
    (0.30, -0.92), // R — pico principal
    (0.32, 0.45), // S
    (0.34, 0),
    (0.42, -0.22), // onda T
    (0.50, 0),
    (1.00, 0),
  ];

  final double phase;
  final bool isRest;
  final Color lineColor;
  final Color accentColor;
  final Color dotColor;

  late final Paint _linePaint = Paint()
    ..color = lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _accentPaint = Paint()
    ..color = accentColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _dotPaint = Paint()
    ..color = dotColor
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0 || size.width <= 0) return;

    _paintDotGrid(canvas, size);

    final path = isRest ? _buildRestPath(size) : _buildBeatPath(size);

    // Render do "halo" mais grosso primeiro, depois a linha crispada
    // por cima — barato (so dois drawPath, sem MaskFilter).
    canvas
      ..drawPath(path, _accentPaint)
      ..drawPath(path, _linePaint);
  }

  /// Modo treino: sequencia de batimentos EKG scrollando pra esquerda.
  Path _buildBeatPath(Size size) {
    final baseline = size.height * 0.62;
    const cycleWidth = 170.0;
    const amplitude = 28.0;
    final scrollOffset = phase * cycleWidth;

    final path = Path();
    var first = true;
    // Desenha 1 ciclo a mais a esquerda e direita pra cobrir scroll.
    final beatStartX = -cycleWidth - (scrollOffset % cycleWidth);
    for (var bx = beatStartX; bx < size.width + cycleWidth; bx += cycleWidth) {
      for (final pt in _beatShape) {
        final x = bx + pt.$1 * cycleWidth;
        final y = baseline + pt.$2 * amplitude;
        if (x < -8 || x > size.width + 8) continue;
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }
    }
    return path;
  }

  /// Modo descanso: onda senoidal calma com baixa amplitude.
  Path _buildRestPath(Size size) {
    final baseline = size.height * 0.62;
    const amplitude = 6.0;
    const wavelength = 240.0;
    final scrollOffset = phase * wavelength;

    final path = Path()..moveTo(0, baseline);
    for (var x = 0.0; x <= size.width; x += 4) {
      final t = (x + scrollOffset) / wavelength * 2 * math.pi;
      final y = baseline + amplitude * math.sin(t);
      path.lineTo(x, y);
    }
    return path;
  }

  /// Grade sutil de pontos para profundidade — desloca devagar com o
  /// scroll para nao "engessar" o background.
  void _paintDotGrid(Canvas canvas, Size size) {
    const spacingX = 24.0;
    const spacingY = 24.0;
    final scrollOffset = (phase * spacingX * 2) % spacingX;
    for (var x = -spacingX + scrollOffset; x < size.width; x += spacingX) {
      for (var y = spacingY; y < size.height; y += spacingY) {
        canvas.drawCircle(Offset(x, y), 1, _dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_PulsoHeroBackdropPainter old) {
    return old.phase != phase ||
        old.isRest != isRest ||
        old.lineColor != lineColor;
  }
}
