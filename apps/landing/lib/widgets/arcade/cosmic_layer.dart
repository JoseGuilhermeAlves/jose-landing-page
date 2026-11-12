import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Camada de "vida" do fundo global, entre o `CalmBackdrop` e o conteudo.
///
/// Redesign 2026-11 (2a passada): o fundo calmo ficou elegante mas sem vida.
/// Volta o universo: nebulosas difusas, uma galaxia distante e os planetas
/// pixel do hero antigo ATRAVESSANDO o ceu da direita pra esquerda (parallax
/// por `step`, wrap continuo), com halo neon. Camada fixa: o conteudo rola
/// por cima, o que da profundidade.
///
/// Respeita `disableAnimations`. Decorativo (`IgnorePointer`).
class CosmicLayer extends StatefulWidget {
  const CosmicLayer({super.key});

  @override
  State<CosmicLayer> createState() => _CosmicLayerState();
}

class _CosmicLayerState extends State<CosmicLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  );

  /// Planetas que ATRAVESSAM o ceu da direita pra esquerda (como no hero
  /// antigo): x inicial 0..1, y 0..1 da viewport, diametro em px, corpo,
  /// passo de parallax (1 = lento, 2 = ~2x) e cor do halo.
  static const _bodies = <_Body>[
    _Body(0.11, 0.17, 140, CelestialBody.saturn, 1, Color(0xFFFF3CAC)),
    _Body(0.49, 0.085, 66, CelestialBody.ice, 2, Color(0xFF36E0FF)),
    _Body(0.38, 0.62, 72, CelestialBody.portal, 2, Color(0xFFE83CC8)),
    _Body(0.27, 0.40, 88, CelestialBody.earth, 1, Color(0xFF2FA8E0)),
    _Body(0.74, 0.80, 92, CelestialBody.lava, 1, Color(0xFFFF6A1E)),
  ];

  /// Span de wrap em fracao de largura (entra/sai com folga).
  static const double _span = 1.3;

  static const _nebulas = [
    CosmosNebula(
      canvasAnchor: Offset(0.82, 0.22),
      radiusPixels: 260,
      color: Color(0xFFFF2EA0),
      density: 0.10,
      seed: 3,
    ),
    CosmosNebula(
      canvasAnchor: Offset(0.30, 0.78),
      radiusPixels: 240,
      color: Color(0xFF6A3CFF),
      density: 0.10,
      seed: 11,
    ),
    CosmosNebula(
      canvasAnchor: Offset(0.95, 0.70),
      radiusPixels: 200,
      color: Color(0xFF14C2D6),
      density: 0.08,
      seed: 5,
    ),
  ];

  static const _galaxies = [
    CosmosGalaxy(
      canvasAnchor: Offset(0.42, 0.10),
      radiusPixels: 120,
      coreColor: Color(0xFFFFE6C2),
      armColor: Color(0xFF49E8FF),
      tiltY: 0.38,
      rotation: 0.6,
      dustCount: 180,
      seed: 7,
    ),
  ];

  /// x normalizado com wrap continuo (seamless: desloca multiplo inteiro
  /// de [_span] por volta, entao value 0 e 1 coincidem).
  double _xFor(_Body b) {
    var x = (b.x - _t.value * _span * b.step) % _span;
    if (x < 0) x += _span;
    return x - 0.15;
  }

  Widget _planet(
    _Body b, {
    required double w,
    required double h,
    required double scale,
  }) {
    final d = b.size * scale;
    final box = d * 1.7;
    // Leve flutuar vertical alem da travessia.
    final bob = math.sin(_t.value * 2 * math.pi * 3 + b.x * 9) * 6 * scale;
    return Positioned(
      left: _xFor(b) * w - box / 2,
      top: b.y * h - box / 2 + bob,
      width: box,
      height: box,
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    b.glow.withValues(alpha: 0.45),
                    b.glow.withValues(alpha: 0),
                  ],
                  stops: const [0.34, 1],
                ),
              ),
            ),
            Center(
              child: SizedBox.square(
                dimension: d,
                child: CelestialPlanet(body: b.body, seed: b.seed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _t.stop();
    } else if (!_t.isAnimating) {
      _t.repeat();
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          final mobile = w < 600;
          final scale = mobile ? 0.6 : 1.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 0.7,
                child: RepaintBoundary(
                  child: CustomPaint(
                    isComplex: true,
                    willChange: true,
                    painter: CosmosPainter(
                      animation: _t,
                      starColor: const Color(0x00000000),
                      pixelSize: mobile ? 0.6 : 1,
                      nebulas: _nebulas,
                      galaxies: mobile ? const [] : _galaxies,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _t,
                builder: (context, _) => Stack(
                  children: [
                    for (final b in _bodies)
                      _planet(b, w: w, h: h, scale: scale),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Body {
  const _Body(this.x, this.y, this.size, this.body, this.step, this.glow);

  final double x;
  final double y;
  final double size;
  final CelestialBody body;
  final int step;

  /// Cor do halo neon (bloom) atras do corpo.
  final Color glow;

  /// Seed estavel por posicao (varia o noise entre corpos do mesmo tipo).
  int get seed => (x * 100).round() + (y * 13).round() + 1;
}
