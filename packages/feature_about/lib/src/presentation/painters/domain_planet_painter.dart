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

/// Planeta inline pra cada no da constelacao, em estetica 8/16-bit: o
/// corpo e desenhado como um grid de "pixels" quadrados, com o
/// sombreamento de esfera (normal · luz) quantizado nos 5 degraus da
/// paleta — sem gradiente suave, sem antialias. Patterns (bands,
/// speckled, hemispheres) e anel tambem viram blocos. Quando [isActive],
/// ganha um glow CRT (blur) e o pulse modula a intensidade.
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

  /// Resolucao do grid de pixels do corpo (lado a lado). ~14 da leitura
  /// 16-bit sem virar mosaico grosseiro.
  static const int _grid = 14;

  /// Direcao da luz (upper-left em direcao ao observador), normalizada.
  static final _light = _norm3(-0.5, -0.55, 0.68);

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final ringMargin = spec.ring != null ? 0.18 : 0.0;
    final radius = (shortest / 2) * (1 - ringMargin);
    final center = Offset(size.width / 2, size.height / 2);

    // Glow externo quando ativo — bloom CRT difuso.
    if (isActive) {
      final glow = Paint()
        ..color = spec.palette[3].withValues(alpha: 0.35 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(center, radius + 8, glow);
    }

    // Anel atras do corpo (blocos).
    if (spec.ring != null) {
      _paintRing(canvas, center, radius, spec.ring!);
    }

    _paintPixelBody(canvas, center, radius);
  }

  /// Corpo pixelado: varre um grid quadrado; cada celula cujo centro cai
  /// dentro do disco vira um pixel colorido pelo degrau de iluminacao.
  void _paintPixelBody(Canvas canvas, Offset center, double radius) {
    final px = (radius * 2) / _grid;
    final origin = Offset(center.dx - radius, center.dy - radius);
    final rng = math.Random(spec.seed);

    // Pre-sorteia quais celulas recebem "speckle" pra ser determinista.
    final speckle = <int>{};
    if (spec.pattern == DomainPlanetPattern.speckled) {
      final count = (_grid * _grid * 0.12).round();
      for (var i = 0; i < count; i++) {
        speckle.add(rng.nextInt(_grid * _grid));
      }
    }

    for (var gy = 0; gy < _grid; gy++) {
      for (var gx = 0; gx < _grid; gx++) {
        // Centro da celula em coords normalizadas -1..1.
        final u = ((gx + 0.5) / _grid) * 2 - 1;
        final v = ((gy + 0.5) / _grid) * 2 - 1;
        final d2 = u * u + v * v;
        if (d2 > 1) continue; // fora do disco — silhueta pixelada

        // Normal da esfera no ponto + iluminacao lambert.
        final nz = math.sqrt(1 - d2);
        var bright = u * _light[0] + v * _light[1] + nz * _light[2];
        bright = bright.clamp(0.0, 1.0);

        // Quantiza em 5 degraus -> indice de paleta (0 shadow..4 light).
        var idx = (bright * 4.999).floor().clamp(0, 4);

        // Termina (borda) sempre puxa pro shadow pra dar volume.
        if (d2 > 0.86) idx = (idx - 1).clamp(0, 4);

        idx = _applyPattern(idx, gx, gy, u, v, speckle);

        _cell.color = spec.palette[idx];
        canvas.drawRect(
          Rect.fromLTWH(
            origin.dx + gx * px,
            origin.dy + gy * px,
            // +0.6 evita fios de fundo entre celulas por arredondamento.
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
    double u,
    double v,
    Set<int> speckle,
  ) {
    switch (spec.pattern) {
      case DomainPlanetPattern.bands:
        // Faixas horizontais: linhas pares escurecem um degrau.
        if (gy.isEven) return (idx - 1).clamp(0, 4);
        return idx;
      case DomainPlanetPattern.speckled:
        if (speckle.contains(gy * _grid + gx)) {
          return (idx + 1).clamp(0, 4);
        }
        return idx;
      case DomainPlanetPattern.hemispheres:
        // Hemisferio inferior escurece; calota polar (topo) clareia.
        if (v > 0.1) return (idx - 1).clamp(0, 4);
        if (v < -0.55) return 4;
        return idx;
    }
  }

  /// Anel saturno-style pixelado: blocos quadrados distribuidos numa
  /// elipse maior que o corpo. Tilt controla a altura da elipse.
  void _paintRing(
    Canvas canvas,
    Offset center,
    double bodyRadius,
    double tilt,
  ) {
    final rx = bodyRadius * 1.6;
    final ry = math.max(bodyRadius * 0.32, bodyRadius * tilt * 1.6);
    final block = math.max(2.5, bodyRadius * 0.14);
    const steps = 40;

    for (var i = 0; i < steps; i++) {
      final a = (i / steps) * math.pi * 2;
      final x = center.dx + math.cos(a) * rx;
      final y = center.dy + math.sin(a) * ry;
      // Pontas (cos extremo) mais brilhantes; resto mid.
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
