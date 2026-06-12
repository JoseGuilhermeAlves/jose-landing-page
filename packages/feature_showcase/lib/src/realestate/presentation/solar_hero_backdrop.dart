import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Backdrop animado da home Solar — silhueta de morros ao fundo +
/// sol baixo girando levemente e particulas (poeira/folhas) flutuando.
/// Evoca paisagem do interior sem ilustrar literalmente um imovel.
///
/// Performance: painter usa `super(repaint:)` direto e mantem paints +
/// posicoes-base das particulas cacheados.
class SolarHeroBackdrop extends StatefulWidget {
  const SolarHeroBackdrop({
    required this.skyColor,
    required this.hillColor,
    required this.sunColor,
    required this.particleColor,
    super.key,
  });

  final Color skyColor;
  final Color hillColor;
  final Color sunColor;
  final Color particleColor;

  @override
  State<SolarHeroBackdrop> createState() => _SolarHeroBackdropState();
}

class _SolarHeroBackdropState extends State<SolarHeroBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        isComplex: true,
        willChange: true,
        painter: _SolarHeroBackdropPainter(
          controller: _controller,
          skyColor: widget.skyColor,
          hillColor: widget.hillColor,
          sunColor: widget.sunColor,
          particleColor: widget.particleColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Particle {
  const _Particle(this.x, this.y, this.r, this.speed);
  final double x;
  final double y;
  final double r;
  final double speed;
}

class _SolarHeroBackdropPainter extends CustomPainter {
  _SolarHeroBackdropPainter({
    required this.controller,
    required this.skyColor,
    required this.hillColor,
    required this.sunColor,
    required this.particleColor,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final Color skyColor;
  final Color hillColor;
  final Color sunColor;
  final Color particleColor;

  late final Paint _skyPaint = Paint()
    ..color = skyColor
    ..style = PaintingStyle.fill;

  late final Paint _hillPaint = Paint()
    ..color = hillColor
    ..style = PaintingStyle.fill;

  late final Paint _hillShadePaint = Paint()
    ..color = hillColor.withValues(alpha: 0.65)
    ..style = PaintingStyle.fill;

  late final Paint _sunPaint = Paint()
    ..color = sunColor
    ..style = PaintingStyle.fill;

  // Halo do sol — shader radial criado uma vez por tamanho (o gradiente
  // e desenhado na origem e transladado ate o sol, entao so o raio
  // importa). Evita RadialGradient.createShader + Paint por frame.
  final Paint _haloPaint = Paint();
  double _haloRadius = -1;

  // Paint unico reutilizado pelas 12 particulas (so a cor/alpha muda).
  final Paint _particlePaint = Paint();

  // Morros — geometria estatica por tamanho; recalculada so quando o
  // canvas muda de dimensao.
  Path _farHills = Path();
  Path _nearHills = Path();
  Size _hillsSize = Size.zero;

  // Posicoes-base das particulas (12 pontos) — distribuidas em grid
  // pseudo-aleatorio pra evitar concentracao.
  static final List<_Particle> _particles = List<_Particle>.generate(12, (i) {
    final rand = math.Random(i * 7 + 3);
    return _Particle(
      0.05 + rand.nextDouble() * 0.90,
      0.10 + rand.nextDouble() * 0.55,
      1.2 + rand.nextDouble() * 1.8,
      0.25 + rand.nextDouble() * 0.5,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final t = controller.value;

    // Ceu.
    canvas.drawRect(Offset.zero & size, _skyPaint);

    // Sol baixo se movendo de leste pra oeste devagar (de 0.25 a 0.75
    // do width). Halo radial atras.
    final sunX = size.width * (0.25 + 0.50 * t);
    final sunY = size.height * 0.30;
    final haloRadius = size.height * 0.35;
    if (haloRadius != _haloRadius) {
      _haloRadius = haloRadius;
      _haloPaint.shader = RadialGradient(
        colors: [
          sunColor.withValues(alpha: 0.45),
          skyColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: haloRadius));
    }
    canvas
      ..save()
      ..translate(sunX, sunY)
      ..drawCircle(Offset.zero, haloRadius, _haloPaint)
      ..restore()
      ..drawCircle(Offset(sunX, sunY), size.height * 0.07, _sunPaint);

    // Morros ao fundo (duas camadas) — paths cacheados por tamanho.
    if (size != _hillsSize) {
      _hillsSize = size;
      _farHills = Path()
        ..moveTo(0, size.height * 0.78)
        ..quadraticBezierTo(
          size.width * 0.20,
          size.height * 0.55,
          size.width * 0.40,
          size.height * 0.70,
        )
        ..quadraticBezierTo(
          size.width * 0.60,
          size.height * 0.85,
          size.width * 0.80,
          size.height * 0.65,
        )
        ..quadraticBezierTo(
          size.width * 0.95,
          size.height * 0.55,
          size.width,
          size.height * 0.72,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      _nearHills = Path()
        ..moveTo(0, size.height * 0.90)
        ..quadraticBezierTo(
          size.width * 0.30,
          size.height * 0.70,
          size.width * 0.55,
          size.height * 0.85,
        )
        ..quadraticBezierTo(
          size.width * 0.78,
          size.height * 0.97,
          size.width,
          size.height * 0.82,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }
    canvas
      ..drawPath(_farHills, _hillShadePaint)
      ..drawPath(_nearHills, _hillPaint);

    // Particulas — flutuam para cima com ciclo proprio por seed.
    for (var i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final phase = (t * p.speed + (i / _particles.length)) % 1.0;
      final px = (p.x + math.sin(phase * math.pi * 2) * 0.02) * size.width;
      final py = (p.y - phase * 0.18) * size.height;
      if (py < 0 || py > size.height * 0.78) continue;
      final alpha = (1 - phase).clamp(0.0, 1.0) * 0.6;
      _particlePaint.color = particleColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(px, py), p.r, _particlePaint);
    }
  }

  @override
  bool shouldRepaint(_SolarHeroBackdropPainter old) {
    return old.skyColor != skyColor ||
        old.hillColor != hillColor ||
        old.sunColor != sunColor ||
        old.particleColor != particleColor;
  }
}
