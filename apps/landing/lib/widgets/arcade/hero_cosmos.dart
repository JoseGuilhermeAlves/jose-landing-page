import 'package:flutter/material.dart';
import 'package:landing/widgets/arcade/pixel_planet.dart';

/// Campo de planetas pixel espalhados pelo fundo do hero (espelha a
/// disposicao do cosmos original: corpos dispersos pelos cantos/bordas,
/// nao orbitando nada). Fica atras do conteudo e do buraco negro. Estatico
/// (sem repaint por frame) — planetas sao decorativos e nao interativos.
class HeroCosmos extends StatelessWidget {
  const HeroCosmos({super.key});

  /// (x, y normalizados 0..1, diametro px, tipo, paleta, ringTilt?).
  static const List<_P> _planets = [
    // Saturno rosa, canto superior-direito.
    _P(0.9, 0.15, 150, PlanetKind.gasGiant, _saturn, 1, 0.34),
    // Gigante gasoso laranja, superior-esquerda.
    _P(0.12, 0.22, 116, PlanetKind.gasGiant, _orange, 2, null),
    // Terran (continentes), meio-esquerda baixo.
    _P(0.04, 0.66, 96, PlanetKind.terran, _terran, 3, null),
    // Lua cinza com crateras, inferior-direita.
    _P(0.93, 0.84, 80, PlanetKind.moon, _moon, 4, null),
    // Lava rachada, inferior-centro.
    _P(0.45, 0.92, 72, PlanetKind.lava, _lava, 5, null),
    // Gelo, topo-centro-direita.
    _P(0.66, 0.06, 64, PlanetKind.ice, _ice, 6, null),
  ];

  static const _saturn = [
    Color(0xFF2E1A2A),
    Color(0xFF6B3A52),
    Color(0xFFB06A82),
    Color(0xFFD99AA8),
    Color(0xFFF6DCE2),
  ];
  static const _orange = [
    Color(0xFF301505),
    Color(0xFF6B3410),
    Color(0xFFC2691E),
    Color(0xFFE89A3E),
    Color(0xFFFFD89A),
  ];
  static const _terran = [
    Color(0xFF0A2740),
    Color(0xFF155A8C),
    Color(0xFF2E8C5A),
    Color(0xFF6AC77E),
    Color(0xFFE6F2D0),
  ];
  static const _moon = [
    Color(0xFF24242E),
    Color(0xFF45454F),
    Color(0xFF727280),
    Color(0xFFA2A2AE),
    Color(0xFFDCDCE6),
  ];
  static const _lava = [
    Color(0xFF2A0A06),
    Color(0xFF6B1810),
    Color(0xFFC23A1E),
    Color(0xFFF2702E),
    Color(0xFFFFC25A),
  ];
  static const _ice = [
    Color(0xFF12283A),
    Color(0xFF2E5A7E),
    Color(0xFF5FA0CC),
    Color(0xFFA9D8F0),
    Color(0xFFEAF8FF),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          return Stack(
            children: [
              for (final p in _planets)
                Positioned(
                  left: p.x * w - p.size / 2,
                  top: p.y * h - p.size / 2,
                  width: p.size,
                  height: p.size,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: PixelPlanetPainter(
                        kind: p.kind,
                        palette: p.palette,
                        seed: p.seed,
                        ringTilt: p.ring,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _P {
  const _P(
    this.x,
    this.y,
    this.size,
    this.kind,
    this.palette,
    this.seed,
    this.ring,
  );

  final double x;
  final double y;
  final double size;
  final PlanetKind kind;
  final List<Color> palette;
  final int seed;
  final double? ring;
}
