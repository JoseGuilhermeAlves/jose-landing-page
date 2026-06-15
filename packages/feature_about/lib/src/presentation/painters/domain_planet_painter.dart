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

/// Planeta inline pra cada no da constelacao, em estetica 8/16-bit. O
/// corpo e desenhado como um grid de "pixels" quadrados (lado ~5px,
/// constante independente do tamanho do no, pra leitura nitida). O
/// sombreamento usa a normal da esfera contra a luz (lambert), quantizado
/// em 5 degraus da paleta; a silhueta ganha um outline escuro de 1 pixel e
/// um realce especular no ponto de luz. Sem antialias. Quando [isActive],
/// um glow CRT (bloom blur, camada separada) pulsa atras.
class DomainPlanetPainter extends CustomPainter {
  DomainPlanetPainter({
    required this.spec,
    required this.isActive,
    required this.pulse,
  }) : _cell = Paint()..isAntiAlias = false;

  final DomainPlanetSpec spec;
  final bool isActive;

  /// 0..1 pra modular pulse leve no glow quando ativo.
  final double pulse;

  final Paint _cell;

  /// Lado-alvo do pixel em px logicos — define a resolucao do grid.
  static const double _targetPx = 5;

  /// Direcao da luz (upper-left em direcao ao observador), normalizada.
  static final _light = _norm3(-0.5, -0.55, 0.68);

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final ringMargin = spec.ring != null ? 0.18 : 0.0;
    final radius = (shortest / 2) * (1 - ringMargin);
    final center = Offset(size.width / 2, size.height / 2);

    if (isActive) {
      final glow = Paint()
        ..color = spec.palette[3].withValues(alpha: 0.4 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius + 8, glow);
    }

    if (spec.ring != null) {
      _paintRing(canvas, center, radius, spec.ring!);
    }

    // Grid adaptativo: pixel ~constante (~5px) seja o no grande ou pequeno.
    final grid = ((radius * 2) / _targetPx).round().clamp(11, 20);
    _paintPixelBody(canvas, center, radius, grid);
  }

  void _paintPixelBody(Canvas canvas, Offset center, double radius, int grid) {
    final px = (radius * 2) / grid;
    final origin = Offset(center.dx - radius, center.dy - radius);
    final rng = math.Random(spec.seed);

    final speckle = <int>{};
    if (spec.pattern == DomainPlanetPattern.speckled) {
      final count = (grid * grid * 0.12).round();
      for (var i = 0; i < count; i++) {
        speckle.add(rng.nextInt(grid * grid));
      }
    }

    // Distancia normalizada acima da qual a celula e tratada como outline.
    final edgeBand = 1 - (2.2 / grid);

    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        final u = ((gx + 0.5) / grid) * 2 - 1;
        final v = ((gy + 0.5) / grid) * 2 - 1;
        final d2 = u * u + v * v;
        if (d2 > 1) continue; // silhueta pixelada

        Color color;
        if (d2 > edgeBand) {
          // Outline: borda escura de 1 pixel pra recortar do fundo.
          color = spec.palette[0];
        } else {
          final nz = math.sqrt(1 - d2);
          var bright = u * _light[0] + v * _light[1] + nz * _light[2];
          // Contraste: empurra meios-tons (gamma <1 clareia, mas usamos
          // uma curva em S leve pra separar luz/sombra).
          bright = bright.clamp(0.0, 1.0);
          bright = bright * bright * (3 - 2 * bright); // smoothstep

          var idx = (bright * 4.999).floor().clamp(0, 4);
          idx = _applyPattern(idx, gx, gy, v, speckle, grid);
          color = spec.palette[idx];

          // Especular: pixel mais alinhado a luz vira branco-quente.
          if (bright > 0.93 && idx >= 3) {
            color = Color.lerp(spec.palette[4], Colors.white, 0.7)!;
          }
        }

        _cell.color = color;
        canvas.drawRect(
          Rect.fromLTWH(
            origin.dx + gx * px,
            origin.dy + gy * px,
            px + 0.6,
            px + 0.6,
          ),
          _cell,
        );
      }
    }
  }

  int _applyPattern(
    int idx,
    int gx,
    int gy,
    double v,
    Set<int> speckle,
    int grid,
  ) {
    switch (spec.pattern) {
      case DomainPlanetPattern.bands:
        // Faixas horizontais a cada 2 linhas escurecem um degrau.
        if (gy.isEven) return (idx - 1).clamp(0, 4);
        return idx;
      case DomainPlanetPattern.speckled:
        if (speckle.contains(gy * grid + gx)) return (idx + 1).clamp(0, 4);
        return idx;
      case DomainPlanetPattern.hemispheres:
        if (v > 0.12) return (idx - 1).clamp(0, 4);
        if (v < -0.55) return 4; // calota polar
        return idx;
    }
  }

  /// Anel saturno-style pixelado: blocos quadrados numa elipse maior que o
  /// corpo. Tilt controla a altura da elipse.
  void _paintRing(
    Canvas canvas,
    Offset center,
    double bodyRadius,
    double tilt,
  ) {
    final rx = bodyRadius * 1.6;
    final ry = math.max(bodyRadius * 0.3, bodyRadius * tilt * 1.6);
    final block = math.max(2.5, bodyRadius * 0.13);
    const steps = 44;

    for (var i = 0; i < steps; i++) {
      final a = (i / steps) * math.pi * 2;
      final x = center.dx + math.cos(a) * rx;
      final y = center.dy + math.sin(a) * ry;
      final bright = math.cos(a).abs() > 0.7;
      _cell.color = (bright ? spec.palette[4] : spec.palette[3]).withValues(
        alpha: 0.9,
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
