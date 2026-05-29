import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Padrao de superficie do planeta — espelha
/// `package:animations` PlanetPattern sem dependencia direta.
enum DomainPlanetPattern { bands, speckled, hemispheres }

/// Spec imutavel pra cada dominio: paleta 5 cores (shadow ->
/// highlight), pattern, ring opcional. Cada dominio recebe uma
/// especificacao unica no [DomainPlanetCatalog] em
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

/// Planeta inline pra cada no da constelacao. Pintura leve em estilo
/// CosmosPlanet (gradient radial pra esfera, surface pattern,
/// rim/highlight), mas em painter dedicado pra evitar baixar o
/// CosmosField inteiro pra renderizar 5 corpos pequenos. Quando
/// [isActive] e true, ganha glow externo blur + escala maior.
class DomainPlanetPainter extends CustomPainter {
  DomainPlanetPainter({
    required this.spec,
    required this.isActive,
    required this.pulse,
  });

  final DomainPlanetSpec spec;
  final bool isActive;

  /// 0..1 pra modular pulse leve no glow quando ativo.
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final ringMargin = spec.ring != null ? 0.18 : 0.0;
    final radius = (shortest / 2) * (1 - ringMargin);
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Glow externo quando ativo — disco difuso brand.
    if (isActive) {
      final glow = Paint()
        ..color = spec.palette[2].withValues(alpha: 0.32 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(center, radius + 10, glow);
    }

    // 2. Ring (atras do corpo) — duas elipses concentricas
    // diferenciadas por tilt.
    if (spec.ring != null) {
      _paintRing(canvas, center, radius, spec.ring!);
    }

    // 3. Atmosfera — anel difuso fino ao redor do corpo.
    final atmosphere = Paint()
      ..color = spec.palette[3].withValues(alpha: 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius + 3, atmosphere);

    // 4. Corpo: gradient radial top-left para baixo-direita
    // (light source consistente com CosmosPainter).
    final bodyRect = Rect.fromCircle(center: center, radius: radius);
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 1.05,
        colors: [
          spec.palette[4],
          spec.palette[3],
          spec.palette[2],
          spec.palette[1],
          spec.palette[0],
        ],
        stops: const [0.0, 0.25, 0.55, 0.80, 1.0],
      ).createShader(bodyRect);
    canvas.drawCircle(center, radius, bodyPaint);

    // 5. Surface pattern — bands / speckled / hemispheres.
    canvas.save();
    canvas.clipPath(Path()..addOval(bodyRect));
    switch (spec.pattern) {
      case DomainPlanetPattern.bands:
        _paintBands(canvas, center, radius);
      case DomainPlanetPattern.speckled:
        _paintSpeckled(canvas, center, radius);
      case DomainPlanetPattern.hemispheres:
        _paintHemispheres(canvas, center, radius);
    }
    canvas.restore();

    // 6. Rim shadow — vinheta sutil no terminator pra dar volume.
    final rimShadow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.5, 0.5),
        radius: 1.0,
        colors: [Colors.transparent, spec.palette[0].withValues(alpha: 0.45)],
        stops: const [0.78, 1.0],
      ).createShader(bodyRect);
    canvas.drawCircle(center, radius, rimShadow);

    // 7. Highlight — bloom pequeno no quadrante upper-left.
    final highlight = Paint()
      ..color = spec.palette[4].withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.32, center.dy - radius * 0.32),
      radius * 0.18,
      highlight,
    );
  }

  void _paintBands(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..style = PaintingStyle.fill;
    const bandCount = 6;
    for (var i = 0; i < bandCount; i++) {
      final t = (i / bandCount) * 2 - 1; // -1..1
      final y = center.dy + t * radius * 0.85;
      final h = radius * 0.16;
      final colorIdx = (i.isEven ? 1 : 2);
      paint.color = spec.palette[colorIdx].withValues(alpha: 0.45);
      final rect = Rect.fromLTWH(center.dx - radius, y - h / 2, radius * 2, h);
      canvas.drawRect(rect, paint);
    }
  }

  void _paintSpeckled(Canvas canvas, Offset center, double radius) {
    final rng = math.Random(spec.seed);
    final paint = Paint()..style = PaintingStyle.fill;
    final dotCount = (radius * 0.7).round().clamp(8, 22);
    for (var i = 0; i < dotCount; i++) {
      final r = math.sqrt(rng.nextDouble()) * radius * 0.85;
      final theta = rng.nextDouble() * math.pi * 2;
      final dot = Offset(
        center.dx + r * math.cos(theta),
        center.dy + r * math.sin(theta),
      );
      final dotRadius = (1 + rng.nextDouble() * 2.5);
      final colorIdx = 1 + rng.nextInt(2);
      paint.color = spec.palette[colorIdx].withValues(alpha: 0.55);
      canvas.drawCircle(dot, dotRadius, paint);
    }
  }

  void _paintHemispheres(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = spec.palette[0].withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final lowerRect = Rect.fromLTWH(
      center.dx - radius,
      center.dy + radius * 0.05,
      radius * 2,
      radius * 0.95,
    );
    canvas.drawRect(lowerRect, paint);
    // Polar cap highlight no topo.
    paint.color = spec.palette[4].withValues(alpha: 0.40);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.85),
        width: radius * 1.4,
        height: radius * 0.5,
      ),
      math.pi,
      math.pi,
      true,
      paint,
    );
  }

  void _paintRing(
    Canvas canvas,
    Offset center,
    double bodyRadius,
    double tiltY,
  ) {
    final ringWidth = bodyRadius * 1.85;
    final ringHeight = bodyRadius * tiltY * 1.65;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2, bodyRadius * 0.08)
      ..shader = ui.Gradient.linear(
        Offset(center.dx - ringWidth / 2, center.dy),
        Offset(center.dx + ringWidth / 2, center.dy),
        [
          spec.palette[3].withValues(alpha: 0.0),
          spec.palette[3].withValues(alpha: 0.85),
          spec.palette[3].withValues(alpha: 0.0),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: ringWidth, height: ringHeight),
      ringPaint,
    );

    // Aresta brilhante na frente do corpo (front-arc) — cria
    // sensacao de profundidade do anel passando atras.
    final frontArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, bodyRadius * 0.06)
      ..color = spec.palette[4].withValues(alpha: 0.55);
    canvas.drawArc(
      Rect.fromCenter(center: center, width: ringWidth, height: ringHeight),
      0.05,
      math.pi - 0.10,
      false,
      frontArc,
    );
  }

  @override
  bool shouldRepaint(covariant DomainPlanetPainter old) =>
      old.isActive != isActive || old.pulse != pulse || old.spec != spec;
}
