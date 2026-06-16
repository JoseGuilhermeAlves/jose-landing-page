part of 'cosmos_painter.dart';

/// Camadas de planeta/anel/lua do [CosmosPainter] — render smooth multi-layer
/// (bloom -> atmosfera -> corpo + surface -> rim -> highlight -> terminator),
/// anel em half-ellipse e lua com glow. Extraido do arquivo principal pra
/// manter cada responsabilidade num arquivo proprio (god-file split).
extension PlanetRendering on CosmosPainter {
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

    // 3. Body + surface (clipped to disc). Path reusado (sem alocar por frame).
    canvas.save();
    _clipPath
      ..reset()
      ..addOval(Rect.fromCircle(center: center, radius: r));
    canvas.clipPath(_clipPath);
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

    // Donut ellipse path: outer minus inner. Path reusado (sem alocar/frame).
    _ringPath
      ..reset()
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
    canvas.drawPath(_ringPath, _paint);
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
    _moonClipPath
      ..reset()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: mr));
    canvas.clipPath(_moonClipPath);
    _paint.shader = terminator;
    canvas.drawCircle(moonCenter, mr, _paint);
    _paint.shader = null;
    canvas.restore();
  }
}
