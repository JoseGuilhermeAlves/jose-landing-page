import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Cosmos pixel-art 32-bit — paletas 9-stop interpoladas + Bayer 8x8 pra
/// dithering fino (transicoes suaves mas ainda stippled), planetas e
/// nebulosas pre-renderizados pra `ui.Image` cacheada (1 blit/frame em
/// vez de 2-10k drawRect).
///
/// Performance strategy:
/// - **Bitmap caching**: cada planeta (corpo + atmosfera) renderiza UMA
///   vez no primeiro frame, vira `ui.Image`, depois e blit via
///   `drawImageRect`. Cache estatica sobrevive a recriacao do painter
///   (AnimatedBuilder reconstroi o painter por frame).
/// - **Per-frame**: so estrelas (twinkle), luas (orbita), cometa (janela).
///   Tudo cheap em count.
/// - **Single mutable `_paint`** com AA off pros draws per-frame.
/// - **`shouldRepaint`** campo a campo.

/// Padrao da superficie do planeta.
enum PlanetPattern {
  /// Faixas horizontais — gas giant com vortex spot.
  bands,

  /// Crateras pseudo-aleatorias — planeta rochoso.
  speckled,

  /// Hemisferio inferior mais escuro + polar caps.
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

  /// Palette base (3-9 cores). O painter interpola pra rampa fixa de 9
  /// stops, dando dither fino estilo 32-bit.
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

/// Painter pixel-art com caching agressivo.
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
  final double pixelSize;
  final List<CosmosPlanet> planets;
  final List<CosmosNebula> nebulas;
  final CosmosComet? comet;

  /// Estrelas cadentes (multiple comets). Cada uma com janela propria de
  /// visibilidade — distribuir as janelas pelo ciclo da animacao da
  /// sensacao de eventos cosmicos esparsos.
  final List<CosmosComet> shootingStars;

  final List<Offset> pixelStars;

  /// Mutable paint pros draws per-frame (stars/moons/comet). AA off,
  /// FilterQuality none — pixel-perfect mesmo em scale.
  final Paint _paint = Paint()
    ..isAntiAlias = false
    ..filterQuality = FilterQuality.none
    ..style = PaintingStyle.fill;

  /// Cache estatica de imagens — sobrevive recriacao do painter.
  /// Key = hash determinista das props que afetam pixel output.
  static final Map<int, ui.Image> _planetCache = {};
  static final Map<int, ui.Image> _ringCache = {};
  static final Map<int, ui.Image> _nebulaCache = {};

  /// Util pra testes / hot reload — limpa todas as imagens cacheadas.
  static void clearCache() {
    for (final img in _planetCache.values) {
      img.dispose();
    }
    for (final img in _ringCache.values) {
      img.dispose();
    }
    for (final img in _nebulaCache.values) {
      img.dispose();
    }
    _planetCache.clear();
    _ringCache.clear();
    _nebulaCache.clear();
  }

  /// Bayer 8x8 / 64 — thresholds 0..1 pra dithering ordenado fino.
  /// 64 niveis de threshold espalham transicoes em padroes mais sutis
  /// que o 4x4, dando feel 32-bit em vez de 16-bit.
  static const List<List<double>> _bayer8 = [
    [0 / 64, 32 / 64, 8 / 64, 40 / 64, 2 / 64, 34 / 64, 10 / 64, 42 / 64],
    [48 / 64, 16 / 64, 56 / 64, 24 / 64, 50 / 64, 18 / 64, 58 / 64, 26 / 64],
    [12 / 64, 44 / 64, 4 / 64, 36 / 64, 14 / 64, 46 / 64, 6 / 64, 38 / 64],
    [60 / 64, 28 / 64, 52 / 64, 20 / 64, 62 / 64, 30 / 64, 54 / 64, 22 / 64],
    [3 / 64, 35 / 64, 11 / 64, 43 / 64, 1 / 64, 33 / 64, 9 / 64, 41 / 64],
    [51 / 64, 19 / 64, 59 / 64, 27 / 64, 49 / 64, 17 / 64, 57 / 64, 25 / 64],
    [15 / 64, 47 / 64, 7 / 64, 39 / 64, 13 / 64, 45 / 64, 5 / 64, 37 / 64],
    [63 / 64, 31 / 64, 55 / 64, 23 / 64, 61 / 64, 29 / 64, 53 / 64, 21 / 64],
  ];

  /// Quantidade de stops na rampa de cor — 9 ja da banded suficientemente
  /// fino pra parecer 32-bit (mais que isso vira gradient indistinguivel
  /// de smooth).
  static const int _rampStops = 9;

  /// Aneis atmosfericos por planeta. Renderizados dentro da imagem
  /// cacheada (mais barato que repintar fora dela todo frame).
  static const int _atmosRings = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Ordem: nebulosas → estrelas → anel-tras → planeta(corpo+atmos)
    // → anel-frente → luas → cometa.
    for (final n in nebulas) {
      _blitNebula(canvas, size, n);
    }
    _paintStars(canvas, size);
    for (final p in planets) {
      if (p.ring != null) _blitRingHalf(canvas, size, p, front: false);
    }
    for (final p in planets) {
      _blitPlanet(canvas, size, p);
    }
    for (final p in planets) {
      if (p.ring != null) _blitRingHalf(canvas, size, p, front: true);
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
  // PLANETA — cache + blit
  // ===========================================================================

  void _blitPlanet(Canvas canvas, Size size, CosmosPlanet planet) {
    if (planet.palette.isEmpty || planet.radiusPixels <= 0) return;
    final img = _getOrRenderPlanet(planet);
    final center = _planetCenter(planet, size);
    final hw = img.width / 2.0;
    final hh = img.height / 2.0;
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTRB(
        center.dx - hw,
        center.dy - hh,
        center.dx + hw,
        center.dy + hh,
      ),
      _paint,
    );
  }

  ui.Image _getOrRenderPlanet(CosmosPlanet planet) {
    final key = Object.hash(
      planet.id,
      planet.radiusPixels,
      planet.pattern.index,
      planet.seed,
      pixelSize,
      Object.hashAll(planet.palette),
    );
    return _planetCache.putIfAbsent(key, () => _renderPlanetImage(planet));
  }

  ui.Image _renderPlanetImage(CosmosPlanet planet) {
    final r = planet.radiusPixels;
    final unitSize = 2 * (r + _atmosRings + 1);
    final pxSize = (unitSize * pixelSize).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, pxSize.toDouble(), pxSize.toDouble()),
    );

    final cx = pxSize / 2.0;
    final cy = pxSize / 2.0;

    final ramp = _resolveRamp(planet.palette);
    final craters = planet.pattern == PlanetPattern.speckled
        ? _craterList(planet.seed, r)
        : const <_Crater>[];
    final vortex = planet.pattern == PlanetPattern.bands
        ? _Vortex.forPlanet(r, planet.seed)
        : null;

    // Atmosfera primeiro (atras do corpo).
    _renderAtmosphereTo(canvas, ramp.last, r, cx, cy);
    // Corpo.
    _renderPlanetBodyTo(
      canvas,
      ramp: ramp,
      craters: craters,
      vortex: vortex,
      pattern: planet.pattern,
      r: r,
      cx: cx,
      cy: cy,
    );

    final picture = recorder.endRecording();
    final img = picture.toImageSync(pxSize, pxSize);
    picture.dispose();
    return img;
  }

  void _renderAtmosphereTo(
    Canvas canvas,
    Color rim,
    int r,
    double cx,
    double cy,
  ) {
    const alphas = [0.45, 0.28, 0.16, 0.08];
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none
      ..style = PaintingStyle.fill;
    for (var step = 0; step < _atmosRings; step++) {
      final ringR = r + 1 + step;
      paint.color =
          rim.withValues(alpha: (rim.a * alphas[step]).clamp(0.0, 1.0));
      _drawPixelRingTo(canvas, paint, cx, cy, ringR);
    }
  }

  void _drawPixelRingTo(
    Canvas canvas,
    Paint paint,
    double cx,
    double cy,
    int radius,
  ) {
    if (radius <= 0) return;
    final r2 = radius * radius;
    final r2Inner = (radius - 1) * (radius - 1);
    for (var py = -radius; py <= radius; py++) {
      final ymag = py * py;
      if (ymag > r2) continue;
      final hwOuter = math.sqrt(r2 - ymag).floor();
      final hwInner =
          ymag <= r2Inner ? math.sqrt(r2Inner - ymag).floor() : -1;
      if (hwInner < 0) {
        // Linha cheia (topo/fundo do anel).
        canvas.drawRect(
          Rect.fromLTWH(
            cx + (-hwOuter) * pixelSize,
            cy + py * pixelSize,
            (2 * hwOuter + 1) * pixelSize,
            pixelSize,
          ),
          paint,
        );
      } else {
        final segWidth = hwOuter - hwInner;
        if (segWidth > 0) {
          canvas
            ..drawRect(
              Rect.fromLTWH(
                cx + (-hwOuter) * pixelSize,
                cy + py * pixelSize,
                segWidth * pixelSize,
                pixelSize,
              ),
              paint,
            )
            ..drawRect(
              Rect.fromLTWH(
                cx + (hwInner + 1) * pixelSize,
                cy + py * pixelSize,
                segWidth * pixelSize,
                pixelSize,
              ),
              paint,
            );
        }
      }
    }
  }

  void _renderPlanetBodyTo(
    Canvas canvas, {
    required List<Color> ramp,
    required List<_Crater> craters,
    required _Vortex? vortex,
    required PlanetPattern pattern,
    required int r,
    required double cx,
    required double cy,
  }) {
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none
      ..style = PaintingStyle.fill;

    for (var py = -r; py <= r; py++) {
      final ymag = py * py;
      if (ymag > r * r) continue;
      final hw = math.sqrt(r * r - ymag).floor();

      // Run-batching horizontal: agrupa pixels adjacentes do mesmo idx.
      int? runStart;
      int? runIdx;

      for (var px = -hw; px <= hw + 1; px++) {
        int? idx;
        if (px <= hw) {
          idx = _paletteIndex(
            px: px,
            py: py,
            r: r,
            pattern: pattern,
            craters: craters,
            vortex: vortex,
            rampLen: ramp.length,
          );
        }
        if (idx != runIdx) {
          if (runIdx != null && runStart != null) {
            paint.color = ramp[runIdx];
            canvas.drawRect(
              Rect.fromLTWH(
                cx + runStart * pixelSize,
                cy + py * pixelSize,
                (px - runStart) * pixelSize,
                pixelSize,
              ),
              paint,
            );
          }
          runStart = px;
          runIdx = idx;
        }
      }
    }
  }

  int _paletteIndex({
    required int px,
    required int py,
    required int r,
    required PlanetPattern pattern,
    required List<_Crater> craters,
    required _Vortex? vortex,
    required int rampLen,
  }) {
    final nx = (px + 0.5) / r;
    final ny = (py + 0.5) / r;
    final nz2 = 1 - nx * nx - ny * ny;
    final nz = nz2 > 0 ? math.sqrt(nz2) : 0.0;

    // Luz top-left, ligeiramente pra frente do disco.
    const lx = -0.50;
    const ly = -0.50;
    const lz = 0.71;
    var lambert = (nx * lx + ny * ly + nz * lz).clamp(-0.15, 1.0);

    // Pattern modifier.
    switch (pattern) {
      case PlanetPattern.bands:
        // Bandas mais largas (5 unidades) com mods sutis.
        final band = (((py + r) ~/ 5) % 5);
        const bandMods = [0.10, -0.04, 0.06, -0.12, 0.02];
        lambert += bandMods[band];
        if (vortex != null && vortex.contains(px, py)) {
          lambert -= 0.30;
          if (vortex.isRim(px, py)) lambert += 0.55;
        }
      case PlanetPattern.speckled:
        for (final c in craters) {
          final dx = px - c.dx;
          final dy = py - c.dy;
          final d2 = dx * dx + dy * dy;
          if (d2 <= c.r2) {
            lambert -= 0.35;
            // Crater rim NW highlight.
            if (d2 > c.r2 * 0.55 && dx + dy < 0) lambert += 0.55;
            break;
          }
        }
      case PlanetPattern.hemispheres:
        if (py > 0) lambert -= 0.18;
        if (py < -r * 0.72 || py > r * 0.72) lambert += 0.35;
    }

    // Bayer 8x8 dither — width pequeno (0.10) pra dither sutil, transicoes
    // ficam stippled mas nao "ruidosas".
    final bayer = _bayer8[py & 7][px & 7];
    final dithered = lambert + (bayer - 0.5) * 0.10;

    final idx = (dithered * (rampLen - 1)).round();
    return idx.clamp(0, rampLen - 1);
  }

  // ===========================================================================
  // ANEL — cache + blit (front/back halves via clipRect)
  // ===========================================================================

  void _blitRingHalf(
    Canvas canvas,
    Size size,
    CosmosPlanet planet, {
    required bool front,
  }) {
    final ring = planet.ring!;
    if (ring.outerRadiusPixels <= ring.innerRadiusPixels) return;

    final img = _getOrRenderRing(ring);
    final center = _planetCenter(planet, size);
    final hw = img.width / 2.0;
    final hh = img.height / 2.0;

    canvas.save();
    if (front) {
      canvas.clipRect(
        Rect.fromLTWH(0, center.dy, size.width, size.height - center.dy),
      );
    } else {
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, center.dy));
    }
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTRB(
        center.dx - hw,
        center.dy - hh,
        center.dx + hw,
        center.dy + hh,
      ),
      _paint,
    );
    canvas.restore();
  }

  ui.Image _getOrRenderRing(PlanetRing ring) {
    final key = Object.hash(
      ring.innerRadiusPixels,
      ring.outerRadiusPixels,
      ring.color.toARGB32(),
      ring.tiltY,
      pixelSize,
    );
    return _ringCache.putIfAbsent(key, () => _renderRingImage(ring));
  }

  ui.Image _renderRingImage(PlanetRing ring) {
    final outerR = ring.outerRadiusPixels;
    final tiltY = ring.tiltY.clamp(0.05, 1.0);
    final outerH = (outerR * tiltY).ceil();
    final pxW = ((2 * outerR + 1) * pixelSize).ceil();
    final pxH = ((2 * outerH + 1) * pixelSize).ceil();
    if (pxW <= 0 || pxH <= 0) {
      return _emptyImage();
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, pxW.toDouble(), pxH.toDouble()),
    );
    final cx = pxW / 2.0;
    final cy = pxH / 2.0;

    final ramp = _ringRamp(ring.color);
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none
      ..style = PaintingStyle.fill;
    final innerR = ring.innerRadiusPixels;
    final ringSpan = math.max(1, outerR - innerR);

    for (var py = -outerH; py <= outerH; py++) {
      for (var px = -outerR; px <= outerR; px++) {
        final nx = px / outerR;
        final ny = py / (outerR * tiltY);
        final outerN = nx * nx + ny * ny;
        if (outerN > 1) continue;
        final nxi = innerR == 0 ? 2.0 : px / innerR;
        final nyi = innerR == 0 ? 2.0 : py / (innerR * tiltY);
        if (nxi * nxi + nyi * nyi < 1) continue;

        final tNorm =
            (math.sqrt(px * px + py * py) - innerR) / ringSpan;
        final bandIdx =
            (tNorm * ramp.length).floor().clamp(0, ramp.length - 1);

        final bayer = _bayer8[py & 7][px & 7];
        if (bayer < 0.10 && bandIdx.isOdd) continue;

        paint.color = ramp[bandIdx];
        canvas.drawRect(
          Rect.fromLTWH(
            cx + px * pixelSize,
            cy + py * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    final img = picture.toImageSync(pxW, pxH);
    picture.dispose();
    return img;
  }

  List<Color> _ringRamp(Color base) {
    return [
      base.withValues(alpha: (base.a * 0.55).clamp(0.0, 1.0)),
      base.withValues(alpha: (base.a * 0.80).clamp(0.0, 1.0)),
      base.withValues(alpha: (base.a * 1.00).clamp(0.0, 1.0)),
      base.withValues(alpha: (base.a * 0.72).clamp(0.0, 1.0)),
    ];
  }

  // ===========================================================================
  // NEBULOSA — cache + blit
  // ===========================================================================

  void _blitNebula(Canvas canvas, Size size, CosmosNebula n) {
    if (n.radiusPixels <= 0) return;
    final img = _getOrRenderNebula(n);
    final cx = _snap(n.canvasAnchor.dx * size.width);
    final cy = _snap(n.canvasAnchor.dy * size.height);
    final hw = img.width / 2.0;
    final hh = img.height / 2.0;

    // Pulsacao por palette cycle stepped — 2 estados via alpha.
    final phase = ((tick + n.seed * 0.1) * 4).floor() & 1;
    final pulseAlpha = phase == 0 ? 1.0 : 0.78;
    _paint.colorFilter = ColorFilter.mode(
      Colors.white.withValues(alpha: pulseAlpha),
      BlendMode.modulate,
    );
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTRB(cx - hw, cy - hh, cx + hw, cy + hh),
      _paint,
    );
    _paint.colorFilter = null;
  }

  ui.Image _getOrRenderNebula(CosmosNebula n) {
    final key = Object.hash(
      n.radiusPixels,
      n.color.toARGB32(),
      n.density,
      n.seed,
      pixelSize,
    );
    return _nebulaCache.putIfAbsent(key, () => _renderNebulaImage(n));
  }

  ui.Image _renderNebulaImage(CosmosNebula n) {
    final r = n.radiusPixels;
    final pxSize = ((2 * r + 1) * pixelSize).ceil();
    if (pxSize <= 0) return _emptyImage();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, pxSize.toDouble(), pxSize.toDouble()),
    );
    final cx = pxSize / 2.0;
    final cy = pxSize / 2.0;

    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none
      ..style = PaintingStyle.fill;
    final rng = math.Random(n.seed * 31 + 17);

    for (var py = -r; py <= r; py++) {
      final ymag = py * py;
      if (ymag > r * r) continue;
      final hw = math.sqrt(r * r - ymag).floor();
      for (var px = -hw; px <= hw; px++) {
        final d2 = px * px + py * py;
        final tNorm = math.sqrt(d2) / r;
        final localDensity = n.density * (1 - tNorm) * (1 - tNorm);
        final bayer = _bayer8[py & 7][px & 7];
        if (bayer > localDensity) continue;
        if (rng.nextDouble() > localDensity * 1.4) continue;

        final alpha = (n.color.a * (1 - tNorm * 0.85)).clamp(0.0, 1.0);
        paint.color = n.color.withValues(alpha: alpha);
        canvas.drawRect(
          Rect.fromLTWH(
            cx + px * pixelSize,
            cy + py * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    final img = picture.toImageSync(pxSize, pxSize);
    picture.dispose();
    return img;
  }

  // ===========================================================================
  // STARS — per-frame, cheap
  // ===========================================================================

  void _paintStars(Canvas canvas, Size size) {
    const coolTint = Color(0xFFBFD4FF);
    const warmTint = Color(0xFFFFD8A0);

    for (var i = 0; i < pixelStars.length; i++) {
      final s = pixelStars[i];
      final cx = _snap(s.dx * size.width);
      final cy = _snap(s.dy * size.height);

      final isFeatured = i % 6 == 0;
      final isDistant = !isFeatured && i % 3 == 1;

      // Stars NAO piscam mais — alpha estavel por tier. So as featured
      // tem um sine pulse muito sutil (0.85-1.0) — imperceptivel como
      // "blink", percebido so como "vida".
      final featuredPulse = isFeatured
          ? 0.925 + 0.075 * math.sin(tick * 2 * math.pi + i * 0.4)
          : 1.0;

      Color baseColor;
      double tierAlpha;
      if (isFeatured) {
        baseColor = (i % 12 == 0) ? warmTint : coolTint;
        tierAlpha = 1.0;
      } else if (isDistant) {
        baseColor = starColor;
        tierAlpha = 0.50;
      } else {
        baseColor = starColor;
        tierAlpha = 0.85;
      }
      final alpha = (baseColor.a * featuredPulse * tierAlpha).clamp(0.0, 1.0);
      _paint.color = baseColor.withValues(alpha: alpha);

      if (isFeatured) {
        _drawFeaturedStar(canvas, cx, cy);
      } else if (isDistant) {
        canvas.drawRect(
          Rect.fromLTWH(
            cx + pixelSize * 0.25,
            cy + pixelSize * 0.25,
            pixelSize * 0.5,
            pixelSize * 0.5,
          ),
          _paint,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(cx, cy, pixelSize, pixelSize),
          _paint,
        );
      }
    }
  }

  void _drawFeaturedStar(Canvas canvas, double cx, double cy) {
    final p = pixelSize;
    // Diamond 3x3:
    //   .X.
    //   XXX
    //   .X.
    canvas
      ..drawRect(Rect.fromLTWH(cx, cy - p, p, p), _paint)
      ..drawRect(Rect.fromLTWH(cx - p, cy, p * 3, p), _paint)
      ..drawRect(Rect.fromLTWH(cx, cy + p, p, p), _paint);

    // Halo 4-corners (5x5 diamond extremes) com alpha reduzida — agora
    // sempre desenhado (sem condicao "atPeak" que causava blink).
    final original = _paint.color;
    _paint.color = original.withValues(
      alpha: (original.a * 0.35).clamp(0.0, 1.0),
    );
    canvas
      ..drawRect(Rect.fromLTWH(cx, cy - 2 * p, p, p), _paint)
      ..drawRect(Rect.fromLTWH(cx - 2 * p, cy, p, p), _paint)
      ..drawRect(Rect.fromLTWH(cx + 2 * p, cy, p, p), _paint)
      ..drawRect(Rect.fromLTWH(cx, cy + 2 * p, p, p), _paint);
    _paint.color = original;
  }

  // ===========================================================================
  // PLANET DRIFT — movimento sutil estilo parallax
  // ===========================================================================

  /// Centro efetivo do planeta no canvas, com drift aplicado.
  /// Drift e snapped a multiplos de `pixelSize` pra preservar pixel
  /// grid alignment.
  Offset _planetCenter(CosmosPlanet planet, Size size) {
    final drift = _planetDrift(planet);
    return Offset(
      _snap(planet.canvasAnchor.dx * size.width + drift.dx),
      _snap(planet.canvasAnchor.dy * size.height + drift.dy),
    );
  }

  Offset _planetDrift(CosmosPlanet planet) {
    // Range escala com sqrt(radius) — gigantes drift mais, pequenos
    // menos (sensacao parallax: maior = mais perto = move mais).
    final rangeX = math.sqrt(planet.radiusPixels.toDouble()) * 1.4;
    final rangeY = math.sqrt(planet.radiusPixels.toDouble()) * 0.5;
    final phase = planet.seed * 0.31;
    return Offset(
      math.sin(tick * 2 * math.pi + phase) * rangeX,
      math.cos(tick * 2 * math.pi * 0.7 + phase + 1.5) * rangeY,
    );
  }

  // ===========================================================================
  // LUA — per-frame, cheap (raio pequeno)
  // ===========================================================================

  void _paintMoon(Canvas canvas, Size size, CosmosPlanet planet) {
    final moon = planet.moon!;
    final raw = (tick + moon.phaseOffset) % 1.0;
    final t =
        moon.steps > 0 ? (raw * moon.steps).floor() / moon.steps : raw;
    final angle = t * 2 * math.pi;

    final center = _planetCenter(planet, size);
    final orbitR = moon.orbitRadiusPixels;
    final mx = _snap(center.dx + math.cos(angle) * orbitR * pixelSize);
    final my =
        _snap(center.dy + math.sin(angle) * orbitR * pixelSize * 0.45);

    final mr = moon.moonRadiusPixels;
    if (mr <= 0) return;

    final ramp = _moonRamp(moon.color);
    for (var py = -mr; py <= mr; py++) {
      final ymag = py * py;
      if (ymag > mr * mr) continue;
      final hw = math.sqrt(mr * mr - ymag).floor();
      for (var px = -hw; px <= hw; px++) {
        final nx = (px + 0.5) / mr;
        final ny = (py + 0.5) / mr;
        final nz2 = 1 - nx * nx - ny * ny;
        final nz = nz2 > 0 ? math.sqrt(nz2) : 0.0;
        const lx = -0.5;
        const ly = -0.5;
        const lz = 0.71;
        final lambert = (nx * lx + ny * ly + nz * lz).clamp(-0.15, 1.0);
        final bayer = _bayer8[py & 7][px & 7];
        final dithered = lambert + (bayer - 0.5) * 0.10;
        final idx = (dithered * (ramp.length - 1))
            .round()
            .clamp(0, ramp.length - 1);
        _paint.color = ramp[idx];
        canvas.drawRect(
          Rect.fromLTWH(
            mx + px * pixelSize,
            my + py * pixelSize,
            pixelSize,
            pixelSize,
          ),
          _paint,
        );
      }
    }
  }

  List<Color> _moonRamp(Color base) {
    return [
      _darker(base, 0.70),
      _darker(base, 0.45),
      _darker(base, 0.20),
      base,
      _lighter(base, 0.20),
    ];
  }

  // ===========================================================================
  // COMETA — per-frame, cheap (so ativo na janela)
  // ===========================================================================

  void _paintComet(Canvas canvas, Size size, CosmosComet c) {
    if (tick < c.windowStart || tick > c.windowEnd) return;
    final windowSpan = c.windowEnd - c.windowStart;
    if (windowSpan <= 0) return;

    final progress = (tick - c.windowStart) / windowSpan;
    final headX = _snap(
      (c.startAnchor.dx + (c.endAnchor.dx - c.startAnchor.dx) * progress) *
          size.width,
    );
    final headY = _snap(
      (c.startAnchor.dy + (c.endAnchor.dy - c.startAnchor.dy) * progress) *
          size.height,
    );

    final dirX = (c.startAnchor.dx - c.endAnchor.dx) * size.width;
    final dirY = (c.startAnchor.dy - c.endAnchor.dy) * size.height;
    final len = math.sqrt(dirX * dirX + dirY * dirY);
    if (len == 0) return;
    final ux = dirX / len;
    final uy = dirY / len;

    for (var i = c.tailLengthPixels; i >= 1; i--) {
      final tt = i / c.tailLengthPixels;
      final alpha = (c.color.a * (1 - tt) * 0.9).clamp(0.0, 1.0);
      _paint.color = c.color.withValues(alpha: alpha);
      final tx = _snap(headX + ux * i * pixelSize);
      final ty = _snap(headY + uy * i * pixelSize);
      canvas.drawRect(
        Rect.fromLTWH(tx, ty, pixelSize, pixelSize),
        _paint,
      );
    }

    _paint.color = c.color;
    final p = pixelSize;
    canvas
      ..drawRect(Rect.fromLTWH(headX, headY - p, p, p), _paint)
      ..drawRect(Rect.fromLTWH(headX - p, headY, p * 3, p), _paint)
      ..drawRect(Rect.fromLTWH(headX, headY + p, p, p), _paint);
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  double _snap(double v) => (v / pixelSize).roundToDouble() * pixelSize;

  /// Interpola palette de input (1-N cores) pra rampa fixa de 9 stops.
  List<Color> _resolveRamp(List<Color> palette) {
    if (palette.isEmpty) {
      return List<Color>.filled(_rampStops, const Color(0xFF000000));
    }
    if (palette.length == 1) {
      return List<Color>.filled(_rampStops, palette.first);
    }
    final result = <Color>[];
    for (var i = 0; i < _rampStops; i++) {
      final t = i / (_rampStops - 1);
      final pos = t * (palette.length - 1);
      final lo = pos.floor().clamp(0, palette.length - 1);
      final hi = (lo + 1).clamp(0, palette.length - 1);
      final f = pos - lo;
      result.add(_mix(palette[lo], palette[hi], f));
    }
    return result;
  }

  ui.Image _emptyImage() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 1, 1));
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1, 1),
      Paint()..color = const Color(0x00000000),
    );
    final pic = recorder.endRecording();
    final img = pic.toImageSync(1, 1);
    pic.dispose();
    return img;
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
// SURFACE FEATURES — internal helpers
// =============================================================================

class _Crater {
  const _Crater(this.dx, this.dy, this.r2);
  final double dx;
  final double dy;
  final double r2;
}

List<_Crater> _craterList(int seed, int r) {
  final rng = math.Random(seed * 101 + 7);
  final sizeBonus = (r ~/ 50).clamp(0, 12);
  final count = 6 + rng.nextInt(4) + sizeBonus;
  return List<_Crater>.generate(count, (_) {
    final ang = rng.nextDouble() * 2 * math.pi;
    final dist = rng.nextDouble() * r * 0.78;
    final cdx = math.cos(ang) * dist;
    final cdy = math.sin(ang) * dist;
    final crad = 1.5 + rng.nextDouble() * (r * 0.06 + 1.5);
    return _Crater(cdx, cdy, crad * crad);
  });
}

class _Vortex {
  const _Vortex(this.cx, this.cy, this.rx, this.ry);
  final double cx;
  final double cy;
  final double rx;
  final double ry;

  static _Vortex forPlanet(int r, int seed) {
    final rng = math.Random(seed * 53 + 11);
    final dx = (rng.nextDouble() * 0.6 - 0.3) * r;
    final dy = (0.1 + rng.nextDouble() * 0.25) * r;
    final rx = r * (0.18 + rng.nextDouble() * 0.08);
    final ry = rx * (0.5 + rng.nextDouble() * 0.2);
    return _Vortex(dx, dy, rx, ry);
  }

  bool contains(int px, int py) {
    final dx = px - cx;
    final dy = py - cy;
    return (dx * dx) / (rx * rx) + (dy * dy) / (ry * ry) < 1;
  }

  bool isRim(int px, int py) {
    final dx = px - cx;
    final dy = py - cy;
    final n = (dx * dx) / (rx * rx) + (dy * dy) / (ry * ry);
    return n > 0.65 && n < 1.0;
  }
}

// =============================================================================
// COLOR HELPERS
// =============================================================================

Color _darker(Color c, double factor) {
  final k = (1 - factor).clamp(0.0, 1.0);
  return Color.from(alpha: c.a, red: c.r * k, green: c.g * k, blue: c.b * k);
}

Color _lighter(Color c, double factor) {
  final k = factor.clamp(0.0, 1.0);
  return Color.from(
    alpha: c.a,
    red: (c.r * (1 - k) + k).clamp(0.0, 1.0),
    green: (c.g * (1 - k) + k).clamp(0.0, 1.0),
    blue: (c.b * (1 - k) + k).clamp(0.0, 1.0),
  );
}

Color _mix(Color a, Color b, double t) {
  final s = 1 - t;
  return Color.from(
    alpha: a.a * s + b.a * t,
    red: a.r * s + b.r * t,
    green: a.g * s + b.g * t,
    blue: a.b * s + b.b * t,
  );
}
