import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Backdrop animado do hero da home Garoa. Desenha graos de cafe
/// flutuando devagar sobre o creme + tres plumas de vapor subindo,
/// numa metafora de "manha calma" coerente com a tagline. Sem assets.
///
/// Performance: Paint cacheados, `shouldRepaint` so retorna true quando
/// `phase` realmente avancou e vive em `RepaintBoundary`. Layout fica
/// no caller — o backdrop preenche `Size.infinite`.
class GaroaHeroBackdrop extends StatefulWidget {
  const GaroaHeroBackdrop({
    required this.beanColor,
    required this.steamColor,
    super.key,
  });

  /// Cor dos graos flutuando ao fundo (geralmente primary com alpha).
  final Color beanColor;

  /// Cor das plumas de vapor (geralmente accent ou onSurfaceMuted).
  final Color steamColor;

  @override
  State<GaroaHeroBackdrop> createState() => _GaroaHeroBackdropState();
}

class _GaroaHeroBackdropState extends State<GaroaHeroBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            size: Size.infinite,
            isComplex: true,
            willChange: true,
            painter: _GaroaHeroBackdropPainter(
              phase: _controller.value,
              beanColor: widget.beanColor,
              steamColor: widget.steamColor,
            ),
          );
        },
      ),
    );
  }
}

class _GaroaHeroBackdropPainter extends CustomPainter {
  _GaroaHeroBackdropPainter({
    required this.phase,
    required this.beanColor,
    required this.steamColor,
  });

  /// Fase do loop em [0, 1).
  final double phase;
  final Color beanColor;
  final Color steamColor;

  // Posicoes estaticas dos graos (x em [0, 1], y_base em [0, 1],
  // radius_factor relativo a min(w, h)). Cada um tem fase propria
  // pra dar a impressao de movimento aleatorio.
  static const List<(double, double, double, double)> _beans = [
    (0.08, 0.18, 0.018, 0.10),
    (0.21, 0.72, 0.022, 0.40),
    (0.35, 0.30, 0.016, 0.65),
    (0.46, 0.84, 0.014, 0.25),
    (0.58, 0.20, 0.020, 0.75),
    (0.71, 0.58, 0.018, 0.05),
    (0.83, 0.30, 0.014, 0.55),
    (0.92, 0.78, 0.016, 0.85),
    (0.15, 0.50, 0.012, 0.20),
    (0.65, 0.86, 0.020, 0.45),
  ];

  late final Paint _beanFill = Paint()
    ..color = beanColor
    ..style = PaintingStyle.fill;

  late final Paint _beanStroke = Paint()
    ..color = beanColor.withValues(alpha: beanColor.a * 0.6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  late final Paint _steamPaint = Paint()
    ..color = steamColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    _paintBeans(canvas, size);
    _paintSteam(canvas, size);
  }

  void _paintBeans(Canvas canvas, Size size) {
    final unit = math.min(size.width, size.height);
    for (final bean in _beans) {
      final phaseOffset = bean.$4;
      // Bob vertical sutil (+- 4% da altura) com fase propria.
      final beatPhase = (phase + phaseOffset) % 1.0;
      final dy = math.sin(beatPhase * 2 * math.pi) * size.height * 0.04;
      final center = Offset(
        bean.$1 * size.width,
        bean.$2 * size.height + dy,
      );
      final r = bean.$3 * unit;
      final rect = Rect.fromCenter(
        center: center,
        width: r * 2,
        height: r * 2.6,
      );
      canvas
        ..drawOval(rect, _beanFill)
        // Risco central do grao — caracteristica visual.
        ..drawLine(
          Offset(center.dx, center.dy - r * 1.1),
          Offset(center.dx, center.dy + r * 1.1),
          _beanStroke,
        );
    }
  }

  void _paintSteam(Canvas canvas, Size size) {
    // Tres plumas de vapor subindo. Posicoes ancoradas no canto
    // inferior direito — a maioria do espaco fica livre pra texto a
    // esquerda. Cada pluma e uma senoide vertical que se desloca em
    // amplitude com a fase.
    final origins = [
      Offset(size.width * 0.72, size.height * 0.95),
      Offset(size.width * 0.80, size.height * 0.95),
      Offset(size.width * 0.88, size.height * 0.95),
    ];
    final phases = [0.0, 0.33, 0.66];
    for (var i = 0; i < origins.length; i++) {
      final origin = origins[i];
      final pPhase = (phase + phases[i]) % 1.0;
      final path = Path()..moveTo(origin.dx, origin.dy);
      const segmentCount = 24;
      final height = size.height * 0.55;
      for (var s = 1; s <= segmentCount; s++) {
        final t = s / segmentCount;
        final y = origin.dy - height * t;
        // Amplitude cresce com t pra simular vapor abrindo no topo.
        final amp = 6 + t * 14;
        // Fase espacial + fase temporal — onda lateral.
        final wave =
            math.sin((t * math.pi * 3) + (pPhase * 2 * math.pi)) * amp;
        path.lineTo(origin.dx + wave, y);
      }
      // Fade no topo: pintar com alpha decrescente nao da no stroke
      // path puro; em vez disso, pintar em dois segmentos com paints
      // de alpha diferente seria caro. Mantemos um stroke unico —
      // tradeoff aceitavel pra uma decoracao discreta.
      canvas.drawPath(path, _steamPaint);
    }
  }

  @override
  bool shouldRepaint(_GaroaHeroBackdropPainter old) {
    return old.phase != phase ||
        old.beanColor != beanColor ||
        old.steamColor != steamColor;
  }
}
