import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Campo de corpos celestes do hero — planetas pixel (CustomPainter) que
/// PASSAM devagar pela tela da direita pra esquerda, junto com o starfield
/// do backdrop (parallax: alguns mais rapidos). Ficam nas faixas de topo e
/// base pra nao atravessar o texto/portrait. Decorativo, IgnorePointer.
class HeroCosmos extends StatefulWidget {
  const HeroCosmos({super.key});

  /// x inicial 0..1; y 0..1 (faixas topo/base); diametro px; corpo;
  /// passo de parallax (1 = lento, 2 = ~2x).
  static const List<_Body> _bodies = [
    _Body(0.10, 0.14, 150, CelestialBody.saturn, 1),
    _Body(0.78, 0.10, 112, CelestialBody.lava, 1),
    _Body(0.45, 0.18, 88, CelestialBody.ice, 2),
    _Body(0.20, 0.86, 100, CelestialBody.earth, 1),
    _Body(0.86, 0.90, 80, CelestialBody.moon, 2),
    _Body(0.55, 0.82, 120, CelestialBody.sun, 1),
  ];

  @override
  State<HeroCosmos> createState() => _HeroCosmosState();
}

class _HeroCosmosState extends State<HeroCosmos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scroll;

  @override
  void initState() {
    super.initState();
    // 1 volta = travessia de um "passo" de parallax. Loop sem salto: x usa
    // multiplos inteiros do span de wrap (ver _xFor).
    _scroll = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.stop();
    } else if (!_scroll.isAnimating) {
      _scroll.repeat();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Span de wrap em fracao de largura (entra/sai com folga).
  static const double _span = 1.3;

  /// x normalizado com wrap continuo (seamless: desloca multiplo inteiro
  /// de [_span] por volta, entao value 0 e 1 coincidem).
  double _xFor(_Body b) {
    var x = (b.x - _scroll.value * _span * b.step) % _span;
    if (x < 0) x += _span;
    return x - 0.15; // folga a esquerda
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          return AnimatedBuilder(
            animation: _scroll,
            builder: (context, _) {
              return Stack(
                children: [
                  for (final b in HeroCosmos._bodies)
                    Positioned(
                      left: _xFor(b) * w - b.size / 2,
                      top: b.y * h - b.size / 2,
                      width: b.size,
                      height: b.size,
                      child: CelestialPlanet(body: b.body, seed: b.seed),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Body {
  const _Body(this.x, this.y, this.size, this.body, this.step);

  final double x;
  final double y;
  final double size;
  final CelestialBody body;
  final int step;

  /// Seed estavel por posicao (varia o noise entre corpos do mesmo tipo).
  int get seed => (x * 100).round() + (y * 13).round() + 1;
}
