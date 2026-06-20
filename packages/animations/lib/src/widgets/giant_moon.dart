import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lua majenta GIGANTE desenhada 100% em CustomPainter — mesma estetica e
/// tecnica pixel-art dos `CelestialPlanet`: grid de celulas quadradas sem
/// antialias, sombreamento de esfera (lambert + ambient, sem facetar),
/// outline de 1px por vizinhanca, e superficie detalhada por crateras
/// deterministicas (pit escuro + parede sombreada pela luz + borda elevada
/// clara) e "maria" (manchas escuras de baixa frequencia).
///
/// Pensada pra aparecer enorme num canto com so UM QUADRANTE visivel (o host
/// posiciona o centro fora da tela). Por isso a densidade de crateras e
/// alta: o detalhe precisa aguentar o close-up.
class GiantMoon extends StatelessWidget {
  const GiantMoon({this.seed = 42, super.key});

  /// Seed do campo de crateras/maria — varia o relevo sem mexer na paleta.
  final int seed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GiantMoonPainter(seed: seed),
      ),
    );
  }
}

/// Cratera deterministica em coords normalizadas (-1..1) relativas ao raio.
class _Crater {
  const _Crater(this.cx, this.cy, this.r);

  final double cx;
  final double cy;
  final double r;
}

/// Painter estatico (nao anima) da lua. O tipo decide silhueta, paleta e
/// relevo; tudo em blocos quadrados sem antialias (pixel-perfect).
class _GiantMoonPainter extends CustomPainter {
  _GiantMoonPainter({required this.seed}) : _cell = Paint()..isAntiAlias = false;

  final int seed;
  final Paint _cell;

  /// Lado-alvo do pixel (px) — fino o bastante pra silhueta redonda, mas
  /// generoso pra um disco gigante nao explodir o numero de celulas.
  static const double _targetPx = 5;
  static final List<double> _light = _norm3(-0.5, -0.6, 0.62);

  /// Rampa magenta NEON: sombra ultravioleta -> mid magenta saturado ->
  /// highlight rosa-quente quase branco. Mids puxados pro neon (alta croma)
  /// pra a lua brilhar, nao parecer rocha fosca.
  static const List<Color> _ramp = [
    Color(0xFF2A0036),
    Color(0xFF66008A),
    Color(0xFFB400E0), // neon magenta-violeta
    Color(0xFFF02CF0), // NEON MAGENTA solido
    Color(0xFFFF6CFF), // mid-light pink-neon
    Color(0xFFFFD6FF), // highlight blush
  ];
  static const Color _outline = Color(0xFF1A0026);

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    if (shortest <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (shortest / 2) * 0.98;
    final grid = (shortest / _targetPx).round().clamp(60, 170);
    final px = shortest / grid;
    final origin = Offset(center.dx - shortest / 2, center.dy - shortest / 2);
    final craters = _buildCraters(seed);

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

    double nx(int gx) => (origin.dx + (gx + .5) * px - center.dx) / radius;
    double ny(int gy) => (origin.dy + (gy + .5) * px - center.dy) / radius;
    bool inDisc(int gx, int gy) {
      final u = nx(gx);
      final v = ny(gy);
      return u * u + v * v <= 1;
    }

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
        if (edge) {
          drawCell(gx, gy, _outline);
          continue;
        }

        final nz = math.sqrt(1 - d2);
        // Ambient alto + ganho — neon brilha mesmo no lado sombreado.
        var l = (0.32 + 0.74 * (u * _light[0] + v * _light[1] + nz * _light[2]))
            .clamp(0.0, 1.0);
        // Maria: manchas escuras de baixa frequencia (mares lunares).
        final maria = _fbm((u + 1) * 1.8, (v + 1) * 1.8, seed, 4);
        if (maria > 0.6) l *= 0.72;
        // Crateras (relevo detalhado).
        l = (l + _crater(craters, u, v)).clamp(0.0, 1.0);
        drawCell(gx, gy, _band(_ramp, l));
      }
    }
  }

  /// Campo denso de crateras com tamanhos variados (bias pra pequenas via
  /// `r1*r2`), determinista por seed.
  static List<_Crater> _buildCraters(int seed) {
    final rng = math.Random(seed * 911 + 7);
    return List<_Crater>.generate(48, (_) {
      final cx = rng.nextDouble() * 1.9 - 0.95;
      final cy = rng.nextDouble() * 1.9 - 0.95;
      final r = 0.035 + rng.nextDouble() * rng.nextDouble() * 0.2;
      return _Crater(cx, cy, r);
    });
  }

  /// Contribuicao de relevo das crateras numa celula: pit escuro no centro,
  /// parede sombreada/iluminada conforme a luz, e borda elevada clara.
  double _crater(List<_Crater> craters, double u, double v) {
    var acc = 0.0;
    for (final c in craters) {
      final dx = u - c.cx;
      final dy = v - c.cy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < c.r) {
        // Floor escuro + parede 3D (lado virado pra luz clareia).
        acc -= 0.34 * (1 - dist / c.r);
        acc += (dx * _light[0] + dy * _light[1]) / c.r * 0.16;
      } else if (dist < c.r * 1.3) {
        // Borda elevada (ejecta) — anel claro fino.
        acc += 0.15 * (1 - (dist - c.r) / (c.r * 0.3));
      }
    }
    return acc;
  }

  /// Mapeia 0..1 num degrau da rampa (banda pixel).
  Color _band(List<Color> ramp, double l) {
    final i = (l.clamp(0.0, 1.0) * (ramp.length - 1)).round();
    return ramp[i.clamp(0, ramp.length - 1)];
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
  bool shouldRepaint(_GiantMoonPainter old) => old.seed != seed;
}
