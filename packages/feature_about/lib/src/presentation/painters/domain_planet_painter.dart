import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Padrao de superficie do planeta — espelha
/// `package:animations` PlanetPattern sem dependencia direta.
enum DomainPlanetPattern { bands, speckled, hemispheres }

/// Spec imutavel pra cada dominio: paleta 5 cores (shadow ->
/// highlight), pattern, ring opcional. Cada dominio recebe uma
/// especificacao unica no DomainPlanetCatalog em
/// `domain_constellation.dart`.
@immutable
class DomainPlanetSpec {
  const DomainPlanetSpec({
    required this.palette,
    required this.pattern,
    this.ring,
    this.seed = 0,
  });

  /// 5 cores [shadow, mid-dark, mid, mid-light, highlight].
  final List<Color> palette;
  final DomainPlanetPattern pattern;

  /// Tilt anel relativo (0 = horizontal, 1 = vertical fino). Color
  /// derivado de `palette[3]`.
  final double? ring;

  final int seed;
}

/// Planeta pixel-art (estilo sprite 16-bit) pra cada no da constelacao.
/// Grid de blocos FIXO (chunky, independente do tamanho), esfera por
/// lambert; bands gasosas ondulam pela latitude, speckled vira crateras
/// (pit escuro + borda clara), hemispheres separa calota. Dithering em
/// xadrez no terminator suaviza os degraus sem perder o look pixel.
/// Outline escuro recorta a silhueta e um cluster especular marca a luz.
/// Sem antialias; glow ativo e bloom (blur) em camada separada.
class DomainPlanetPainter extends CustomPainter {
  DomainPlanetPainter({
    required this.spec,
    required this.isActive,
    required this.pulse,
  }) : _cell = Paint()..isAntiAlias = false;

  final DomainPlanetSpec spec;
  final bool isActive;
  final double pulse;
  final Paint _cell;

  /// Resolucao fixa do corpo — chunky tipo sprite (nao adaptativa, pra
  /// nunca ficar fina/muddy).
  static const int _grid = 18;

  static final _light = _norm3(-0.55, -0.6, 0.58);

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final ringMargin = spec.ring != null ? 0.2 : 0.0;
    final radius = (shortest / 2) * (1 - ringMargin);
    final center = Offset(size.width / 2, size.height / 2);

    if (isActive) {
      final glow = Paint()
        ..color = spec.palette[3].withValues(alpha: 0.45 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(center, radius + 8, glow);
    }

    if (spec.ring != null) _paintRing(canvas, center, radius, spec.ring!);

    _paintBody(canvas, center, radius);
  }

  void _paintBody(Canvas canvas, Offset center, double radius) {
    final px = (radius * 2) / _grid;
    final origin = Offset(center.dx - radius, center.dy - radius);
    final rng = math.Random(spec.seed);

    // Crateras pre-sorteadas (so no pattern speckled): celula do pit.
    final craters = <int>{};
    if (spec.pattern == DomainPlanetPattern.speckled) {
      final n = (_grid * _grid * 0.06).round();
      for (var i = 0; i < n; i++) {
        craters.add(rng.nextInt(_grid * _grid));
      }
    }

    const edgeBand = 1 - (2.0 / _grid);

    for (var gy = 0; gy < _grid; gy++) {
      for (var gx = 0; gx < _grid; gx++) {
        final u = ((gx + 0.5) / _grid) * 2 - 1;
        final v = ((gy + 0.5) / _grid) * 2 - 1;
        final d2 = u * u + v * v;
        if (d2 > 1) continue;

        Color color;
        if (d2 > edgeBand) {
          color = spec.palette[0]; // outline
        } else {
          final nz = math.sqrt(1 - d2);
          // Lambert + smoothstep pra separar luz/sombra.
          var l = (u * _light[0] + v * _light[1] + nz * _light[2]).clamp(
            0.0,
            1.0,
          );
          l = l * l * (3 - 2 * l);

          // Pattern modula o nivel ANTES de quantizar.
          l = _applyPattern(l, gx, gy, u, v, craters);

          color = _quantize(l, gx, gy);

          // Cluster especular: ponto mais alto da luz vira branco-quente.
          if (l > 0.96) color = Color.lerp(spec.palette[4], Colors.white, .7)!;
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

  /// Quantiza nivel 0..1 em 5 degraus de paleta, com dithering em xadrez
  /// na fronteira entre degraus (suaviza sem perder pixel).
  Color _quantize(double l, int gx, int gy) {
    final f = (l.clamp(0.0, 1.0)) * 4;
    var idx = f.floor();
    final frac = f - idx;
    // Dither: na zona ambigua, alterna entre idx e idx+1 por xadrez.
    if (frac > 0.34 && frac < 0.66 && idx < 4 && (gx + gy).isEven) idx += 1;
    return spec.palette[idx.clamp(0, 4)];
  }

  double _applyPattern(
    double l,
    int gx,
    int gy,
    double u,
    double v,
    Set<int> craters,
  ) {
    switch (spec.pattern) {
      case DomainPlanetPattern.bands:
        // Bandas gasosas: faixas de latitude que ondulam com a longitude
        // (sin de v deslocado por sin de u) — leitura "Jupiter".
        final band = math.sin(v * 7.2 + math.sin(u * 2.4) * 0.9);
        return l + band * 0.16;
      case DomainPlanetPattern.speckled:
        // Cratera: pit escuro; a celula acima-esquerda vira borda clara.
        if (craters.contains(gy * _grid + gx)) return (l - 0.4).clamp(0, 1);
        if (craters.contains((gy + 1) * _grid + (gx + 1))) {
          return (l + 0.3).clamp(0, 1);
        }
        return l;
      case DomainPlanetPattern.hemispheres:
        if (v < -0.5) return (l + 0.25).clamp(0, 1); // calota polar clara
        if (v > 0.15) return (l - 0.2).clamp(0, 1); // hemisferio inferior
        return l;
    }
  }

  /// Anel saturno-style pixelado: blocos quadrados numa elipse maior que o
  /// corpo, sem AA. Pontas mais brilhantes.
  void _paintRing(
    Canvas canvas,
    Offset center,
    double bodyRadius,
    double tilt,
  ) {
    final rx = bodyRadius * 1.7;
    final ry = math.max(bodyRadius * 0.3, bodyRadius * tilt * 1.7);
    final block = math.max(2.5, bodyRadius * 0.12);
    const steps = 52;
    for (var i = 0; i < steps; i++) {
      final a = (i / steps) * math.pi * 2;
      final x = center.dx + math.cos(a) * rx;
      final y = center.dy + math.sin(a) * ry;
      final bright = math.cos(a).abs() > 0.7;
      _cell.color = (bright ? spec.palette[4] : spec.palette[3]).withValues(
        alpha: 0.92,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: block, height: block),
        _cell,
      );
    }
  }

  static List<double> _norm3(double x, double y, double z) {
    final m = math.sqrt(x * x + y * y + z * z);
    return [x / m, y / m, z / m];
  }

  @override
  bool shouldRepaint(covariant DomainPlanetPainter old) =>
      old.isActive != isActive || old.pulse != pulse || old.spec != spec;
}
