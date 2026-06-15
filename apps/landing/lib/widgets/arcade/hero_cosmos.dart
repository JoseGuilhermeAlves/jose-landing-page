import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Campo de corpos celestes do hero — sprites recortados do cosmos_3
/// (replica exata da referencia) espalhados em disposicao curada pelos
/// cantos/bordas (longe do texto e do buraco negro). Cada corpo flutua
/// devagar (cosmos "passando"), com fase/velocidade proprias. Decorativo,
/// IgnorePointer.
class HeroCosmos extends StatefulWidget {
  const HeroCosmos({super.key});

  /// x,y normalizados 0..1; diametro px; corpo; fase de drift.
  static const List<_Body> _bodies = [
    _Body(0.15, 0.16, 172, CelestialBody.saturn, 0),
    _Body(0.88, 0.15, 124, CelestialBody.lava, 1.3),
    _Body(0.05, 0.74, 124, CelestialBody.ice, 2.4),
    _Body(0.31, 0.9, 96, CelestialBody.earth, 3.1),
    _Body(0.95, 0.72, 120, CelestialBody.moon, 4.2),
    _Body(0.64, 0.08, 84, CelestialBody.portal, 5),
    _Body(0.5, 0.96, 74, CelestialBody.sun, 5.7),
  ];

  @override
  State<HeroCosmos> createState() => _HeroCosmosState();
}

class _HeroCosmosState extends State<HeroCosmos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    // Loop longo — drift lento, leitura de "passando".
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          return AnimatedBuilder(
            animation: _drift,
            builder: (context, _) {
              final t = _drift.value * 2 * math.pi;
              return Stack(
                children: [
                  for (final b in HeroCosmos._bodies) _positioned(b, w, h, t),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _positioned(_Body b, double w, double h, double t) {
    // Drift suave: orbita minuscula (amplitude ~6% do corpo) em fase propria.
    final amp = b.size * 0.06;
    final dx = math.cos(t + b.phase) * amp;
    final dy = math.sin(t * 0.8 + b.phase) * amp;
    return Positioned(
      left: b.x * w - b.size / 2 + dx,
      top: b.y * h - b.size / 2 + dy,
      width: b.size,
      height: b.size,
      child: CelestialPlanet(body: b.body, seed: b.phase.round() + 1),
    );
  }
}

class _Body {
  const _Body(this.x, this.y, this.size, this.body, this.phase);

  final double x;
  final double y;
  final double size;
  final CelestialBody body;
  final double phase;
}
