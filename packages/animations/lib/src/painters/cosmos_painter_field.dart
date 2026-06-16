part of 'cosmos_painter.dart';

/// Campo cosmico de fundo do [CosmosPainter] — nebulosas, estrelas, cometas,
/// galaxia espiral, pulsares, cinturoes de asteroides e wisps. Extraido do
/// arquivo principal pra separar o "fundo difuso" dos corpos solidos
/// (god-file split). Todos leem o mesmo `tick`/`_paint` do painter.
extension CosmicFieldRendering on CosmosPainter {
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
    _strokePaint
      ..shader = tailShader
      ..strokeWidth = pixelSize * 2.0;
    canvas.drawLine(tailEnd, head, _strokePaint);
    _strokePaint.shader = null;

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

    // Pre-compute blob geometry and phases once per wisp (deterministic
    // from seed). Avoids re-seeding Random inside the per-frame loop.
    // Gradient stops are const; only colors vary by breath alpha.
    const stops = [0.0, 0.40, 0.75, 1.0];

    for (var i = 0; i < w.blobCount; i++) {
      final baseAng = rng.nextDouble() * twoPi;
      final baseDist = rng.nextDouble() * r * 0.55;
      final blobR = r * (0.45 + rng.nextDouble() * 0.45);
      final phaseX = rng.nextDouble() * twoPi;
      final phaseY = rng.nextDouble() * twoPi;
      final breathPhase = rng.nextDouble() * twoPi;
      final color = w.colors[i % w.colors.length];

      final dx = math.sin(tick * twoPi + phaseX) * drift;
      final dy = math.cos(tick * twoPi * 0.83 + phaseY) * drift * 0.75;
      final breath = 0.75 + 0.25 * math.sin(tick * twoPi + breathPhase);

      final blobCenter = Offset(
        cx + math.cos(baseAng) * baseDist + dx,
        cy + math.sin(baseAng) * baseDist + dy,
      );

      final coreAlpha = (color.a * density * 0.75 * breath).clamp(0.0, 1.0);
      _paint.shader = RadialGradient(
        colors: [
          color.withValues(alpha: coreAlpha),
          color.withValues(alpha: coreAlpha * 0.55),
          color.withValues(alpha: coreAlpha * 0.15),
          color.withValues(alpha: 0),
        ],
        stops: stops,
      ).createShader(Rect.fromCircle(center: blobCenter, radius: blobR));
      canvas.drawCircle(blobCenter, blobR, _paint);
      _paint.shader = null;
    }
  }
}
