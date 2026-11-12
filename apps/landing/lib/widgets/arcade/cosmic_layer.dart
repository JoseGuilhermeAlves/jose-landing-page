import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Camada de "vida" do fundo global, entre o `CalmBackdrop` e o conteudo.
///
/// Redesign 2026-11 (2a passada): o fundo calmo ficou elegante mas sem vida.
/// Volta o universo, com disciplina: nebulosas difusas e uma galaxia distante
/// em baixa intensidade, e planetas pixel **ancorados nas bordas** (parte
/// fora da tela, "espiando"), flutuando devagar — nunca no miolo da coluna
/// de leitura. Fica fixo enquanto o conteudo rola, o que da profundidade.
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
    duration: const Duration(seconds: 48),
  );

  /// Planetas: x/y normalizados (podem passar de 0..1 = parte fora da tela),
  /// diametro relativo ao lado menor, corpo, cor do halo, fase do flutuar.
  static const _desktop = <_Orb>[
    _Orb(0.985, 0.16, 0.20, CelestialBody.saturn, Color(0xFFFF3CAC), 0),
    _Orb(0.955, 0.80, 0.13, CelestialBody.lava, Color(0xFFFF6A1E), 1.7),
    _Orb(0.01, 0.56, 0.07, CelestialBody.ice, Color(0xFF36E0FF), 3.1),
    _Orb(0.992, 0.47, 0.045, CelestialBody.earth, Color(0xFF2FA8E0), 4.4),
  ];

  static const _mobile = <_Orb>[
    _Orb(1.02, 0.12, 0.34, CelestialBody.saturn, Color(0xFFFF3CAC), 0),
    _Orb(-0.04, 0.86, 0.22, CelestialBody.lava, Color(0xFFFF6A1E), 1.7),
  ];

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
          final orbs = mobile ? _mobile : _desktop;
          final unit = math.min(w, h);

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
              for (final o in orbs)
                _FloatingOrb(orb: o, t: _t, w: w, h: h, unit: unit),
            ],
          );
        },
      ),
    );
  }
}

class _FloatingOrb extends StatelessWidget {
  const _FloatingOrb({
    required this.orb,
    required this.t,
    required this.w,
    required this.h,
    required this.unit,
  });

  final _Orb orb;
  final Animation<double> t;
  final double w;
  final double h;
  final double unit;

  @override
  Widget build(BuildContext context) {
    final d = orb.size * unit;
    final box = d * 1.8;
    // O planeta e pintado uma vez (RepaintBoundary); so a posicao anima.
    final planet = RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orb.glow.withValues(alpha: 0.35),
                  orb.glow.withValues(alpha: 0),
                ],
                stops: const [0.34, 1],
              ),
            ),
          ),
          Center(
            child: SizedBox.square(
              dimension: d,
              child: CelestialPlanet(body: orb.body, seed: orb.seed),
            ),
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: t,
      child: Opacity(opacity: 0.85, child: planet),
      builder: (context, child) {
        final a = t.value * 2 * math.pi + orb.phase;
        final dy = math.sin(a) * unit * 0.012;
        final dx = math.cos(a * 0.5) * unit * 0.006;
        return Positioned(
          left: orb.x * w - box / 2 + dx,
          top: orb.y * h - box / 2 + dy,
          width: box,
          height: box,
          child: child!,
        );
      },
    );
  }
}

class _Orb {
  const _Orb(this.x, this.y, this.size, this.body, this.glow, this.phase);

  final double x;
  final double y;
  final double size;
  final CelestialBody body;
  final Color glow;
  final double phase;

  int get seed => (x * 100).round() + (y * 13).round() + 1;
}
