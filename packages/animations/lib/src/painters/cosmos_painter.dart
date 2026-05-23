import 'dart:math' as math;

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

    for (final n in nebulas) {
      _paintNebula(canvas, size, n);
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
