import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mapa de bairro abstrato — quarteiroes geometricos como pano de
/// fundo, ruas em cinza claro, parque em accent translucido e pin do
/// imovel destacado com halo pulsante.
///
/// Painter usa um seed (`propertySeed`) pra variar a posicao do pin e
/// dos quarteiroes — assim cada imovel ganha um mapa minimamente
/// diferente sem precisar de assets reais.
///
/// Performance: paints e paths cacheados; ticker so dispara o halo
/// pulsante. Painter recebe controller direto via `super(repaint:)`
/// pra pular build/layout do RenderCustomPaint.
class SolarNeighborhoodMap extends StatefulWidget {
  const SolarNeighborhoodMap({
    required this.propertySeed,
    required this.blockColor,
    required this.streetColor,
    required this.parkColor,
    required this.pinColor,
    super.key,
  });

  /// Seed determinista pra variar pin + quarteiroes por imovel
  /// (hashCode do id, por exemplo). Garante que a mesma propriedade
  /// renda sempre o mesmo mapa.
  final int propertySeed;

  final Color blockColor;
  final Color streetColor;
  final Color parkColor;
  final Color pinColor;

  @override
  State<SolarNeighborhoodMap> createState() => _SolarNeighborhoodMapState();
}

class _SolarNeighborhoodMapState extends State<SolarNeighborhoodMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        isComplex: true,
        willChange: true,
        painter: _SolarNeighborhoodMapPainter(
          controller: _controller,
          propertySeed: widget.propertySeed,
          blockColor: widget.blockColor,
          streetColor: widget.streetColor,
          parkColor: widget.parkColor,
          pinColor: widget.pinColor,
        ),
      ),
    );
  }
}

class _SolarNeighborhoodMapPainter extends CustomPainter {
  _SolarNeighborhoodMapPainter({
    required this.controller,
    required this.propertySeed,
    required this.blockColor,
    required this.streetColor,
    required this.parkColor,
    required this.pinColor,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final int propertySeed;
  final Color blockColor;
  final Color streetColor;
  final Color parkColor;
  final Color pinColor;

  late final Paint _blockPaint = Paint()
    ..color = blockColor
    ..style = PaintingStyle.fill;

  /// Cor das vias — cinza claro frio derivado do asfalto pra contrastar
  /// com os quarteiroes (que usam `blockColor`, um tan/creme).
  late final Color _streetInkColor = Color.lerp(
    streetColor,
    const Color(0xFFD7DCE2),
    0.70,
  )!;

  late final Paint _streetPaint = Paint()
    ..color = _streetInkColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  late final Paint _streetThinPaint = Paint()
    ..color = _streetInkColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  late final Paint _parkPaint = Paint()
    ..color = parkColor
    ..style = PaintingStyle.fill;

  late final Paint _pinPaint = Paint()
    ..color = pinColor
    ..style = PaintingStyle.fill;

  // Halo pulsante — Paint reusado, so o alpha muda por frame.
  late final Paint _pinHaloPaint = Paint()..style = PaintingStyle.fill;

  late final Paint _pinDotPaint = Paint()..color = Colors.white;

  // Aro fino branco em volta do pin.
  late final Paint _pinRingPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  late final Paint _compassBgPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.85);

  // "N" da bussola — texto estatico, layout feito uma vez.
  late final TextPainter _compassTextPainter = TextPainter(
    text: TextSpan(
      text: 'N',
      style: TextStyle(
        color: pinColor,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Asfalto/fundo do mapa — cinza azulado frio derivado do
  /// `streetColor` (que e um tan da borda). Lerpamos rumo a um slate
  /// frio pra que o fundo NAO seja so um tan-sobre-tan: os
  /// quarteiroes/ruas passam a separar de verdade.
  late final Paint _asphaltPaint = Paint()
    ..color = Color.lerp(streetColor, const Color(0xFF5B6470), 0.62)!
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Fundo (asfalto) = cinza azulado frio distinto, nao um tint do
    // tan da borda — garante que os quarteiroes (creme) separem.
    canvas.drawRect(Offset.zero & size, _asphaltPaint);

    // Grade 5x4 de quarteiroes. Algumas celulas viram parque baseado
    // no seed.
    const cols = 5;
    const rows = 4;
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final parkCell = propertySeed.abs() % (cols * rows);
    final pinCell = (propertySeed.abs() ~/ 3) % (cols * rows);

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          c * cellW + 4,
          r * cellH + 4,
          cellW - 8,
          cellH - 8,
        );
        final idx = r * cols + c;
        if (idx == parkCell) {
          canvas
            ..drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(8)),
              _parkPaint,
            )
            // Trilhas internas do parque.
            ..drawLine(
              Offset(rect.left + 4, rect.center.dy),
              Offset(rect.right - 4, rect.center.dy),
              _streetThinPaint,
            );
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            _blockPaint,
          );
        }
      }
    }

    // Avenidas principais — uma horizontal a 60% e uma vertical a 40%.
    canvas
      ..drawLine(
        Offset(0, size.height * 0.60),
        Offset(size.width, size.height * 0.60),
        _streetPaint,
      )
      ..drawLine(
        Offset(size.width * 0.40, 0),
        Offset(size.width * 0.40, size.height),
        _streetPaint,
      );

    // Pin do imovel no centro do quarteirao escolhido pelo seed.
    final pinRow = pinCell ~/ cols;
    final pinCol = pinCell % cols;
    final pinCenter = Offset(
      pinCol * cellW + cellW / 2,
      pinRow * cellH + cellH / 2,
    );
    final halo = 6 + 6 * controller.value;
    _pinHaloPaint.color = pinColor.withValues(
      alpha: 0.20 * (1 - controller.value),
    );
    canvas
      ..drawCircle(pinCenter, halo, _pinHaloPaint)
      ..drawCircle(pinCenter, 6, _pinPaint)
      ..drawCircle(pinCenter, 2.4, _pinDotPaint)
      // Aro fino branco em volta pra destacar.
      ..drawCircle(pinCenter, 6, _pinRingPaint);

    // Risco "X" do norte no canto.
    _paintCompass(canvas, size);
  }

  void _paintCompass(Canvas canvas, Size size) {
    final origin = Offset(size.width - 22, 22);
    canvas.drawCircle(origin, 10, _compassBgPaint);
    _compassTextPainter.paint(
      canvas,
      Offset(
        origin.dx - _compassTextPainter.width / 2,
        origin.dy - _compassTextPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_SolarNeighborhoodMapPainter old) {
    return old.propertySeed != propertySeed ||
        old.blockColor != blockColor ||
        old.streetColor != streetColor ||
        old.parkColor != parkColor ||
        old.pinColor != pinColor;
  }
}

/// Helper para gerar seed a partir de um id de string.
int solarMapSeedFor(String id) {
  var hash = 0;
  for (var i = 0; i < id.length; i++) {
    hash = (hash * 31 + id.codeUnitAt(i)) & 0x7fffffff;
  }
  // Forca area minima pra reduzir colisao de seeds visuais.
  return math.max(1, hash);
}
