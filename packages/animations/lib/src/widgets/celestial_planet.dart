import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Corpo celeste pixel-art desenhado 100% em CustomPainter (sem imagem —
/// fiel a tese "tudo e Canvas" do projeto). Mira a qualidade de sprite
/// 16-bit: silhueta redonda (grid de alta resolucao), sombreamento de
/// esfera (lambert + ambient, sem facetar), outline de 1px por vizinhanca,
/// e superficie propria por tipo — bandas gasosas, crateras, veias de lava
/// por noise, continentes/nuvens, sol emissivo, portal de buraco-negro.
/// Tudo em blocos quadrados sem antialias (pixel-perfect); o glow fica a
/// cargo de quem usa (camada de bloom separada).
enum CelestialBody { lava, saturn, ice, earth, sun, moon, portal }

/// Widget conveniente: desenha [body] preenchendo o espaco dado.
class CelestialPlanet extends StatelessWidget {
  const CelestialPlanet({required this.body, this.seed = 7, super.key});

  final CelestialBody body;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: CelestialPainter(body: body, seed: seed),
      ),
    );
  }
}

/// Painter de um corpo celeste. Estatico (nao anima); o tipo decide
/// silhueta, paleta e padrao de superficie.
class CelestialPainter extends CustomPainter {
  CelestialPainter({required this.body, this.seed = 7})
    : _cell = Paint()..isAntiAlias = false;

  final CelestialBody body;
  final int seed;
  final Paint _cell;

  /// Lado-alvo do pixel (px) — fino o bastante pra silhueta redonda.
  static const double _targetPx = 2.6;
  static final _light = _norm3(-0.5, -0.62, 0.6);

  bool get _hasRing => body == CelestialBody.saturn;

  /// Fracao do half-size ocupada pelo disco do corpo. Saturno deixa margem
  /// pro anel; o sol deixa margem pra corona/raios; o resto quase preenche.
  double get _discScale => switch (body) {
    CelestialBody.saturn => 0.6,
    CelestialBody.sun => 0.56,
    _ => 0.92,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (shortest / 2) * _discScale;
    final grid = (shortest / _targetPx).round().clamp(30, 96);
    final px = shortest / grid;
    final origin = Offset(center.dx - shortest / 2, center.dy - shortest / 2);
    final cfg = _configFor(body);

    void drawCell(int gx, int gy, Color c) {
      _cell.color = c;
      canvas.drawRect(
        Rect.fromLTWH(
          origin.dx + gx * px,
          origin.dy + gy * px,
          px + .6,
          px + .6,
        ),
        _cell,
      );
    }

    // Coords normalizadas (-1..1) do centro de uma celula relativas ao raio.
    double nx(int gx) => (origin.dx + (gx + .5) * px - center.dx) / radius;
    double ny(int gy) => (origin.dy + (gy + .5) * px - center.dy) / radius;
    bool inDisc(int gx, int gy) {
      final u = nx(gx);
      final v = ny(gy);
      return u * u + v * v <= 1;
    }

    // 1) Anel de tras (saturno) — metade superior, atras do corpo.
    if (_hasRing) {
      _paintRing(grid, drawCell, nx, ny, cfg.ringColor!, back: true);
    }

    // 1b) Corona/raios do sol — emanam de tras do disco pra fora.
    if (body == CelestialBody.sun) {
      _paintSunCorona(grid, drawCell, nx, ny, cfg.ramp);
    }

    // 2) Corpo.
    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        final u = nx(gx);
        final v = ny(gy);
        final d2 = u * u + v * v;
        if (d2 > 1) continue;

        // Outline 1px: celula de borda (vizinho fora do disco).
        final edge =
            !inDisc(gx - 1, gy) ||
            !inDisc(gx + 1, gy) ||
            !inDisc(gx, gy - 1) ||
            !inDisc(gx, gy + 1);
        if (edge && body != CelestialBody.sun) {
          drawCell(gx, gy, cfg.outline);
          continue;
        }
        drawCell(gx, gy, _surface(cfg, u, v, d2, gx, gy));
      }
    }

    // 3) Anel da frente (saturno) — metade inferior, sobre o corpo.
    if (_hasRing) {
      _paintRing(grid, drawCell, nx, ny, cfg.ringColor!, back: false);
    }
  }

  /// Cor da superficie de uma celula conforme o tipo.
  Color _surface(_Cfg cfg, double u, double v, double d2, int gx, int gy) {
    final ramp = cfg.ramp;
    final nz = math.sqrt(1 - d2);

    // Sol: emissivo (sem terminator) — brilho radial + flares.
    if (body == CelestialBody.sun) {
      final flare = _fbm((u + 1) * 2.4, (v + 1) * 2.4, seed, 4);
      final l = ((1 - d2) * 0.72 + flare * 0.5).clamp(0.0, 1.0);
      return _band(ramp, l);
    }

    // Portal: disco escuro + cruz + aro tratados a parte; aqui so o fundo.
    if (body == CelestialBody.portal) {
      return _portalColor(cfg, u, v, d2);
    }

    // Lambert + ambient (sem smoothstep — esfera macia, nao facetada).
    var l = (0.16 + 0.86 * (u * _light[0] + v * _light[1] + nz * _light[2]))
        .clamp(0.0, 1.0);

    switch (body) {
      case CelestialBody.saturn:
        l = (l + 0.13 * math.sin(v * 7 + math.sin(u * 2.2) * 0.9)).clamp(0, 1);
      case CelestialBody.ice:
        l = (l + 0.07 * math.sin(v * 9)).clamp(0, 1);
        if (v < -0.6 || v > 0.62) l = math.max(l, 0.82); // calotas
      case CelestialBody.lava:
        final n = _fbm((u + 1) * 3.2, (v + 1) * 3.2, seed, 4);
        final ridge = 1 - (2 * n - 1).abs();
        if (ridge > 0.7) return _band(cfg.vein!, (ridge - 0.7) / 0.3 * l + .4);
        l *= 0.66; // crosta escura
      case CelestialBody.earth:
        return _earthColor(cfg, u, v, l);
      case CelestialBody.moon:
        l = (l + _craters(u, v)).clamp(0, 1);
      case CelestialBody.sun:
      case CelestialBody.portal:
        break;
    }
    return _band(ramp, l);
  }

  Color _earthColor(_Cfg cfg, double u, double v, double l) {
    final cloud = _fbm((u + 1) * 4.4 - seed, (v + 1) * 4.4, seed + 9, 3);
    if (cloud > 0.64) return _band(cfg.cloud!, l.clamp(0.5, 1));
    final land = _fbm((u + 1) * 2.7 + seed, (v + 1) * 2.7, seed, 4);
    // ramp base do earth = oceano.
    return land > 0.5 ? _band(cfg.land!, l) : _band(cfg.ramp, l);
  }

  /// Portal = vortex neon: horizonte de eventos escuro no centro, disco em
  /// espiral alternando magenta<->ciano (torcido pelo raio, quantizado em
  /// degraus pixel), anel quente logo fora do nucleo e aro ciano crisp.
  Color _portalColor(_Cfg cfg, double u, double v, double d2) {
    final cyan = cfg.ringColor!;
    final magenta = cfg.ramp[3];
    final rr = math.sqrt(d2);
    final ang = math.atan2(v, u);

    // Horizonte de eventos: nucleo quase preto clareando levemente pra fora.
    if (rr < 0.30) {
      return Color.lerp(cfg.ramp[0], cfg.ramp[1], rr / 0.30)!;
    }
    // Aro externo neon crisp.
    if (rr > 0.90) return Color.lerp(cyan, const Color(0xFFFFFFFF), 0.25)!;

    // Espiral: faixas magenta<->ciano torcidas pelo raio, em degraus pixel.
    final swirl = ang + rr * 7.0;
    final band = (0.5 + 0.5 * math.sin(swirl * 3)).clamp(0.0, 1.0);
    final q = (band * 3).round() / 3;
    var c = Color.lerp(magenta, cyan, q)!;

    // Anel quente logo fora do horizonte; profundidade nas bordas externas.
    final lit = (1 - (rr - 0.30) / 0.60).clamp(0.0, 1.0);
    if (rr < 0.42) {
      c = Color.lerp(c, const Color(0xFFFFFFFF), 0.5 * lit)!;
    } else {
      c = Color.lerp(c, cfg.ramp[1], (1 - lit) * 0.35)!;
    }
    return c;
  }

  /// Crateras deterministicas: pit escuro + borda clara.
  double _craters(double u, double v) {
    var acc = 0.0;
    final rng = math.Random(seed);
    for (var i = 0; i < 9; i++) {
      final cx = rng.nextDouble() * 1.7 - 0.85;
      final cy = rng.nextDouble() * 1.7 - 0.85;
      final cr = 0.09 + rng.nextDouble() * 0.14;
      final dist = math.sqrt((u - cx) * (u - cx) + (v - cy) * (v - cy));
      if (dist < cr) {
        acc -= 0.3 * (1 - dist / cr);
      } else if (dist < cr * 1.3) {
        acc += 0.18;
      }
    }
    return acc;
  }

  /// Corona do sol: glow radial + dois conjuntos de raios (8 longos + 8
  /// curtos intercalados) em blocos pixel, decaindo com o raio e fadando
  /// no espaco. Desenhada fora do disco (o nucleo emissivo cobre o miolo).
  void _paintSunCorona(
    int grid,
    void Function(int, int, Color) drawCell,
    double Function(int) nx,
    double Function(int) ny,
    List<Color> ramp,
  ) {
    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        final u = nx(gx);
        final v = ny(gy);
        final d2 = u * u + v * v;
        // Dentro do nucleo o corpo desenha por cima — pula (com leve overlap).
        if (d2 <= 0.86 * 0.86 || d2 > 3.0) continue;
        final r = math.sqrt(d2);
        final ang = math.atan2(v, u);

        // Glow difuso colado ao disco.
        final glow = ((1.25 - r) / 0.45).clamp(0.0, 1.0);
        // 8 raios longos + 8 curtos defasados de pi/8.
        final longRay = math.pow(math.max(0.0, math.cos(ang * 8)), 6)
            .toDouble();
        final shortRay =
            math.pow(math.max(0.0, math.cos(ang * 8 + math.pi / 8)), 8)
                .toDouble();
        final longFall = ((1.55 - r) / 0.55).clamp(0.0, 1.0);
        final shortFall = ((1.18 - r) / 0.32).clamp(0.0, 1.0);

        final inten =
            (glow * glow * 0.5 +
                    longRay * longFall * 0.95 +
                    shortRay * shortFall * 0.7)
                .clamp(0.0, 1.0);
        if (inten < 0.14) continue;

        final color = _band(ramp, (inten * 0.7 + 0.3).clamp(0.0, 1.0));
        // Alpha quantizado em degraus pra leitura pixel (sem rampa lisa).
        final a = ((inten * 4).ceil() / 4).clamp(0.25, 1.0);
        drawCell(gx, gy, color.withValues(alpha: a));
      }
    }
  }

  /// Anel eliptico (annulus) de saturno, metade [back] ou frente.
  void _paintRing(
    int grid,
    void Function(int, int, Color) drawCell,
    double Function(int) nx,
    double Function(int) ny,
    Color ringColor, {
    required bool back,
  }) {
    const tilt = 0.36;
    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        final u = nx(gx);
        final v = ny(gy);
        if ((v < 0) != back) continue;
        // Coordenada radial eliptica (y "esticado" por 1/tilt).
        final er = math.sqrt(u * u + (v / tilt) * (v / tilt));
        if (er < 1.12 || er > 1.62) continue;
        // Brilho do anel: pontas (|u| grande) mais claras + 2 sub-faixas.
        final t = (er - 1.12) / 0.5;
        final lit = (t < 0.5 ? 0.55 : 0.95) * (0.6 + 0.4 * u.abs());
        drawCell(
          gx,
          gy,
          Color.lerp(ringColor, Colors.white, lit.clamp(0.0, 1.0) * 0.5)!,
        );
      }
    }
  }

  /// Mapeia 0..1 num degrau da rampa (banda pixel).
  Color _band(List<Color> ramp, double l) {
    final i = (l.clamp(0.0, 1.0) * (ramp.length - 1)).round();
    return ramp[i.clamp(0, ramp.length - 1)];
  }

  // ---- configuracao por corpo ----
  _Cfg _configFor(CelestialBody b) {
    switch (b) {
      case CelestialBody.saturn:
        // Gigante gasoso violeta neon + anel ciano (alto contraste synthwave).
        return const _Cfg(
          ramp: [
            Color(0xFF2A0E3F),
            Color(0xFF53219E),
            Color(0xFF8A3FD6),
            Color(0xFFB36CF0),
            Color(0xFFE6C2FF),
          ],
          outline: Color(0xFF160726),
          ringColor: Color(0xFF36E0FF),
        );
      case CelestialBody.ice:
        // Mundo gelado em ciano eletrico vivido.
        return const _Cfg(
          ramp: [
            Color(0xFF06283F),
            Color(0xFF0A5A88),
            Color(0xFF18A8C9),
            Color(0xFF5FE0F0),
            Color(0xFFD6FBFF),
          ],
          outline: Color(0xFF041A2C),
        );
      case CelestialBody.lava:
        // Crosta escura avermelhada + veias de lava em laranja/amarelo quente.
        return const _Cfg(
          ramp: [
            Color(0xFF1A0606),
            Color(0xFF3A1010),
            Color(0xFF5E1C18),
            Color(0xFF822A20),
            Color(0xFFA83A28),
          ],
          outline: Color(0xFF0C0303),
          vein: [
            Color(0xFFC21A0A),
            Color(0xFFFF4D1E),
            Color(0xFFFF9A3E),
            Color(0xFFFFE89A),
          ],
        );
      case CelestialBody.earth:
        // Terra mantida (oceano/continente/nuvem) — so mais saturada/viva.
        return const _Cfg(
          ramp: [
            Color(0xFF03203F),
            Color(0xFF0A4E8A),
            Color(0xFF1E7AD0),
            Color(0xFF4FB0F0),
            Color(0xFFBFEAFF),
          ],
          outline: Color(0xFF021026),
          land: [
            Color(0xFF0A4A1F),
            Color(0xFF128A34),
            Color(0xFF1EC04E),
            Color(0xFF5FE87E),
            Color(0xFFCDFFB0),
          ],
          cloud: [
            Color(0xFFC2D6E2),
            Color(0xFFE0EEF6),
            Color(0xFFF6FCFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
          ],
        );
      case CelestialBody.sun:
        return const _Cfg(
          ramp: [
            Color(0xFFC24A0A),
            Color(0xFFE87A14),
            Color(0xFFF6A82E),
            Color(0xFFFBD24A),
            Color(0xFFFFF6CC),
          ],
          outline: Color(0xFFC24A0A),
        );
      case CelestialBody.moon:
        return const _Cfg(
          ramp: [
            Color(0xFF262630),
            Color(0xFF43434E),
            Color(0xFF6E6E7A),
            Color(0xFF9A9CA8),
            Color(0xFFCFD2DC),
          ],
          outline: Color(0xFF18181F),
        );
      case CelestialBody.portal:
        // Vortex: nucleo escuro (ramp[0/1]), magenta neon (ramp[3]) na
        // espiral, ciano (ringColor) no aro. ramp[2/4] dao apoio de cor.
        return const _Cfg(
          ramp: [
            Color(0xFF05010F),
            Color(0xFF2A0A4A),
            Color(0xFF7A1E9E),
            Color(0xFFE83CC8),
            Color(0xFFFF7AE6),
          ],
          outline: Color(0xFF05010F),
          ringColor: Color(0xFF36E0FF),
        );
    }
  }

  // ---- noise ----
  static double _hash(int x, int y, int seed) {
    var h = x * 374761393 + y * 668265263 + seed * 1274126177;
    h = (h ^ (h >> 13)) * 1274126177;
    return ((h ^ (h >> 16)) & 0x7fffffff) / 0x7fffffff;
  }

  static double _valueNoise(double x, double y, int seed) {
    final xi = x.floor();
    final yi = y.floor();
    final xf = x - xi;
    final yf = y - yi;
    final u = xf * xf * (3 - 2 * xf);
    final v = yf * yf * (3 - 2 * yf);
    final a = _hash(xi, yi, seed);
    final b = _hash(xi + 1, yi, seed);
    final c = _hash(xi, yi + 1, seed);
    final d = _hash(xi + 1, yi + 1, seed);
    return _mix(_mix(a, b, u), _mix(c, d, u), v);
  }

  static double _fbm(double x, double y, int seed, int oct) {
    var sum = 0.0;
    var amp = 0.5;
    var freq = 1.0;
    for (var i = 0; i < oct; i++) {
      sum += _valueNoise(x * freq, y * freq, seed + i) * amp;
      freq *= 2;
      amp *= 0.5;
    }
    return sum.clamp(0.0, 1.0);
  }

  static double _mix(double a, double b, double t) => a + (b - a) * t;

  static List<double> _norm3(double x, double y, double z) {
    final m = math.sqrt(x * x + y * y + z * z);
    return [x / m, y / m, z / m];
  }

  @override
  bool shouldRepaint(CelestialPainter old) =>
      old.body != body || old.seed != seed;
}

/// Config visual de um corpo: rampa base + outline + extras por tipo.
class _Cfg {
  const _Cfg({
    required this.ramp,
    required this.outline,
    this.ringColor,
    this.vein,
    this.land,
    this.cloud,
  });

  final List<Color> ramp;
  final Color outline;
  final Color? ringColor;
  final List<Color>? vein;
  final List<Color>? land;
  final List<Color>? cloud;
}
