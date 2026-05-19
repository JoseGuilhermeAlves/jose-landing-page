import 'dart:math' as math;

import 'package:feature_showcase/src/realestate/domain/property_feature.dart';
import 'package:flutter/material.dart';

/// Glifo desenhado por [PropertyFeature] — usado em chips no detalhe
/// do imovel. Cada feature tem geometria propria (piscina = retangulo
/// arredondado com ondulacao; vaga = retangulo com seta; jardim =
/// silhueta de folha; etc.).
///
/// Painter sem animacao; `shouldRepaint` so dispara quando feature ou
/// cor mudam.
class SolarFeatureIcon extends StatelessWidget {
  const SolarFeatureIcon({
    required this.feature,
    this.color,
    this.size = 18,
    super.key,
  });

  final PropertyFeature feature;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _SolarFeatureIconPainter(feature: feature, color: tint),
      ),
    );
  }
}

class _SolarFeatureIconPainter extends CustomPainter {
  _SolarFeatureIconPainter({required this.feature, required this.color});

  final PropertyFeature feature;
  final Color color;

  late final Paint _stroke = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _fill = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    switch (feature) {
      case PropertyFeature.pool:
        _paintPool(canvas, size);
      case PropertyFeature.garage:
        _paintGarage(canvas, size);
      case PropertyFeature.garden:
        _paintGarden(canvas, size);
      case PropertyFeature.balcony:
        _paintBalcony(canvas, size);
      case PropertyFeature.suite:
        _paintSuite(canvas, size);
      case PropertyFeature.barbecue:
        _paintBarbecue(canvas, size);
      case PropertyFeature.solar:
        _paintSolar(canvas, size);
      case PropertyFeature.borehole:
        _paintBorehole(canvas, size);
    }
  }

  /// Piscina — retangulo arredondado com ondulacao senoidal.
  void _paintPool(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.30,
      size.width * 0.8,
      size.height * 0.40,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.1)),
      _stroke,
    );
    final wave = Path()..moveTo(rect.left + 4, rect.center.dy);
    const steps = 6;
    for (var i = 1; i <= steps; i++) {
      final x = rect.left + 4 + (rect.width - 8) * (i / steps);
      final y = rect.center.dy + math.sin(i * math.pi / 1.2) * 1.5;
      wave.lineTo(x, y);
    }
    canvas.drawPath(wave, _stroke);
  }

  /// Vaga coberta — retangulo de garagem com seta entrando.
  void _paintGarage(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.30,
      size.width * 0.70,
      size.height * 0.55,
    );
    canvas.drawRect(rect, _stroke);
    // Telhado triangular.
    final roof = Path()
      ..moveTo(rect.left - 2, rect.top)
      ..lineTo(rect.center.dx, rect.top - size.height * 0.18)
      ..lineTo(rect.right + 2, rect.top);
    canvas.drawPath(roof, _stroke);
    // Seta interna.
    final arrow = Path()
      ..moveTo(rect.center.dx, rect.bottom - 4)
      ..lineTo(rect.center.dx, rect.top + 4)
      ..moveTo(rect.center.dx - 4, rect.top + 8)
      ..lineTo(rect.center.dx, rect.top + 4)
      ..lineTo(rect.center.dx + 4, rect.top + 8);
    canvas.drawPath(arrow, _stroke);
  }

  /// Jardim — silhueta de folha com nervura central.
  void _paintGarden(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final leaf = Path()
      ..moveTo(cx, cy - size.height * 0.35)
      ..quadraticBezierTo(
        cx + size.width * 0.35,
        cy,
        cx,
        cy + size.height * 0.35,
      )
      ..quadraticBezierTo(
        cx - size.width * 0.35,
        cy,
        cx,
        cy - size.height * 0.35,
      );
    canvas
      ..drawPath(leaf, _stroke)
      ..drawLine(
        Offset(cx, cy - size.height * 0.30),
        Offset(cx, cy + size.height * 0.30),
        _stroke,
      );
  }

  /// Varanda — sacada vista de frente com guarda-corpo (3 barras).
  void _paintBalcony(Canvas canvas, Size size) {
    final base = Rect.fromLTWH(
      size.width * 0.10,
      size.height * 0.55,
      size.width * 0.80,
      size.height * 0.10,
    );
    canvas.drawRect(base, _stroke);
    final railTop = base.top - size.height * 0.32;
    canvas
      ..drawLine(
        Offset(base.left, railTop),
        Offset(base.right, railTop),
        _stroke,
      )
      ..drawLine(Offset(base.left, railTop), Offset(base.left, base.top), _stroke)
      ..drawLine(
        Offset(base.right, railTop),
        Offset(base.right, base.top),
        _stroke,
      );
    // Barras verticais do guarda-corpo.
    for (var i = 1; i < 6; i++) {
      final x = base.left + base.width * (i / 6);
      canvas.drawLine(Offset(x, railTop), Offset(x, base.top), _stroke);
    }
  }

  /// Suite — cama vista de cima com travesseiros.
  void _paintSuite(Canvas canvas, Size size) {
    final bed = Rect.fromLTWH(
      size.width * 0.12,
      size.height * 0.35,
      size.width * 0.76,
      size.height * 0.45,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bed, Radius.circular(size.width * 0.06)),
      _stroke,
    );
    // Travesseiros (dois retangulos no topo).
    final pillow1 = Rect.fromLTWH(
      bed.left + 4,
      bed.top + 3,
      bed.width / 2 - 6,
      size.height * 0.10,
    );
    final pillow2 = Rect.fromLTWH(
      bed.center.dx + 2,
      bed.top + 3,
      bed.width / 2 - 6,
      size.height * 0.10,
    );
    canvas
      ..drawRect(pillow1, _stroke)
      ..drawRect(pillow2, _stroke);
  }

  /// Churrasqueira — cupula com 3 espetos atravessando.
  void _paintBarbecue(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.65;
    final radius = size.width * 0.32;
    // Cupula (semi-circulo) + base.
    final dome = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    canvas
      ..drawArc(dome, math.pi, math.pi, false, _stroke)
      ..drawLine(
        Offset(cx - radius, cy),
        Offset(cx + radius, cy),
        _stroke,
      );
    // Espetos.
    for (var i = 0; i < 3; i++) {
      final y = cy - radius * (0.20 + 0.20 * i);
      canvas.drawLine(
        Offset(cx - radius * 1.15, y),
        Offset(cx + radius * 1.15, y),
        _stroke,
      );
    }
  }

  /// Aquecimento solar — sol estilizado com raios.
  void _paintSolar(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.20;
    canvas.drawCircle(Offset(cx, cy), r, _fill);
    final rayInner = r * 1.6;
    final rayOuter = r * 2.4;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final start = Offset(
        cx + math.cos(angle) * rayInner,
        cy + math.sin(angle) * rayInner,
      );
      final end = Offset(
        cx + math.cos(angle) * rayOuter,
        cy + math.sin(angle) * rayOuter,
      );
      canvas.drawLine(start, end, _stroke);
    }
  }

  /// Poco artesiano — gota dagua + ondas concentricas.
  void _paintBorehole(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final drop = Path()
      ..moveTo(cx, cy - size.height * 0.30)
      ..quadraticBezierTo(
        cx + size.width * 0.22,
        cy,
        cx,
        cy + size.height * 0.22,
      )
      ..quadraticBezierTo(
        cx - size.width * 0.22,
        cy,
        cx,
        cy - size.height * 0.30,
      );
    canvas.drawPath(drop, _fill);
    // Ondas no chao.
    for (var i = 1; i <= 2; i++) {
      final rect = Rect.fromCenter(
        center: Offset(cx, cy + size.height * 0.32),
        width: size.width * (0.30 + 0.18 * i),
        height: size.height * (0.08 + 0.05 * i),
      );
      canvas.drawArc(rect, math.pi, math.pi, false, _stroke);
    }
  }

  @override
  bool shouldRepaint(_SolarFeatureIconPainter old) {
    return old.feature != feature || old.color != color;
  }
}
