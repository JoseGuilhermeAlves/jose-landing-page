import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

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

/// Padrao da superficie do planeta.
enum PlanetPattern {
  /// Faixas horizontais com vortex spot — gas giant.
  bands,

  /// Manchas / "continentes" pseudo-aleatorios — planeta rochoso.
  speckled,

  /// Hemisferio inferior mais escuro + polar caps brilhantes.
  hemispheres,
}

@immutable
class PlanetRing {
  const PlanetRing({
    required this.innerRadiusPixels,
    required this.outerRadiusPixels,
    required this.color,
    this.tiltY = 0.30,
  });

  final int innerRadiusPixels;
  final int outerRadiusPixels;
  final Color color;
  final double tiltY;
}

@immutable
class PlanetMoon {
  const PlanetMoon({
    required this.orbitRadiusPixels,
    required this.moonRadiusPixels,
    required this.color,
    this.steps = 0,
    this.phaseOffset = 0.0,
  });

  final int orbitRadiusPixels;
  final int moonRadiusPixels;
  final Color color;
  final int steps;
  final double phaseOffset;
}

@immutable
class CosmosPlanet {
  const CosmosPlanet({
    required this.id,
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.palette,
    required this.pattern,
    this.ring,
    this.moon,
    this.seed = 0,
  });

  final String id;
  final Offset canvasAnchor;
  final int radiusPixels;

  /// Palette ideal 4-5 cores: [shadow, mid-dark, mid, mid-light, highlight].
  /// O painter usa palette[0] como base do corpo, palette.last como rim/glow,
  /// e os intermediarios pra surface detail.
  final List<Color> palette;

  final PlanetPattern pattern;
  final PlanetRing? ring;
  final PlanetMoon? moon;
  final int seed;
}

@immutable
class CosmosNebula {
  const CosmosNebula({
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.color,
    this.density = 0.55,
    this.seed = 0,
  });

  final Offset canvasAnchor;
  final int radiusPixels;
  final Color color;
  final double density;
  final int seed;
}

/// Galaxia espiral — pinwheel com nucleo bright, bracos em espiral
/// logaritmica e poeira/estrelas dispersas. Suporta inclinacao `tiltY`
/// (achatamento vertical pra sensacao de plano galactico inclinado) e
/// rotacao lenta amarrada ao `tick` do painter.
///
/// Usada como centerpiece de fundo (renderiza antes das nebulosas).
/// Cores tipicas: nucleo creme/branco quente, bracos em tom frio (cyan,
/// violet, magenta).
@immutable
class CosmosGalaxy {
  const CosmosGalaxy({
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.coreColor,
    required this.armColor,
    this.armCount = 2,
    this.tiltY = 0.45,
    this.rotation = 0.0,
    this.dustCount = 220,
    this.seed = 0,
  });

  final Offset canvasAnchor;
  final int radiusPixels;

  /// Cor do nucleo brilhante (centro denso).
  final Color coreColor;

  /// Cor dominante dos bracos espirais (poeira + estrelas).
  final Color armColor;

  /// 2 ou 4 dao melhor leitura visual.
  final int armCount;

  /// Achatamento vertical (0.05..1.0). Valor < 1 simula plano inclinado.
  final double tiltY;

  /// Offset estatico de rotacao em radianos. O painter adiciona drift
  /// derivado de `tick`.
  final double rotation;

  /// Quantidade de pontos de poeira espalhados ao longo dos bracos.
  /// Renderizados em batch via `drawPoints(PointMode.points)`.
  final int dustCount;

  final int seed;
}

/// Pulsar — estrela de neutrons pequena e brilhante com dois feixes de
/// luz girando radialmente, estilo farol. Pulso de brilho rapido
/// (sine sync com `tick`) reforca o ritmo. Compacto e pontual, ideal
/// como acento ornamental.
@immutable
class CosmosPulsar {
  const CosmosPulsar({
    required this.canvasAnchor,
    required this.coreColor,
    required this.beamColor,
    this.coreRadiusPixels = 3,
    this.beamLengthPixels = 80,
    this.beamWidthRadians = 0.10,
    this.phaseOffset = 0.0,
    this.seed = 0,
  });

  final Offset canvasAnchor;
  final Color coreColor;
  final Color beamColor;

  /// Raio do nucleo brilhante (logico, antes do `pixelSize`).
  final int coreRadiusPixels;

  /// Comprimento dos feixes (logico, antes do `pixelSize`).
  final int beamLengthPixels;

  /// Abertura angular do feixe em radianos. ~0.10 da um leque estreito
  /// estilo farol; valores maiores espalham demais.
  final double beamWidthRadians;

  /// Offset de fase em [0,1] pra dessincronizar pulsares vizinhos.
  final double phaseOffset;

  final int seed;
}

/// Cinturao de asteroides — ribbon de pequenas rochas distribuidas em uma
/// elipse inclinada (plano orbital visto em perspectiva). Roda lentamente
/// em torno do centro (~25% de uma volta por ciclo). Cada rocha tem
/// tamanho e tinta variados (cinza rochoso + highlights quentes ou
/// gelados), seed-determinista. Renderizadas em batch via
/// `drawPoints(PointMode.points)` pra suportar densidade alta sem custo
/// por-rocha.
///
/// Usado como camada mid (entre planetas e pulsares). Distinto do anel de
/// planeta porque nao orbita um corpo especifico — flutua livre.
@immutable
class CosmosAsteroidBelt {
  const CosmosAsteroidBelt({
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.rockColor,
    required this.highlightColor,
    this.tiltY = 0.30,
    this.rotation = 0.0,
    this.thicknessFactor = 0.18,
    this.rockCount = 140,
    this.arcStart = 0.0,
    this.arcSweep = 1.0,
    this.seed = 0,
  });

  final Offset canvasAnchor;

  /// Raio medio do cinturao (eixo maior da elipse).
  final int radiusPixels;

  /// Cor dominante das rochas (cinza rochoso ou tom escuro frio).
  final Color rockColor;

  /// Cor dos brilhos pontuais (gold quente, white gelado).
  final Color highlightColor;

  /// Achatamento vertical (0.05..1.0). Valor < 1 simula plano orbital
  /// inclinado em perspectiva.
  final double tiltY;

  /// Offset estatico de rotacao em radianos. O painter adiciona drift
  /// derivado de `tick`.
  final double rotation;

  /// Espessura radial relativa ao raio (0..1). 0.18 = banda fina como
  /// cinturao classico; valores maiores espalham mais.
  final double thicknessFactor;

  /// Quantidade de rochas. Renderizadas em batch via `drawPoints`.
  final int rockCount;

  /// Fracao [0,1] de onde comeca o arco. 0 = leste do centro.
  final double arcStart;

  /// Fracao [0,1] de quanto do circulo cobrir. 1 = completo;
  /// 0.6 = ribbon parcial pra sensacao de arco.
  final double arcSweep;

  final int seed;
}

/// Wisp — nuvem de gas concentrada com multiplas bolhas de cor soft
/// sobrepostas, drift turbulento via offsets seed-deterministas. Distinta
/// de nebulosa por ser mais densa, concentrada e visivelmente animada
/// (cada blob respira numa fase diferente).
///
/// Usado como camada atmosferica (entre nebulosas e planetas). Boa pra
/// preencher cantos vazios sem competir com focal points.
@immutable
class CosmosWisp {
  const CosmosWisp({
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.colors,
    this.blobCount = 5,
    this.driftPixels = 12,
    this.density = 0.6,
    this.seed = 0,
  });

  final Offset canvasAnchor;

  /// Raio aparente do cluster como um todo (envelope externo).
  final int radiusPixels;

  /// 2-4 cores soft. Cada blob escolhe ciclicamente — overlap de tintas
  /// distintas gera profundidade tipo gas iridescente.
  final List<Color> colors;

  /// Quantidade de blobs sobrepostos. 4-7 da volume sem virar mancha.
  final int blobCount;

  /// Amplitude maxima do drift (logico, antes do `pixelSize`).
  final int driftPixels;

  /// Multiplicador global de alpha (0..1).
  final double density;

  final int seed;
}

@immutable
class CosmosComet {
  const CosmosComet({
    required this.startAnchor,
    required this.endAnchor,
    required this.tailLengthPixels,
    required this.color,
    this.windowStart = 0.0,
    this.windowEnd = 0.18,
  });

  final Offset startAnchor;
  final Offset endAnchor;
  final int tailLengthPixels;
  final Color color;
  final double windowStart;
  final double windowEnd;
}

/// Painter smooth + neon.
class CosmosPainter extends CustomPainter {
  CosmosPainter({
    required this.tick,
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
  });

  final double tick;
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

  /// Paint mutavel reusado. AA on (default), fill.
  final Paint _paint = Paint()..style = PaintingStyle.fill;

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
  // PLANETA — multi-layer smooth render
  // ===========================================================================

  void _paintPlanet(Canvas canvas, Size size, CosmosPlanet planet) {
    if (planet.palette.isEmpty || planet.radiusPixels <= 0) return;

    final center = _planetCenter(planet, size);
    final r = planet.radiusPixels * pixelSize;
    final ramp = _resolveRamp(planet.palette);

    // 1. Outer bloom — neon halo difuso, 2.6x raio.
    _paintBloom(canvas, center, r, ramp);

    // 2. Atmospheric outer rim — 1.05x raio, brighter color.
    _paintAtmosphereRim(canvas, center, r, ramp);

    // 3. Body + surface (clipped to disc).
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: r)),
    );
    _paintBody(canvas, center, r, planet, ramp);
    _paintSurface(canvas, center, r, planet, ramp);
    _paintTerminator(canvas, center, r, ramp);
    _paintHighlight(canvas, center, r, ramp);
    canvas.restore();
  }

  void _paintBloom(Canvas canvas, Offset center, double r, List<Color> ramp) {
    // Glow tighter pra nao lavar a cor solida do corpo.
    final glow = ramp[math.min(2, ramp.length - 1)];
    final bloomR = r * 1.65;

    final shader = RadialGradient(
      colors: [
        glow.withValues(alpha: 0.30),
        glow.withValues(alpha: 0.12),
        glow.withValues(alpha: 0),
      ],
      stops: const [0.45, 0.72, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: bloomR));
    _paint
      ..shader = shader
      ..colorFilter = null;
    canvas.drawCircle(center, bloomR, _paint);
    _paint.shader = null;
  }

  void _paintAtmosphereRim(
    Canvas canvas,
    Offset center,
    double r,
    List<Color> ramp,
  ) {
    final rim = ramp.last;
    final rimR = r * 1.06;

    // Anel atmosferico fino — desenhado como circulo cheio com
    // gradient que so destaca a borda.
    final shader = RadialGradient(
      colors: [
        rim.withValues(alpha: 0),
        rim.withValues(alpha: 0),
        rim.withValues(alpha: 0.55),
        rim.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.92, 0.97, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: rimR));
    _paint.shader = shader;
    canvas.drawCircle(center, rimR, _paint);
    _paint.shader = null;
  }

  void _paintBody(
    Canvas canvas,
    Offset center,
    double r,
    CosmosPlanet planet,
    List<Color> ramp,
  ) {
    // Solid neon block — mid color quase uniforme com fade pra
    // shadow so na borda externa. Cor fica vibrante e legivel.
    final mid = ramp[(ramp.length * 0.6).floor().clamp(0, ramp.length - 1)];
    final shadow = ramp.first;

    final shader = RadialGradient(
      colors: [mid, mid, shadow],
      stops: const [0.0, 0.85, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: r));
    _paint.shader = shader;
    canvas.drawCircle(center, r, _paint);
    _paint.shader = null;
  }

  void _paintSurface(
    Canvas canvas,
    Offset center,
    double r,
    CosmosPlanet planet,
    List<Color> ramp,
  ) {
    switch (planet.pattern) {
      case PlanetPattern.bands:
        _paintBands(canvas, center, r, ramp, planet.seed);
      case PlanetPattern.speckled:
        _paintSpeckle(canvas, center, r, ramp, planet.seed);
      case PlanetPattern.hemispheres:
        _paintHemispheres(canvas, center, r, ramp);
    }
  }

  void _paintBands(
    Canvas canvas,
    Offset center,
    double r,
    List<Color> ramp,
    int seed,
  ) {
    // 5-7 faixas horizontais com alphas variados pra simular atmosfera
    // turbulenta. Cores alternam entre dois stops da rampa.
    final rng = math.Random(seed);
    const bandHeights = [0.18, 0.12, 0.20, 0.14, 0.22, 0.14];
    final bandColors = [
      ramp[1].withValues(alpha: 0.85),
      ramp[3].withValues(alpha: 0.78),
      ramp[0].withValues(alpha: 0.70),
      ramp[2].withValues(alpha: 0.65),
      ramp[4].withValues(alpha: 0.55),
      ramp[1].withValues(alpha: 0.82),
    ];

    var y = center.dy - r;
    for (var i = 0; i < bandHeights.length; i++) {
      final h = bandHeights[i] * 2 * r;
      _paint.color = bandColors[i % bandColors.length];
      canvas.drawRect(
        Rect.fromLTWH(center.dx - r - 4, y, 2 * r + 8, h),
        _paint,
      );
      y += h;
    }

    // Vortex spot (mancha estilo Jupiter) — oval offset do equador
    // com gradient interno pra parecer ciclonico.
    final vx = center.dx + (rng.nextDouble() * 0.5 - 0.25) * r;
    final vy = center.dy + (0.05 + rng.nextDouble() * 0.2) * r;
    final vrx = r * 0.22;
    final vry = vrx * 0.55;
    final vortexShader =
        RadialGradient(
          colors: [
            ramp.first.withValues(alpha: 0.85),
            ramp[1].withValues(alpha: 0.60),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(
          Rect.fromCenter(
            center: Offset(vx, vy),
            width: vrx * 2,
            height: vry * 2,
          ),
        );
    _paint.shader = vortexShader;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(vx, vy), width: vrx * 2, height: vry * 2),
      _paint,
    );
    _paint.shader = null;
  }

  void _paintSpeckle(
    Canvas canvas,
    Offset center,
    double r,
    List<Color> ramp,
    int seed,
  ) {
    // 8-14 "continentes" como soft ovals scatterados. Cor dark do palette
    // com alpha pra deixar misturar com a base radial.
    final rng = math.Random(seed * 101 + 7);
    final count = 8 + rng.nextInt(7);
    final patchColor = ramp[1];

    for (var i = 0; i < count; i++) {
      final ang = rng.nextDouble() * 2 * math.pi;
      final dist = rng.nextDouble() * r * 0.78;
      final ex = center.dx + math.cos(ang) * dist;
      final ey = center.dy + math.sin(ang) * dist;
      final ew = r * (0.16 + rng.nextDouble() * 0.20);
      final eh = ew * (0.50 + rng.nextDouble() * 0.45);
      final rot = rng.nextDouble() * math.pi;

      canvas.save();
      canvas.translate(ex, ey);
      canvas.rotate(rot);
      // Continente solido — alpha alta no nucleo, fade so na borda.
      final shader =
          RadialGradient(
            colors: [
              patchColor.withValues(alpha: 0.92),
              patchColor.withValues(alpha: 0.65),
              patchColor.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.70, 1.0],
          ).createShader(
            Rect.fromCenter(center: Offset.zero, width: ew * 2, height: eh * 2),
          );
      _paint.shader = shader;
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: ew * 2, height: eh * 2),
        _paint,
      );
      _paint.shader = null;
      canvas.restore();
    }
  }

  void _paintHemispheres(
    Canvas canvas,
    Offset center,
    double r,
    List<Color> ramp,
  ) {
    // Hemisferio inferior em palette[1] (mid-dark) solido.
    final lower = ramp[1];
    final shader = LinearGradient(
      begin: const Alignment(0, -0.05),
      end: const Alignment(0, 0.5),
      colors: [Colors.transparent, lower.withValues(alpha: 0.92)],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: r));
    _paint.shader = shader;
    canvas.drawCircle(center, r, _paint);
    _paint.shader = null;

    // Polar caps brilhantes — palette[4].
    final highlight = ramp.last;
    final capShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        highlight.withValues(alpha: 0.92),
        highlight.withValues(alpha: 0),
        highlight.withValues(alpha: 0),
        highlight.withValues(alpha: 0.75),
      ],
      stops: const [0.0, 0.20, 0.80, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: r));
    _paint.shader = capShader;
    canvas.drawCircle(center, r, _paint);
    _paint.shader = null;
  }

  void _paintTerminator(
    Canvas canvas,
    Offset center,
    double r,
    List<Color> ramp,
  ) {
    // Sombra concentrada no bottom-right edge — preserva cor solida no
    // centro mas mantem dica 3D.
    final shadow = ramp.first;
    final shader = RadialGradient(
      center: const Alignment(0.55, 0.55),
      radius: 1.05,
      colors: [
        shadow.withValues(alpha: 0),
        shadow.withValues(alpha: 0),
        shadow.withValues(alpha: 0.55),
      ],
      stops: const [0.55, 0.75, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: r));
    _paint.shader = shader;
    canvas.drawCircle(center, r, _paint);
    _paint.shader = null;
  }

  void _paintHighlight(
    Canvas canvas,
    Offset center,
    double r,
    List<Color> ramp,
  ) {
    // Highlight concentrado top-left — pequeno e intenso pra nao
    // lavar o block de cor.
    final highlight = ramp.last;
    final shader = RadialGradient(
      center: const Alignment(-0.50, -0.55),
      radius: 0.40,
      colors: [
        highlight.withValues(alpha: 0.65),
        highlight.withValues(alpha: 0.20),
        highlight.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: r));
    _paint.shader = shader;
    canvas.drawCircle(center, r, _paint);
    _paint.shader = null;
  }

  // ===========================================================================
  // ANEL — half-ellipses com gradient + glow
  // ===========================================================================

  void _paintRingHalf(
    Canvas canvas,
    Size size,
    CosmosPlanet planet, {
    required bool front,
  }) {
    final ring = planet.ring!;
    if (ring.outerRadiusPixels <= ring.innerRadiusPixels) return;

    final center = _planetCenter(planet, size);
    final outerR = ring.outerRadiusPixels * pixelSize;
    final innerR = ring.innerRadiusPixels * pixelSize;
    final tiltY = ring.tiltY.clamp(0.05, 1.0);
    final outerH = outerR * tiltY;
    final innerH = innerR * tiltY;

    canvas.save();
    if (front) {
      canvas.clipRect(
        Rect.fromLTWH(0, center.dy, size.width, size.height - center.dy),
      );
    } else {
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, center.dy));
    }

    // Donut ellipse path: outer minus inner.
    final donut = Path()
      ..addOval(
        Rect.fromCenter(center: center, width: outerR * 2, height: outerH * 2),
      )
      ..addOval(
        Rect.fromCenter(center: center, width: innerR * 2, height: innerH * 2),
      )
      ..fillType = PathFillType.evenOdd;

    // Gradient horizontal — bordas (limbos) mais brilhantes simulando
    // espessura do anel.
    final shader =
        LinearGradient(
          colors: [
            ring.color.withValues(alpha: (ring.color.a * 0.95).clamp(0.0, 1.0)),
            ring.color.withValues(alpha: (ring.color.a * 0.55).clamp(0.0, 1.0)),
            ring.color.withValues(alpha: (ring.color.a * 0.95).clamp(0.0, 1.0)),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
          Rect.fromCenter(
            center: center,
            width: outerR * 2,
            height: outerH * 2,
          ),
        );
    _paint.shader = shader;
    canvas.drawPath(donut, _paint);
    _paint.shader = null;

    canvas.restore();
  }

  // ===========================================================================
  // LUA — disco com glow + terminator
  // ===========================================================================

  void _paintMoon(Canvas canvas, Size size, CosmosPlanet planet) {
    final moon = planet.moon!;
    final raw = (tick + moon.phaseOffset) % 1.0;
    final t = moon.steps > 0 ? (raw * moon.steps).floor() / moon.steps : raw;
    final angle = t * 2 * math.pi;

    final center = _planetCenter(planet, size);
    final orbitR = moon.orbitRadiusPixels * pixelSize;
    final mx = center.dx + math.cos(angle) * orbitR;
    final my = center.dy + math.sin(angle) * orbitR * 0.45;
    final mr = moon.moonRadiusPixels * pixelSize;
    if (mr <= 0) return;
    final moonCenter = Offset(mx, my);

    // Glow.
    final glowR = mr * 2.4;
    final glowShader = RadialGradient(
      colors: [
        moon.color.withValues(alpha: 0.50),
        moon.color.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: moonCenter, radius: glowR));
    _paint.shader = glowShader;
    canvas.drawCircle(moonCenter, glowR, _paint);
    _paint.shader = null;

    // Body.
    _paint.color = moon.color;
    canvas.drawCircle(moonCenter, mr, _paint);

    // Terminator sutil.
    final terminator = RadialGradient(
      center: const Alignment(0.5, 0.5),
      radius: 1.0,
      colors: [
        Colors.transparent,
        const Color.from(alpha: 0.5, red: 0, green: 0, blue: 0),
      ],
      stops: const [0.35, 1.0],
    ).createShader(Rect.fromCircle(center: moonCenter, radius: mr));
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: moonCenter, radius: mr)),
    );
    _paint.shader = terminator;
    canvas.drawCircle(moonCenter, mr, _paint);
    _paint.shader = null;
    canvas.restore();
  }

  // ===========================================================================
  // NEBULOSA — radial gradient multi-stop, smooth
  // ===========================================================================

  void _paintNebula(Canvas canvas, Size size, CosmosNebula n) {
    if (n.radiusPixels <= 0) return;
    final cx = n.canvasAnchor.dx * size.width;
    final cy = n.canvasAnchor.dy * size.height;
    final r = n.radiusPixels * pixelSize;

    // Breath sutil — alpha pulsando entre 0.85-1.0 com fase por seed.
    final breath =
        0.92 + 0.08 * math.sin(tick * 2 * math.pi + n.seed.toDouble() * 0.7);
    final coreAlpha = (n.color.a * n.density * breath).clamp(0.0, 1.0);

    // Core mais opaco + falloff mais sharp — nebulosa parece "block"
    // de cor neon ao inves de gradient washy.
    final shader = RadialGradient(
      colors: [
        n.color.withValues(alpha: coreAlpha),
        n.color.withValues(alpha: coreAlpha * 0.78),
        n.color.withValues(alpha: coreAlpha * 0.28),
        n.color.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.30, 0.65, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    _paint.shader = shader;
    canvas.drawCircle(Offset(cx, cy), r, _paint);
    _paint.shader = null;
  }

  // ===========================================================================
  // ESTRELAS — dots smooth com halo nas featured
  // ===========================================================================

  void _paintStars(Canvas canvas, Size size) {
    const coolTint = Color(0xFFBFD4FF);
    const warmTint = Color(0xFFFFD8A0);
    const neonPink = Color(0xFFFF99D6);
    const neonCyan = Color(0xFF99FFEC);

    for (var i = 0; i < pixelStars.length; i++) {
      final s = pixelStars[i];
      final cx = s.dx * size.width;
      final cy = s.dy * size.height;

      final isFeatured = i % 6 == 0;
      final isDistant = !isFeatured && i % 3 == 1;

      // Pulse sutil so nas featured — sine wave 0.92-1.0.
      final featuredPulse = isFeatured
          ? 0.92 + 0.08 * math.sin(tick * 2 * math.pi + i * 0.4)
          : 1.0;

      Color color;
      double radius;
      double tierAlpha;
      if (isFeatured) {
        // Featured podem ter tint neon ocasional.
        if (i % 24 == 0) {
          color = neonPink;
        } else if (i % 18 == 0) {
          color = neonCyan;
        } else if (i % 12 == 0) {
          color = warmTint;
        } else {
          color = coolTint;
        }
        radius = pixelSize * 1.35;
        tierAlpha = 0.95;
      } else if (isDistant) {
        color = starColor;
        radius = pixelSize * 0.35;
        tierAlpha = 0.55;
      } else {
        color = starColor;
        radius = pixelSize * 0.65;
        tierAlpha = 0.85;
      }

      final alpha = (color.a * featuredPulse * tierAlpha).clamp(0.0, 1.0);

      if (isFeatured) {
        // Halo difuso 3.5x raio.
        final haloR = radius * 3.8;
        final haloShader = RadialGradient(
          colors: [
            color.withValues(alpha: (alpha * 0.42).clamp(0.0, 1.0)),
            color.withValues(alpha: (alpha * 0.18).clamp(0.0, 1.0)),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: haloR));
        _paint.shader = haloShader;
        canvas.drawCircle(Offset(cx, cy), haloR, _paint);
        _paint.shader = null;

        // Core brilhante.
        _paint.color = color.withValues(alpha: alpha);
        canvas.drawCircle(Offset(cx, cy), radius, _paint);

        // Inner highlight (mini white core).
        _paint.color = Colors.white.withValues(
          alpha: (alpha * 0.6).clamp(0.0, 1.0),
        );
        canvas.drawCircle(Offset(cx, cy), radius * 0.4, _paint);
      } else {
        _paint.color = color.withValues(alpha: alpha);
        canvas.drawCircle(Offset(cx, cy), radius, _paint);
      }
    }
  }

  // ===========================================================================
  // COMETA / SHOOTING STAR — gradient tail + bright head com glow
  // ===========================================================================

  void _paintComet(Canvas canvas, Size size, CosmosComet c) {
    if (tick < c.windowStart || tick > c.windowEnd) return;
    final windowSpan = c.windowEnd - c.windowStart;
    if (windowSpan <= 0) return;

    final progress = (tick - c.windowStart) / windowSpan;
    final headX =
        (c.startAnchor.dx + (c.endAnchor.dx - c.startAnchor.dx) * progress) *
        size.width;
    final headY =
        (c.startAnchor.dy + (c.endAnchor.dy - c.startAnchor.dy) * progress) *
        size.height;

    final dirX = (c.startAnchor.dx - c.endAnchor.dx) * size.width;
    final dirY = (c.startAnchor.dy - c.endAnchor.dy) * size.height;
    final len = math.sqrt(dirX * dirX + dirY * dirY);
    if (len == 0) return;
    final ux = dirX / len;
    final uy = dirY / len;

    final tailLen = c.tailLengthPixels * pixelSize * 2.5;
    final tailEnd = Offset(headX + ux * tailLen, headY + uy * tailLen);
    final head = Offset(headX, headY);

    // Tail: linha grossa com gradient linear.
    final tailShader = LinearGradient(
      colors: [
        c.color.withValues(alpha: 0),
        c.color.withValues(alpha: (c.color.a * 0.85).clamp(0.0, 1.0)),
      ],
    ).createShader(Rect.fromPoints(tailEnd, head));
    _paint
      ..shader = tailShader
      ..strokeCap = StrokeCap.round
      ..strokeWidth = pixelSize * 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(tailEnd, head, _paint);
    _paint
      ..style = PaintingStyle.fill
      ..shader = null;

    // Head glow.
    final headR = pixelSize * 2.0;
    final glowR = headR * 3.2;
    final glowShader = RadialGradient(
      colors: [
        c.color.withValues(alpha: 0.90),
        c.color.withValues(alpha: 0.35),
        c.color.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromCircle(center: head, radius: glowR));
    _paint.shader = glowShader;
    canvas.drawCircle(head, glowR, _paint);
    _paint.shader = null;

    // Head core.
    _paint.color = Colors.white.withValues(alpha: c.color.a);
    canvas.drawCircle(head, headR, _paint);
  }

  // ===========================================================================
  // GALAXIA ESPIRAL — nucleo bright + bracos em espiral logaritmica
  // ===========================================================================

  void _paintGalaxy(Canvas canvas, Size size, CosmosGalaxy g) {
    if (g.radiusPixels <= 0) return;
    final cx = g.canvasAnchor.dx * size.width;
    final cy = g.canvasAnchor.dy * size.height;
    final r = g.radiusPixels * pixelSize;
    final tiltY = g.tiltY.clamp(0.05, 1.0);
    // Rotacao lenta (~25% de uma volta por ciclo) somada ao offset estatico.
    final rot = g.rotation + tick * 2 * math.pi * 0.25;
    final armCount = math.max(1, g.armCount);

    // Escalas Y pra simular plano galactico inclinado. Toda matematica
    // subsequente (centro, halo, bracos) ja sai esmagada verticalmente.
    canvas
      ..save()
      ..translate(cx, cy)
      ..scale(1, tiltY)
      ..rotate(rot);

    // Halo externo difuso — bloom geral que une nucleo + bracos sem
    // virar nuvem chapada.
    final haloShader = RadialGradient(
      colors: [
        g.armColor.withValues(alpha: (g.armColor.a * 0.22).clamp(0.0, 1.0)),
        g.armColor.withValues(alpha: (g.armColor.a * 0.10).clamp(0.0, 1.0)),
        g.armColor.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    _paint.shader = haloShader;
    canvas.drawCircle(Offset.zero, r, _paint);
    _paint.shader = null;

    // Nucleo denso — gradient creme/quente concentrado no centro.
    final coreR = r * 0.32;
    final coreShader = RadialGradient(
      colors: [
        g.coreColor.withValues(alpha: 0.98),
        g.coreColor.withValues(alpha: 0.65),
        g.coreColor.withValues(alpha: 0.18),
        g.coreColor.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.35, 0.70, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: coreR));
    _paint.shader = coreShader;
    canvas.drawCircle(Offset.zero, coreR, _paint);
    _paint.shader = null;

    // Bracos: poeira em pontos batched via drawPoints — Skia desenha
    // todos como squares de strokeWidth em uma chamada so. Espiral
    // logaritmica r(theta) = a * exp(b * theta).
    final rng = math.Random(g.seed * 131 + 17);
    final perArm = math.max(1, g.dustCount ~/ armCount);
    const turns = 1.6; // quantas voltas a espiral da do centro a borda.
    const b = 0.32; // tightness do braco; menor = mais enrolado.

    // Pontos coletados em lista local — alocacao reusada nao serve aqui
    // porque drawPoints aceita lista; mas é UMA alocacao por frame, nao
    // mil drawCircle. Vale o tradeoff.
    for (var arm = 0; arm < armCount; arm++) {
      final armPhase = (arm / armCount) * 2 * math.pi;
      final points = <Offset>[];
      for (var i = 0; i < perArm; i++) {
        // Distribuicao com bias pra fora — concentra menos pontos no
        // nucleo (que ja tem o gradient denso) e mais nos bracos.
        final t = math.pow(rng.nextDouble(), 0.6).toDouble();
        final theta = armPhase + t * turns * 2 * math.pi;
        final radius = r * 0.18 + (r * 0.78) * t * math.exp(b * 0);
        // Jitter perpendicular ao braco — espessura natural.
        final jitter = (rng.nextDouble() - 0.5) * r * 0.10 * (1 - t * 0.4);
        final dirX = math.cos(theta);
        final dirY = math.sin(theta);
        final px = dirX * radius + (-dirY) * jitter;
        final py = dirY * radius + dirX * jitter;
        points.add(Offset(px, py));
      }
      // Alpha decai um pouco em bracos secundarios pra dar leitura
      // hierarquica quando armCount > 2.
      final armAlpha = (g.armColor.a * (arm == 0 ? 0.85 : 0.70))
          .clamp(0.0, 1.0);
      _paint
        ..color = g.armColor.withValues(alpha: armAlpha)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = pixelSize * 0.9;
      canvas.drawPoints(PointMode.points, points, _paint);

      // Algumas estrelas brilhantes pontuais por braco (1 em ~15 pontos)
      // — desenhadas como dots maiores no nucleo de cor clara.
      for (var i = 0; i < points.length; i += 15) {
        _paint
          ..color = g.coreColor.withValues(alpha: 0.85)
          ..strokeWidth = pixelSize * 1.6;
        canvas.drawPoints(PointMode.points, [points[i]], _paint);
      }
    }

    // Reset paint state mutavel.
    _paint
      ..strokeWidth = 0
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFF000000);

    canvas.restore();
  }

  // ===========================================================================
  // PULSAR — nucleo bright + dois feixes rotativos estilo farol
  // ===========================================================================

  void _paintPulsar(Canvas canvas, Size size, CosmosPulsar p) {
    final cx = p.canvasAnchor.dx * size.width;
    final cy = p.canvasAnchor.dy * size.height;
    final coreR = p.coreRadiusPixels * pixelSize;
    final beamLen = p.beamLengthPixels * pixelSize;
    if (coreR <= 0 || beamLen <= 0) return;
    final center = Offset(cx, cy);

    // Pulso rapido (~6 batidas por ciclo). Brilho oscila 0.55..1.0.
    final pulse =
        0.55 +
        0.45 * (0.5 + 0.5 * math.sin((tick + p.phaseOffset) * 2 * math.pi * 6));
    // Rotacao dos feixes (~4 voltas por ciclo).
    final beamAngle =
        (tick + p.phaseOffset) * 2 * math.pi * 4 + p.seed * 0.37;

    // Halo externo discreto.
    final haloR = coreR * 4.5;
    final haloShader = RadialGradient(
      colors: [
        p.coreColor.withValues(alpha: (0.55 * pulse).clamp(0.0, 1.0)),
        p.coreColor.withValues(alpha: (0.18 * pulse).clamp(0.0, 1.0)),
        p.coreColor.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.40, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: haloR));
    _paint.shader = haloShader;
    canvas.drawCircle(center, haloR, _paint);
    _paint.shader = null;

    // Dois feixes opostos — triangulos finos com gradient linear
    // (cheio no nucleo, transparente na ponta).
    final width = p.beamWidthRadians.clamp(0.02, 1.0);
    for (var i = 0; i < 2; i++) {
      final ang = beamAngle + i * math.pi;
      final tip = Offset(
        center.dx + math.cos(ang) * beamLen,
        center.dy + math.sin(ang) * beamLen,
      );
      final leftAng = ang + width / 2;
      final rightAng = ang - width / 2;
      // Base do feixe e o proprio nucleo — sai do raio do core.
      final baseL = Offset(
        center.dx + math.cos(leftAng) * coreR,
        center.dy + math.sin(leftAng) * coreR,
      );
      final baseR = Offset(
        center.dx + math.cos(rightAng) * coreR,
        center.dy + math.sin(rightAng) * coreR,
      );
      final beam = Path()
        ..moveTo(baseL.dx, baseL.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(baseR.dx, baseR.dy)
        ..close();
      final beamShader = LinearGradient(
        colors: [
          p.beamColor.withValues(
            alpha: (p.beamColor.a * 0.95 * pulse).clamp(0.0, 1.0),
          ),
          p.beamColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromPoints(center, tip));
      _paint.shader = beamShader;
      canvas.drawPath(beam, _paint);
      _paint.shader = null;
    }

    // Nucleo: glow + dot branco no centro.
    final coreShader = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: pulse.clamp(0.0, 1.0)),
        p.coreColor.withValues(alpha: (0.85 * pulse).clamp(0.0, 1.0)),
        p.coreColor.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: coreR * 1.8));
    _paint.shader = coreShader;
    canvas.drawCircle(center, coreR * 1.8, _paint);
    _paint.shader = null;

    _paint.color = Colors.white.withValues(alpha: pulse.clamp(0.0, 1.0));
    canvas.drawCircle(center, coreR * 0.55, _paint);
  }

  // ===========================================================================
  // CINTURAO DE ASTEROIDES — elipse tilted com rochas batched
  // ===========================================================================

  void _paintAsteroidBelt(Canvas canvas, Size size, CosmosAsteroidBelt b) {
    if (b.radiusPixels <= 0 || b.rockCount <= 0) return;
    final cx = b.canvasAnchor.dx * size.width;
    final cy = b.canvasAnchor.dy * size.height;
    final r = b.radiusPixels * pixelSize;
    final tiltY = b.tiltY.clamp(0.05, 1.0);
    // Rotacao lenta ~25% por ciclo.
    final rot = b.rotation + tick * 2 * math.pi * 0.25;
    final thickness = (b.thicknessFactor.clamp(0.02, 0.8)) * r;
    final sweep = b.arcSweep.clamp(0.05, 1.0);
    final startAng = b.arcStart * 2 * math.pi;

    canvas
      ..save()
      ..translate(cx, cy)
      ..scale(1, tiltY)
      ..rotate(rot);

    // Halo difuso fininho ao longo do arco — sensacao de poeira de fundo
    // antes das rochas individuais. Desenhado como anel via path donut.
    if (sweep > 0.9) {
      final haloOuter = r + thickness * 0.6;
      final haloInner = r - thickness * 0.6;
      if (haloInner > 0) {
        final donut = Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: haloOuter * 2,
              height: haloOuter * 2,
            ),
          )
          ..addOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: haloInner * 2,
              height: haloInner * 2,
            ),
          )
          ..fillType = PathFillType.evenOdd;
        _paint.color = b.rockColor.withValues(
          alpha: (b.rockColor.a * 0.10).clamp(0.0, 1.0),
        );
        canvas.drawPath(donut, _paint);
      }
    }

    // Distribui rochas ao longo do arco com jitter radial. Coleta em
    // listas locais por tier (small / medium / highlight) pra batchar em
    // drawPoints — Skia faz uma chamada GPU por tier ao inves de N
    // drawCircle, salvando dezenas de draw calls.
    final rng = math.Random(b.seed * 211 + 3);
    final smallPoints = <Offset>[];
    final mediumPoints = <Offset>[];
    final highlightPoints = <Offset>[];

    for (var i = 0; i < b.rockCount; i++) {
      // Theta uniforme dentro do arco.
      final theta = startAng + rng.nextDouble() * sweep * 2 * math.pi;
      // Distribuicao radial com bias gaussiano fraco no centro do anel —
      // mais rochas perto do raio medio, menos nas bordas.
      final jitterRaw = rng.nextDouble() + rng.nextDouble() - 1.0;
      final radial = r + jitterRaw * thickness;
      final px = math.cos(theta) * radial;
      final py = math.sin(theta) * radial;
      final pt = Offset(px, py);

      // Tier sortido: ~12% highlight (bright gold/ice), ~28% medium,
      // resto small. Distribuicao tipica de cinturao real.
      final tier = rng.nextDouble();
      if (tier < 0.12) {
        highlightPoints.add(pt);
      } else if (tier < 0.40) {
        mediumPoints.add(pt);
      } else {
        smallPoints.add(pt);
      }
    }

    // Small rocks — pontos finos de baixa intensidade.
    if (smallPoints.isNotEmpty) {
      _paint
        ..color = b.rockColor.withValues(
          alpha: (b.rockColor.a * 0.70).clamp(0.0, 1.0),
        )
        ..strokeCap = StrokeCap.round
        ..strokeWidth = pixelSize * 0.7;
      canvas.drawPoints(PointMode.points, smallPoints, _paint);
    }

    // Medium rocks — um pouco maiores e mais opacos.
    if (mediumPoints.isNotEmpty) {
      _paint
        ..color = b.rockColor.withValues(
          alpha: (b.rockColor.a * 0.95).clamp(0.0, 1.0),
        )
        ..strokeCap = StrokeCap.round
        ..strokeWidth = pixelSize * 1.2;
      canvas.drawPoints(PointMode.points, mediumPoints, _paint);
    }

    // Highlights — rochas reluzentes, cor quente/gelada.
    if (highlightPoints.isNotEmpty) {
      _paint
        ..color = b.highlightColor.withValues(
          alpha: (b.highlightColor.a * 0.95).clamp(0.0, 1.0),
        )
        ..strokeCap = StrokeCap.round
        ..strokeWidth = pixelSize * 1.6;
      canvas.drawPoints(PointMode.points, highlightPoints, _paint);
    }

    // Reset state mutavel.
    _paint
      ..strokeWidth = 0
      ..strokeCap = StrokeCap.butt
      ..color = const Color(0xFF000000);

    canvas.restore();
  }

  // ===========================================================================
  // WISP — cluster de blobs soft com drift turbulento
  // ===========================================================================

  void _paintWisp(Canvas canvas, Size size, CosmosWisp w) {
    if (w.radiusPixels <= 0 || w.blobCount <= 0 || w.colors.isEmpty) return;
    final cx = w.canvasAnchor.dx * size.width;
    final cy = w.canvasAnchor.dy * size.height;
    final r = w.radiusPixels * pixelSize;
    final drift = w.driftPixels * pixelSize;
    final density = w.density.clamp(0.0, 1.0);

    final rng = math.Random(w.seed * 173 + 11);
    const twoPi = 2 * math.pi;

    for (var i = 0; i < w.blobCount; i++) {
      // Cada blob tem ancora base (radial random dentro do envelope),
      // tamanho proprio e fase de drift dessincronizada.
      final baseAng = rng.nextDouble() * twoPi;
      final baseDist = rng.nextDouble() * r * 0.55;
      final blobR = r * (0.45 + rng.nextDouble() * 0.45);
      final phaseX = rng.nextDouble() * twoPi;
      final phaseY = rng.nextDouble() * twoPi;
      final breathPhase = rng.nextDouble() * twoPi;
      final color = w.colors[i % w.colors.length];

      // Drift turbulento via duas senoides em fases distintas — barato e
      // suficientemente organico pra leitura de gas em movimento.
      final dx = math.sin(tick * twoPi + phaseX) * drift;
      final dy = math.cos(tick * twoPi * 0.83 + phaseY) * drift * 0.75;

      // Breath de alpha: respira 0.75..1.0.
      final breath = 0.75 + 0.25 * math.sin(tick * twoPi + breathPhase);

      final center = Offset(
        math.cos(baseAng) * baseDist + dx,
        math.sin(baseAng) * baseDist + dy,
      );

      // Cada blob e um radial gradient denso no nucleo + falloff suave.
      final coreAlpha = (color.a * density * 0.75 * breath).clamp(0.0, 1.0);
      final shader =
          RadialGradient(
            colors: [
              color.withValues(alpha: coreAlpha),
              color.withValues(alpha: coreAlpha * 0.55),
              color.withValues(alpha: coreAlpha * 0.15),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.40, 0.75, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(cx + center.dx, cy + center.dy),
              radius: blobR,
            ),
          );
      _paint.shader = shader;
      canvas.drawCircle(
        Offset(cx + center.dx, cy + center.dy),
        blobR,
        _paint,
      );
      _paint.shader = null;
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
    return old.tick != tick ||
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

  bool get isComplex => true;
  bool get willChange => true;
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
