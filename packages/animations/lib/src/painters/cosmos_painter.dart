import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:animations/src/painters/cosmos_models.dart';
import 'package:flutter/material.dart';

export 'cosmos_models.dart';

// Renderers extraidos pra arquivos proprios (god-file split). Cada um e uma
// extension privada sobre [CosmosPainter] e compartilha `_paint`/`tick`/Paths.
part 'cosmos_painter_planets.dart';
part 'cosmos_painter_field.dart';

/// Cosmos hero — estetica Kurzgesagt + neon. Planetas smooth com
/// multiplas camadas (bloom -> atmosfera -> corpo + surface -> rim ->
/// highlight -> terminator), nebulosas vibrantes em radial gradient,
/// estrelas circulares anti-aliased em 3 tiers e estrelas cadentes com
/// tail gradient.
///
/// Light direction: top-left consistente em todos os corpos. Cores
/// neon-saturadas (hot pink, cyan, magenta, lime) dao o "punch" pra
/// uma landing page que precisa capturar atencao em 5s.
///
/// Performance:
/// - Sem pixel iteration. Tudo via `drawCircle`/`drawOval` + radial
///   gradients (Skia GPU otimizado);
/// - ~100-150 draw calls/frame total (8 planetas x 4-6 layers + 5
///   nebulosas + 50 estrelas + cometa);
/// - `_paint` mutable reusado. Shaders criados inline (allocacao pequena,
///   tradeoff vs. cache complexity — Skia compila shaders rapido).

/// Painter smooth + neon.
class CosmosPainter extends CustomPainter {
  CosmosPainter({
    double? tick,
    this.animation,
    required this.starColor,
    this.pixelSize = 2,
    this.planets = const [],
    this.nebulas = const [],
    this.galaxies = const [],
    this.pulsars = const [],
    this.asteroidBelts = const [],
    this.wisps = const [],
    this.comet,
    this.shootingStars = const [],
    this.pixelStars = const [],
  })  : _tick = tick ?? 0,
        super(repaint: animation);

  /// Animacao que alimenta o tick. Quando presente, `tick` le o valor
  /// corrente da animacao em cada frame (via `super(repaint:)`), pulando
  /// build/layout no pipeline do Flutter.
  final Animation<double>? animation;

  final double _tick;

  /// Progresso do ciclo (0..1). Prefere o valor vivo da [animation];
  /// fallback pro valor estatico passado no construtor.
  double get tick => animation?.value ?? _tick;
  final Color starColor;

  /// Fator de escala "unidade -> logical px". radiusPixels * pixelSize
  /// e o raio visual final em logical px.
  final double pixelSize;

  final List<CosmosPlanet> planets;
  final List<CosmosNebula> nebulas;
  final List<CosmosGalaxy> galaxies;
  final List<CosmosPulsar> pulsars;
  final List<CosmosAsteroidBelt> asteroidBelts;
  final List<CosmosWisp> wisps;
  final CosmosComet? comet;
  final List<CosmosComet> shootingStars;
  final List<Offset> pixelStars;

  final Paint _paint = Paint()..style = PaintingStyle.fill;
  final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // Paths reusados pelos renderers (parts) — clip do disco do planeta, donut
  // do anel e clip da lua. Mutados via `..reset()` por frame, sem alocar.
  final Path _clipPath = Path();
  final Path _ringPath = Path();
  final Path _moonClipPath = Path();

  /// Stub pra compat com versao pixel-art anterior — sem cache em smooth.
  static void clearCache() {}

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Camada mais profunda: galaxias antes de tudo, depois nebulosas.
    for (final g in galaxies) {
      _paintGalaxy(canvas, size, g);
    }
    for (final n in nebulas) {
      _paintNebula(canvas, size, n);
    }
    // Wisps logo apos nebulosas — camada atmosferica densa entre o fundo
    // nebuloso e os corpos solidos.
    for (final w in wisps) {
      _paintWisp(canvas, size, w);
    }
    _paintStars(canvas, size);
    for (final p in planets) {
      if (p.ring != null) _paintRingHalf(canvas, size, p, front: false);
    }
    for (final p in planets) {
      _paintPlanet(canvas, size, p);
    }
    for (final p in planets) {
      if (p.ring != null) _paintRingHalf(canvas, size, p, front: true);
    }
    for (final p in planets) {
      if (p.moon != null) _paintMoon(canvas, size, p);
    }
    // Cinturoes de asteroides na camada mid — depois das luas, antes dos
    // pulsares. Sao texturais; pulsares precisam ficar por cima.
    for (final b in asteroidBelts) {
      _paintAsteroidBelt(canvas, size, b);
    }
    // Pulsares na camada mid (com planetas) — bright spots pontuais.
    for (final ps in pulsars) {
      _paintPulsar(canvas, size, ps);
    }
    if (comet != null) _paintComet(canvas, size, comet!);
    for (final s in shootingStars) {
      _paintComet(canvas, size, s);
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  /// Centro efetivo do planeta com drift sutil aplicado (parallax).
  Offset _planetCenter(CosmosPlanet planet, Size size) {
    final drift = _planetDrift(planet);
    return Offset(
      planet.canvasAnchor.dx * size.width + drift.dx,
      planet.canvasAnchor.dy * size.height + drift.dy,
    );
  }

  Offset _planetDrift(CosmosPlanet planet) {
    final rangeX = math.sqrt(planet.radiusPixels.toDouble()) * 1.6;
    final rangeY = math.sqrt(planet.radiusPixels.toDouble()) * 0.6;
    final phase = planet.seed * 0.31;
    return Offset(
      math.sin(tick * 2 * math.pi + phase) * rangeX,
      math.cos(tick * 2 * math.pi * 0.7 + phase + 1.5) * rangeY,
    );
  }

  /// Interpola palette (1-N cores) pra rampa 5-stop (shadow → highlight).
  List<Color> _resolveRamp(List<Color> palette) {
    if (palette.isEmpty) {
      return List<Color>.filled(5, const Color(0xFF000000));
    }
    if (palette.length == 1) {
      return List<Color>.filled(5, palette.first);
    }
    if (palette.length >= 5) return palette;
    final result = <Color>[];
    for (var i = 0; i < 5; i++) {
      final t = i / 4;
      final pos = t * (palette.length - 1);
      final lo = pos.floor().clamp(0, palette.length - 1);
      final hi = (lo + 1).clamp(0, palette.length - 1);
      final f = pos - lo;
      result.add(_mix(palette[lo], palette[hi], f));
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CosmosPainter old) {
    return old._tick != _tick ||
        old.animation != animation ||
        old.starColor != starColor ||
        old.pixelSize != pixelSize ||
        !identical(old.planets, planets) ||
        !identical(old.nebulas, nebulas) ||
        !identical(old.galaxies, galaxies) ||
        !identical(old.pulsars, pulsars) ||
        !identical(old.asteroidBelts, asteroidBelts) ||
        !identical(old.wisps, wisps) ||
        old.comet != comet ||
        !identical(old.shootingStars, shootingStars) ||
        !identical(old.pixelStars, pixelStars);
  }
}

// =============================================================================
// COLOR HELPERS
// =============================================================================

Color _mix(Color a, Color b, double t) {
  final s = 1 - t;
  return Color.from(
    alpha: a.a * s + b.a * t,
    red: a.r * s + b.r * t,
    green: a.g * s + b.g * t,
    blue: a.b * s + b.b * t,
  );
}
