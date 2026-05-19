import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Estetica 8-bit aplicada ao back_ground estrelado da landing — adiciona
/// planetas, anel, luas em orbita stepped, cometa varrendo a tela e
/// manchas de nebulosa, todos desenhados pixel a pixel (sem antialias).
///
/// Convencoes deste arquivo:
/// - "8-bit pixel" = um quadrado de `pixelSize x pixelSize` em logical px;
///   ex.: `pixelSize: 4` faz um planeta de raio 12 ocupar 96 logical px.
/// - Coordenadas dos planetas/nebulas/cometa: fracoes 0..1 do canvas, pra
///   responder a layouts diversos (mobile portrait, desktop ultrawide).
/// - Animacoes: derivadas de um `tick` 0..1 global, com snap explicito
///   pras luas (orbita em N passos discretos) — sem isso o movimento
///   parece smooth, quebra a sensacao 8-bit.

/// Padrao da superficie do planeta — define como pintar os pixels dentro
/// do disco.
enum PlanetPattern {
  /// Faixas horizontais alternando entre as cores da paleta (gas giant
  /// estilo Jupiter).
  bands,

  /// Cor base + pintinhas escuras pseudo-aleatorias (planeta rochoso
  /// estilo Marte).
  speckled,

  /// Hemisferio superior = palette[0], inferior = palette[1] (look
  /// retro estilo Asteroids).
  hemispheres,
}

/// Configuracao de um anel ao redor de um planeta. O anel e desenhado
/// como uma "elipse de pixels" — eixo horizontal completo, eixo vertical
/// comprimido por [tiltY] (0 = linha, 1 = circulo).
@immutable
class PlanetRing {
  const PlanetRing({
    required this.innerRadiusPixels,
    required this.outerRadiusPixels,
    required this.color,
    this.tiltY = 0.30,
  });

  /// Raio interno do anel em 8-bit pixels (gap entre planeta e anel).
  final int innerRadiusPixels;

  /// Raio externo do anel em 8-bit pixels.
  final int outerRadiusPixels;

  final Color color;

  /// Razao de compressao vertical (0..1). Default 0.30 = anel bem fino,
  /// como Saturno visto quase de perfil.
  final double tiltY;
}

/// Lua que orbita o planeta em movimento stepped (snap a `steps` posicoes
/// discretas por ciclo). Quanto menor [steps], mais "jumpy" o movimento.
@immutable
class PlanetMoon {
  const PlanetMoon({
    required this.orbitRadiusPixels,
    required this.moonRadiusPixels,
    required this.color,
    this.steps = 8,
    this.phaseOffset = 0.0,
  });

  final int orbitRadiusPixels;
  final int moonRadiusPixels;
  final Color color;

  /// Numero de posicoes discretas por orbita completa. 8 da movimento
  /// claramente stepped sem ficar "telegrafico". 16 e quase smooth.
  final int steps;

  /// Fase inicial em fracao da orbita (0..1). Permite que luas de
  /// planetas diferentes nao orbitem em fase.
  final double phaseOffset;
}

/// Definicao declarativa de um planeta. Posicao fracional do canvas,
/// tamanho em 8-bit pixels, paleta limitada (3-4 cores tipicas pro look
/// retro) e padrao de superficie.
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

  /// Centro do planeta em fracoes 0..1 do canvas.
  final Offset canvasAnchor;

  /// Raio do planeta em 8-bit pixels.
  final int radiusPixels;

  /// Paleta. Quantas cores sao usadas depende do [pattern]:
  /// - bands: itera ciclicamente (recomendado 2-3 cores);
  /// - speckled: palette[0]=base, palette[1]=crater (recomendado 2);
  /// - hemispheres: palette[0]=topo, palette[1]=baixo.
  final List<Color> palette;

  final PlanetPattern pattern;
  final PlanetRing? ring;
  final PlanetMoon? moon;

  /// Seed pra determinismo do padrao `speckled`. Mudar o seed remove ou
  /// adiciona crateras.
  final int seed;
}

/// Mancha de nebulosa difusa — distribuicao pseudo-aleatoria de pixels
/// dentro de um disco, com alpha caindo nas bordas. Adiciona profundidade
/// sem competir com as estrelas.
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

  /// Probabilidade de cada pixel da nebulosa ser ligado, antes da
  /// atenuacao por distancia. Default 0.55 = textura porosa.
  final double density;

  final int seed;
}

/// Cometa que cruza o canvas em movimento diagonal, com cauda pixelada.
/// Aparece apenas durante a janela `windowStart..windowEnd` do ciclo
/// global — fora dela, nao desenha nada (cometa "fora de cena").
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

  /// Inicio e fim da janela de visibilidade no ciclo global (0..1).
  /// Default: visivel nos primeiros 18% do ciclo, escondido nos outros
  /// 82% — sensacao de evento raro.
  final double windowStart;
  final double windowEnd;
}

/// Painter pixel-art que renderiza nebulosas, planetas, anel, luas em
/// orbita stepped e um cometa que cruza o canvas.
///
/// Performance:
/// - `Paint` cacheados como campos finais;
/// - rasterizacao do disco/anel/nebulosa feita por seed determinista — o
///   custo por frame e O(numero de pixels visiveis), tipicamente algumas
///   centenas;
/// - sem allocacao de Path ou TextPainter no hot loop;
/// - `shouldRepaint` confere campo a campo;
/// - hints `isComplex: true` (centenas de drawRect compensam rasterizar)
///   e `willChange: true` (anima continuamente).
class CosmosPainter extends CustomPainter {
  CosmosPainter({
    required this.tick,
    required this.starColor,
    this.pixelSize = 4,
    this.planets = const [],
    this.nebulas = const [],
    this.comet,
    this.pixelStars = const [],
  });

  /// Fase global da animacao (0..1 em loop). Alimenta orbita de luas,
  /// twinkle das estrelas 8-bit, janela do cometa.
  final double tick;

  /// Cor base das estrelas 8-bit (pixelStars). Twinkle varia a alpha
  /// dessa cor — nao da cor do planeta.
  final Color starColor;

  /// Lado de cada "8-bit pixel" em logical px. Reduz pra ficar mais
  /// detalhado, aumenta pra ficar mais chunky. Default 4.
  final double pixelSize;

  final List<CosmosPlanet> planets;
  final List<CosmosNebula> nebulas;
  final CosmosComet? comet;

  /// Estrelas 8-bit avulsas (1 pixel cada). Posicao em fracao 0..1 do
  /// canvas; a fase de twinkle e derivada do indice na lista.
  final List<Offset> pixelStars;

  late final Paint _fillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Ordem de pintura (de tras pra frente):
    // 1. Nebulosas (mais ao fundo)
    // 2. Estrelas 8-bit avulsas
    // 3. Aneis (atras dos planetas)
    // 4. Planetas
    // 5. Luas (sobre os planetas)
    // 6. Cometa (sempre na frente, evento de destaque)
    for (final n in nebulas) {
      _paintNebula(canvas, size, n);
    }
    _paintPixelStars(canvas, size);
    for (final p in planets) {
      if (p.ring != null) _paintRing(canvas, size, p);
    }
    for (final p in planets) {
      _paintPlanet(canvas, size, p);
    }
    for (final p in planets) {
      if (p.moon != null) _paintMoon(canvas, size, p);
    }
    if (comet != null) _paintComet(canvas, size, comet!);
  }

  // ---------------------------------------------------------------------------
  // NEBULOSA
  // ---------------------------------------------------------------------------

  void _paintNebula(Canvas canvas, Size size, CosmosNebula n) {
    final cx = n.canvasAnchor.dx * size.width;
    final cy = n.canvasAnchor.dy * size.height;
    final r = n.radiusPixels;
    if (r <= 0) return;

    final rng = math.Random(n.seed * 31 + 17);

    // Itera pixels do bounding box e decide cada um por noise + falloff
    // radial. Mantemos sempre o mesmo rng pra que a textura seja estavel
    // entre frames (so a alpha global respira via `tick`).
    final breath = 0.85 + 0.15 *
        (0.5 + 0.5 * math.sin(tick * 2 * math.pi + n.seed.toDouble()));

    for (var py = -r; py <= r; py++) {
      for (var px = -r; px <= r; px++) {
        final d2 = px * px + py * py;
        if (d2 > r * r) continue;
        final t = math.sqrt(d2) / r; // 0..1
        // Falloff suave nas bordas; densidade efetiva = density * (1-t)^2.
        final localDensity = n.density * (1 - t) * (1 - t);
        if (rng.nextDouble() > localDensity) continue;

        final alpha = (n.color.a * (1 - t * 0.9) * breath).clamp(0.0, 1.0);
        _fillPaint.color = n.color.withValues(alpha: alpha);

        final left = cx + px * pixelSize;
        final top = cy + py * pixelSize;
        canvas.drawRect(
          Rect.fromLTWH(left, top, pixelSize, pixelSize),
          _fillPaint,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // ESTRELAS 8-BIT AVULSAS
  // ---------------------------------------------------------------------------

  void _paintPixelStars(Canvas canvas, Size size) {
    for (var i = 0; i < pixelStars.length; i++) {
      final s = pixelStars[i];
      final cx = s.dx * size.width;
      final cy = s.dy * size.height;

      // Twinkle em onda quadrada (binario "aceso/apagado") — fiel ao
      // visual 8-bit. Fase deslocada por indice pra dessincronizar.
      final phase = (tick * 4 + i * 0.13) % 1.0;
      final bright = phase < 0.5;
      final alpha = starColor.a * (bright ? 1.0 : 0.45);

      _fillPaint.color = starColor.withValues(alpha: alpha);
      canvas.drawRect(
        Rect.fromLTWH(cx, cy, pixelSize, pixelSize),
        _fillPaint,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PLANETAS
  // ---------------------------------------------------------------------------

  void _paintPlanet(Canvas canvas, Size size, CosmosPlanet planet) {
    final cx = planet.canvasAnchor.dx * size.width;
    final cy = planet.canvasAnchor.dy * size.height;
    final r = planet.radiusPixels;
    if (r <= 0 || planet.palette.isEmpty) return;

    final rng = math.Random(planet.seed * 101 + 1);

    for (var py = -r; py <= r; py++) {
      for (var px = -r; px <= r; px++) {
        final d2 = px * px + py * py;
        if (d2 > r * r) continue;

        final color = _pickPlanetColor(planet, px, py, r, rng);
        if (color == null) continue;
        _fillPaint.color = color;

        final left = cx + px * pixelSize;
        final top = cy + py * pixelSize;
        canvas.drawRect(
          Rect.fromLTWH(left, top, pixelSize, pixelSize),
          _fillPaint,
        );
      }
    }
  }

  Color? _pickPlanetColor(
    CosmosPlanet planet,
    int px,
    int py,
    int r,
    math.Random rng,
  ) {
    final palette = planet.palette;
    // Shade modifier — pixels mais a sudeste do disco ficam num indice
    // mais alto da paleta (mais escuro), pixels a noroeste num mais
    // baixo (mais claro). Reforca a sensacao de esfera 3D mesmo no 8-bit.
    final shade = (px + py) / (2 * r); // -1 .. 1

    Color base;
    switch (planet.pattern) {
      case PlanetPattern.bands:
        // Faixas de 3 8-bit pixels de altura, ciclicas na paleta.
        final bandIndex = (((py + r) ~/ 3) % palette.length).abs();
        base = palette[bandIndex];
      case PlanetPattern.speckled:
        // Crateras pseudo-aleatorias. rng e re-seeded por planet, entao
        // o mesmo planeta sempre tem as mesmas crateras (estavel).
        if (rng.nextDouble() < 0.10 && palette.length > 1) {
          base = palette[1];
        } else {
          base = palette[0];
        }
      case PlanetPattern.hemispheres:
        base = py < 0 ? palette[0] : palette[palette.length > 1 ? 1 : 0];
    }

    // Aplica shade: pixels sudeste mais escuros, noroeste mais claros.
    // Usa o ultimo / primeiro indice da paleta como sombra / highlight
    // quando ha 3+ cores.
    if (palette.length >= 3) {
      if (shade > 0.45) return palette.last; // sombra forte
      if (shade < -0.45) return palette.first; // brilho
    }
    return base;
  }

  // ---------------------------------------------------------------------------
  // ANEL
  // ---------------------------------------------------------------------------

  void _paintRing(Canvas canvas, Size size, CosmosPlanet planet) {
    final ring = planet.ring;
    if (ring == null) return;
    final cx = planet.canvasAnchor.dx * size.width;
    final cy = planet.canvasAnchor.dy * size.height;
    final ro = ring.outerRadiusPixels;
    final ri = ring.innerRadiusPixels;
    if (ro <= ri || ro <= 0) return;

    final tiltY = ring.tiltY.clamp(0.0, 1.0);
    _fillPaint.color = ring.color;

    // Itera pixels de uma elipse "anular" — checa anel exterior (dentro
    // de ro com tiltY) e exclui interno (dentro de ri com tiltY).
    final roY = (ro * tiltY).round();
    for (var py = -roY; py <= roY; py++) {
      for (var px = -ro; px <= ro; px++) {
        // Equacao da elipse: (px/ro)^2 + (py/(ro*tiltY))^2 <= 1
        final nx = px / ro;
        final ny = tiltY == 0 ? 0.0 : py / (ro * tiltY);
        final outer = nx * nx + ny * ny;
        if (outer > 1) continue;
        // Anel interno (gap entre anel e planeta).
        final nxi = ri == 0 ? 2.0 : px / ri;
        final nyi = (ri == 0 || tiltY == 0) ? 2.0 : py / (ri * tiltY);
        final inner = nxi * nxi + nyi * nyi;
        if (inner < 1) continue;

        // Hide pixels que cairiam atras do planeta (na metade inferior
        // do anel, pixels dentro do disco do planeta nao desenham — o
        // disco do planeta vai por cima depois). Pra simular o anel
        // passando atras do planeta, pulamos pixels dentro do disco.
        if (px * px + py * py <= planet.radiusPixels * planet.radiusPixels) {
          continue;
        }

        canvas.drawRect(
          Rect.fromLTWH(
            cx + px * pixelSize,
            cy + py * pixelSize,
            pixelSize,
            pixelSize,
          ),
          _fillPaint,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // LUA
  // ---------------------------------------------------------------------------

  void _paintMoon(Canvas canvas, Size size, CosmosPlanet planet) {
    final moon = planet.moon;
    if (moon == null) return;

    // Movimento stepped: snap o tick na orbita pra `steps` posicoes
    // discretas por ciclo. Sem isso a lua escorrega — quebra o look.
    final raw = (tick + moon.phaseOffset) % 1.0;
    final stepped = (raw * moon.steps).floor() / moon.steps;
    final angle = stepped * 2 * math.pi;

    final planetCx = planet.canvasAnchor.dx * size.width;
    final planetCy = planet.canvasAnchor.dy * size.height;
    // Orbita comprimida levemente na vertical pra dar sensacao de plano
    // orbital inclinado.
    final mx = planetCx + math.cos(angle) * moon.orbitRadiusPixels * pixelSize;
    final my = planetCy +
        math.sin(angle) * moon.orbitRadiusPixels * pixelSize * 0.55;

    // Desenha a lua como pequeno disco em 8-bit pixels.
    _fillPaint.color = moon.color;
    final mr = moon.moonRadiusPixels;
    for (var py = -mr; py <= mr; py++) {
      for (var px = -mr; px <= mr; px++) {
        if (px * px + py * py > mr * mr) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            mx + px * pixelSize,
            my + py * pixelSize,
            pixelSize,
            pixelSize,
          ),
          _fillPaint,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // COMETA
  // ---------------------------------------------------------------------------

  void _paintComet(Canvas canvas, Size size, CosmosComet c) {
    if (tick < c.windowStart || tick > c.windowEnd) return;
    final windowSpan = c.windowEnd - c.windowStart;
    if (windowSpan <= 0) return;

    final progress = (tick - c.windowStart) / windowSpan;
    final headX = (c.startAnchor.dx +
            (c.endAnchor.dx - c.startAnchor.dx) * progress) *
        size.width;
    final headY = (c.startAnchor.dy +
            (c.endAnchor.dy - c.startAnchor.dy) * progress) *
        size.height;

    // Direcao da cauda: oposta ao movimento, em coords do canvas.
    final dirX = (c.startAnchor.dx - c.endAnchor.dx) * size.width;
    final dirY = (c.startAnchor.dy - c.endAnchor.dy) * size.height;
    final len = math.sqrt(dirX * dirX + dirY * dirY);
    if (len == 0) return;
    final ux = dirX / len;
    final uy = dirY / len;

    // Cauda de N pixels — alpha decresce linearmente do head pro fim.
    for (var i = 0; i < c.tailLengthPixels; i++) {
      final t = i / c.tailLengthPixels;
      final alpha = (c.color.a * (1 - t) * 0.85).clamp(0.0, 1.0);
      _fillPaint.color = c.color.withValues(alpha: alpha);
      final px = headX + ux * i * pixelSize;
      final py = headY + uy * i * pixelSize;
      canvas.drawRect(
        Rect.fromLTWH(px, py, pixelSize, pixelSize),
        _fillPaint,
      );
    }

    // Cabeca um pouco maior (3x3 pixels), bem brilhante.
    _fillPaint.color = c.color;
    for (var py = -1; py <= 1; py++) {
      for (var px = -1; px <= 1; px++) {
        if (px.abs() + py.abs() > 1) continue; // diamante 1-px
        canvas.drawRect(
          Rect.fromLTWH(
            headX + px * pixelSize,
            headY + py * pixelSize,
            pixelSize,
            pixelSize,
          ),
          _fillPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CosmosPainter old) {
    return old.tick != tick ||
        old.starColor != starColor ||
        old.pixelSize != pixelSize ||
        !identical(old.planets, planets) ||
        !identical(old.nebulas, nebulas) ||
        old.comet != comet ||
        !identical(old.pixelStars, pixelStars);
  }

  /// Hint pro `CustomPaint` host: centenas de drawRect por frame justificam
  /// rasterizar em layer (cache de raster pra GPU).
  bool get isComplex => true;

  /// Hint pro `CustomPaint` host: cena anima continuamente (luas, twinkle,
  /// nebulosa respirando).
  bool get willChange => true;
}
