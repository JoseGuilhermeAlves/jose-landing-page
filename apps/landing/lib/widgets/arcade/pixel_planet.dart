import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tipo de planeta — define o tratamento de superficie.
enum PlanetKind { gasGiant, ice, lava, terran, moon, sun }

/// Planeta pixel-art de alta fidelidade (mira sprites tipo cosmos-3): corpo
/// como grid de blocos quadrados, esfera por lambert + smoothstep, paleta
/// de 5 degraus, outline escuro, realce especular e dithering em xadrez no
/// terminator. Cada [PlanetKind] tem um padrao proprio (bandas onduladas,
/// crateras, veias de lava por noise, continentes, calotas). Anel opcional.
/// Sem antialias — pixel perfect; glow e bloom (blur) em camada separada.
class PixelPlanetPainter extends CustomPainter {
  PixelPlanetPainter({
    required this.kind,
    required this.palette,
    required this.seed,
    this.ringTilt,
    this.glow = false,
  }) : _cell = Paint()..isAntiAlias = false;

  /// [shadow, mid-dark, mid, mid-light, highlight].
  final List<Color> palette;
  final PlanetKind kind;
  final int seed;

  /// Se nao-nulo, desenha anel saturno-style (0 horizontal .. 1 vertical).
  final double? ringTilt;

  /// Bloom difuso atras (so decorativo; nunca borra as formas).
  final bool glow;

  final Paint _cell;

  /// Lado-alvo do pixel (px). Menor = mais detalhe (sprite mais fino).
  static const double _targetPx = 3.4;

  static final _light = _norm3(-0.55, -0.6, 0.58);

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final ringMargin = ringTilt != null ? 0.22 : 0.0;
    final radius = (shortest / 2) * (1 - ringMargin);
    final center = Offset(size.width / 2, size.height / 2);

    if (glow) {
      final g = Paint()
        ..color = palette[3].withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(center, radius * 1.05, g);
    }

    if (ringTilt != null) _paintRingBack(canvas, center, radius, ringTilt!);
    _paintBody(canvas, center, radius);
    if (ringTilt != null) _paintRingFront(canvas, center, radius, ringTilt!);
  }

  void _paintBody(Canvas canvas, Offset center, double radius) {
    final grid = ((radius * 2) / _targetPx).round().clamp(18, 44);
    final px = (radius * 2) / grid;
    final origin = Offset(center.dx - radius, center.dy - radius);
    final edge = 1 - (1.8 / grid);

    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        final u = ((gx + 0.5) / grid) * 2 - 1;
        final v = ((gy + 0.5) / grid) * 2 - 1;
        final d2 = u * u + v * v;
        if (d2 > 1) continue;

        Color color;
        if (d2 > edge) {
          color = palette[0]; // outline
        } else {
          color = _surface(u, v, d2, gx, gy);
        }
        _cell.color = color;
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
    }
  }

  /// Cor de uma celula de superficie conforme o tipo.
  Color _surface(double u, double v, double d2, int gx, int gy) {
    final nz = math.sqrt(1 - d2);

    // Sol e emissivo: brilho radial + flares, sem lado escuro.
    if (kind == PlanetKind.sun) {
      final rad = 1 - d2; // centro mais quente
      final flare = _fbm((u + 1) * 2.2, (v + 1) * 2.2, seed, 3);
      var l = (rad * 0.7 + flare * 0.5).clamp(0.0, 1.0);
      l = l * l * (3 - 2 * l);
      return _q(l, gx, gy);
    }

    // Lambert pros demais.
    var l = (u * _light[0] + v * _light[1] + nz * _light[2]).clamp(0.0, 1.0);
    l = l * l * (3 - 2 * l);

    switch (kind) {
      case PlanetKind.gasGiant:
        final band = math.sin(v * 7.5 + math.sin(u * 2.3) * 1.0);
        l = (l + band * 0.17).clamp(0.0, 1.0);
      case PlanetKind.ice:
        final band = math.sin(v * 9 + math.sin(u * 1.8) * 0.6);
        l = (l + band * 0.10).clamp(0.0, 1.0);
        if (v < -0.55 || v > 0.6) l = (l + 0.25).clamp(0.0, 1.0); // calotas
      case PlanetKind.lava:
        // Veias quentes: ridged noise -> linhas brilhantes.
        final n = _fbm((u + 1) * 3.0, (v + 1) * 3.0, seed, 4);
        final ridge = 1 - (2 * n - 1).abs();
        if (ridge > 0.72) {
          return _lerp(palette[4], Colors.white, 0.3); // veia incandescente
        }
        l = (l * 0.7).clamp(0.0, 1.0); // crosta escura
      case PlanetKind.terran:
        // Continentes: noise decide terra/oceano; segundo noise = nuvens.
        final land = _fbm((u + 1) * 2.6 + seed, (v + 1) * 2.6, seed, 4);
        final cloud = _fbm((u + 1) * 4 - seed, (v + 1) * 4, seed + 7, 3);
        if (cloud > 0.66) return _q(l.clamp(0.55, 1), gx, gy); // nuvem clara
        if (land > 0.52) {
          // terra: usa mid/mid-light (idx 2..3) modulado por l
          final idx = l > 0.6 ? 3 : 2;
          return palette[idx];
        }
        // oceano: shadow/mid-dark (idx 0..1)
        return palette[l > 0.55 ? 1 : 0];
      case PlanetKind.moon:
        // Crateras: pit escuro com borda clara, deterministico.
        final c = _craterField(u, v);
        l = (l + c).clamp(0.0, 1.0);
      case PlanetKind.sun:
        break; // tratado acima
    }

    var color = _q(l, gx, gy);
    if (l > 0.95) color = _lerp(palette[4], Colors.white, 0.6); // especular
    return color;
  }

  /// Quantiza 0..1 em 5 degraus + dithering xadrez no meio do degrau.
  Color _q(double l, int gx, int gy) {
    final f = l.clamp(0.0, 1.0) * 4;
    var idx = f.floor();
    final frac = f - idx;
    if (frac > 0.34 && frac < 0.66 && idx < 4 && (gx + gy).isEven) idx += 1;
    return palette[idx.clamp(0, 4)];
  }

  /// Campo de crateras: soma de poços circulares com borda clara.
  double _craterField(double u, double v) {
    var acc = 0.0;
    final rng = math.Random(seed);
    for (var i = 0; i < 7; i++) {
      final cx = rng.nextDouble() * 1.6 - 0.8;
      final cy = rng.nextDouble() * 1.6 - 0.8;
      final cr = 0.12 + rng.nextDouble() * 0.18;
      final dist = math.sqrt((u - cx) * (u - cx) + (v - cy) * (v - cy));
      if (dist < cr) {
        acc -= 0.35 * (1 - dist / cr); // pit escuro
      } else if (dist < cr * 1.25) {
        acc += 0.22; // borda clara
      }
    }
    return acc;
  }

  void _paintRingBack(Canvas c, Offset center, double r, double tilt) =>
      _paintRing(c, center, r, tilt, front: false);
  void _paintRingFront(Canvas c, Offset center, double r, double tilt) =>
      _paintRing(c, center, r, tilt, front: true);

  void _paintRing(
    Canvas canvas,
    Offset center,
    double bodyRadius,
    double tilt, {
    required bool front,
  }) {
    final rx = bodyRadius * 1.85;
    final ry = math.max(bodyRadius * 0.34, bodyRadius * tilt * 1.85);
    final block = math.max(2.5, bodyRadius * 0.1);
    const steps = 64;
    for (var i = 0; i < steps; i++) {
      final a = (i / steps) * math.pi * 2;
      // back = metade superior (sin<0), front = inferior (sin>0).
      if ((math.sin(a) > 0) != front) continue;
      final x = center.dx + math.cos(a) * rx;
      final y = center.dy + math.sin(a) * ry;
      final bright = math.cos(a).abs() > 0.6;
      _cell.color = (bright ? palette[4] : palette[3]).withValues(alpha: 0.92);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: block, height: block),
        _cell,
      );
    }
  }

  // ---- noise utilitario (value noise + fbm, deterministico) ----
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
    final cc = _hash(xi, yi + 1, seed);
    final d = _hash(xi + 1, yi + 1, seed);
    return _mix(_mix(a, b, u), _mix(cc, d, u), v);
  }

  static double _fbm(double x, double y, int seed, int octaves) {
    var sum = 0.0;
    var amp = 0.5;
    var freq = 1.0;
    for (var i = 0; i < octaves; i++) {
      sum += _valueNoise(x * freq, y * freq, seed + i) * amp;
      freq *= 2;
      amp *= 0.5;
    }
    return sum.clamp(0.0, 1.0);
  }

  static double _mix(double a, double b, double t) => a + (b - a) * t;
  Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  static List<double> _norm3(double x, double y, double z) {
    final m = math.sqrt(x * x + y * y + z * z);
    return [x / m, y / m, z / m];
  }

  @override
  bool shouldRepaint(covariant PixelPlanetPainter old) =>
      old.kind != kind ||
      old.seed != seed ||
      old.ringTilt != ringTilt ||
      old.glow != glow;
}
