import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Mapa abstrato com rota animada — destaque tecnico do mock Aurora
/// (PROJECT.md §4.3.3 marca este painter como "destaque tecnico"). A
/// composicao desenha:
///
/// 1. Quarteiroes geometricos como pano de fundo (suggestao de cidade
///    sem coordenadas reais, em duas tonalidades pra ar de mapa);
/// 2. Uma rota curva como `Path` Bezier ligando a banca (origem) ao
///    cliente (destino);
/// 3. Um halo + linha tracejada animada acompanhando o `progress`;
/// 4. Markers de origem e destino com ilustracoes proprias;
/// 5. O entregador em transito como circulo + halo pulsante,
///    posicionado em `metric.getTangentForOffset(progress)`.
///
/// Performance: o painter recebe o `Listenable` direto via
/// `super(repaint: ...)`, evitando o ciclo `build → layout` da arvore
/// (ver CLAUDE.md). Paints, paths e quarteiroes sao cacheados como
/// campos. `shouldRepaint` so dispara quando o progresso ou as cores
/// mudam.
class AuroraDeliveryMap extends StatefulWidget {
  const AuroraDeliveryMap({
    required this.height,
    super.key,
  });

  /// Altura do canvas; a largura sai do parent.
  final double height;

  @override
  State<AuroraDeliveryMap> createState() => _AuroraDeliveryMapState();
}

class _AuroraDeliveryMapState extends State<AuroraDeliveryMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: CustomPaint(
          isComplex: true,
          willChange: true,
          painter: _AuroraDeliveryMapPainter(
            controller: _controller,
            mapBaseColor: colors.surface,
            mapBlockColor: colors.surfaceContainerHighest,
            roadColor: colors.outline.withValues(alpha: 0.18),
            routeColor: colors.primary,
            originColor: colors.secondary,
            destinationColor: colors.primary,
            courierColor: colors.primary,
            courierHaloColor: colors.primary.withValues(alpha: 0.18),
          ),
        ),
      ),
    );
  }
}

class _AuroraDeliveryMapPainter extends CustomPainter {
  _AuroraDeliveryMapPainter({
    required this.controller,
    required this.mapBaseColor,
    required this.mapBlockColor,
    required this.roadColor,
    required this.routeColor,
    required this.originColor,
    required this.destinationColor,
    required this.courierColor,
    required this.courierHaloColor,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final Color mapBaseColor;
  final Color mapBlockColor;
  final Color roadColor;
  final Color routeColor;
  final Color originColor;
  final Color destinationColor;
  final Color courierColor;
  final Color courierHaloColor;

  // Quarteiroes abstratos em coordenadas normalizadas [0..1] — re-
  // posicionados pra largura/altura do canvas. Cada tupla e
  // (x, y, w, h, isAccent).
  static const List<(double, double, double, double, bool)> _blocks = [
    (0.05, 0.08, 0.20, 0.18, false),
    (0.30, 0.06, 0.16, 0.14, true),
    (0.52, 0.10, 0.22, 0.16, false),
    (0.78, 0.05, 0.18, 0.20, true),
    (0.04, 0.32, 0.16, 0.20, true),
    (0.24, 0.28, 0.24, 0.22, false),
    (0.54, 0.30, 0.18, 0.18, true),
    (0.76, 0.30, 0.22, 0.22, false),
    (0.05, 0.58, 0.22, 0.18, false),
    (0.32, 0.56, 0.18, 0.22, true),
    (0.55, 0.58, 0.20, 0.18, false),
    (0.78, 0.62, 0.18, 0.16, true),
    (0.10, 0.82, 0.18, 0.14, true),
    (0.34, 0.82, 0.20, 0.14, false),
    (0.60, 0.82, 0.16, 0.14, false),
    (0.80, 0.84, 0.16, 0.12, true),
  ];

  late final Paint _basePaint = Paint()
    ..color = mapBaseColor
    ..style = PaintingStyle.fill;

  late final Paint _blockPaint = Paint()
    ..color = mapBlockColor
    ..style = PaintingStyle.fill;

  late final Paint _blockAccentPaint = Paint()
    ..color = mapBlockColor.withValues(alpha: 0.55)
    ..style = PaintingStyle.fill;

  late final Paint _roadPaint = Paint()
    ..color = roadColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  late final Paint _routeHaloPaint = Paint()
    ..color = routeColor.withValues(alpha: 0.18)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _routePaint = Paint()
    ..color = routeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _routeTrailPaint = Paint()
    ..color = routeColor.withValues(alpha: 0.30)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  late final Paint _originFill = Paint()
    ..color = originColor
    ..style = PaintingStyle.fill;

  late final Paint _destinationFill = Paint()
    ..color = destinationColor
    ..style = PaintingStyle.fill;

  late final Paint _markerStroke = Paint()
    ..color = mapBaseColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  late final Paint _courierFill = Paint()
    ..color = courierColor
    ..style = PaintingStyle.fill;

  late final Paint _courierHaloFill = Paint()
    ..color = courierHaloColor
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    canvas
      ..save()
      ..clipRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(20),
        ),
      )
      ..drawRect(Offset.zero & size, _basePaint);

    _paintBlocks(canvas, size);
    _paintRoads(canvas, size);

    // Rota: Bezier curva da origem (canto inf-esq) ao destino (canto
    // sup-dir). Usamos PathMetrics pra: (1) extrair o segmento ja
    // percorrido e (2) calcular a posicao do courier no instante.
    final origin = Offset(size.width * 0.12, size.height * 0.84);
    final destination = Offset(size.width * 0.86, size.height * 0.20);
    final control1 = Offset(size.width * 0.30, size.height * 0.30);
    final control2 = Offset(size.width * 0.70, size.height * 0.78);

    final routePath = Path()
      ..moveTo(origin.dx, origin.dy)
      ..cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        destination.dx,
        destination.dy,
      );

    final progress = controller.value;
    final metric = routePath.computeMetrics().first;

    canvas.drawPath(routePath, _routeHaloPaint);

    // Segmento ja percorrido — solido. Restante — fadeado.
    final traveled = metric.extractPath(0, metric.length * progress);
    final remaining =
        metric.extractPath(metric.length * progress, metric.length);
    canvas
      ..drawPath(remaining, _routeTrailPaint)
      ..drawPath(traveled, _routePaint);

    _paintOriginMarker(canvas, origin);
    _paintDestinationMarker(canvas, destination);
    _paintCourier(canvas, metric, progress);

    canvas.restore();
  }

  void _paintBlocks(Canvas canvas, Size size) {
    for (final b in _blocks) {
      final rect = Rect.fromLTWH(
        b.$1 * size.width,
        b.$2 * size.height,
        b.$3 * size.width,
        b.$4 * size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        b.$5 ? _blockAccentPaint : _blockPaint,
      );
    }
  }

  /// "Ruas" — duas linhas horizontais e duas verticais sutis pra dar
  /// estrutura de grid sem virar tabela.
  void _paintRoads(Canvas canvas, Size size) {
    final hs = [size.height * 0.28, size.height * 0.55, size.height * 0.80];
    final vs = [size.width * 0.28, size.width * 0.54, size.width * 0.78];
    for (final y in hs) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _roadPaint);
    }
    for (final x in vs) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _roadPaint);
    }
  }

  /// Origem (banca) — quadrado arredondado com glyph de telhado.
  void _paintOriginMarker(Canvas canvas, Offset center) {
    final rect = Rect.fromCenter(center: center, width: 26, height: 26);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        _originFill,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        _markerStroke,
      );

    // Telhado: triangulo branco no topo
    final roof = Path()
      ..moveTo(center.dx - 6, center.dy - 1)
      ..lineTo(center.dx, center.dy - 7)
      ..lineTo(center.dx + 6, center.dy - 1)
      ..close();
    canvas.drawPath(
      roof,
      Paint()
        ..color = mapBaseColor
        ..style = PaintingStyle.fill,
    );
    // Porta retangular sob o telhado
    final door = Rect.fromLTWH(center.dx - 3, center.dy + 1, 6, 6);
    canvas.drawRect(
      door,
      Paint()
        ..color = mapBaseColor
        ..style = PaintingStyle.fill,
    );
  }

  /// Destino (cliente) — pin gota com circulo interior.
  void _paintDestinationMarker(Canvas canvas, Offset center) {
    final pin = Path();
    final top = Offset(center.dx, center.dy - 14);
    final bottom = Offset(center.dx, center.dy + 14);
    pin
      ..moveTo(bottom.dx, bottom.dy)
      ..quadraticBezierTo(
        center.dx - 14,
        center.dy + 2,
        top.dx - 4,
        top.dy + 2,
      )
      ..arcToPoint(
        Offset(top.dx + 4, top.dy + 2),
        radius: const Radius.circular(8),
      )
      ..quadraticBezierTo(
        center.dx + 14,
        center.dy + 2,
        bottom.dx,
        bottom.dy,
      )
      ..close();

    canvas
      ..drawPath(pin, _destinationFill)
      ..drawPath(pin, _markerStroke)
      ..drawCircle(
        Offset(center.dx, center.dy - 4),
        4,
        Paint()
          ..color = mapBaseColor
          ..style = PaintingStyle.fill,
      );
  }

  /// Courier em transito — circulo principal com halo pulsante,
  /// posicionado pelo `metric.getTangentForOffset`.
  void _paintCourier(Canvas canvas, ui.PathMetric metric, double progress) {
    final tangent = metric.getTangentForOffset(metric.length * progress);
    if (tangent == null) return;
    final pos = tangent.position;

    // Pulse: 0..1 sinusoidal sobreposto ao progresso
    final pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi * 3);
    final haloRadius = 14 + pulse * 5;

    canvas
      ..drawCircle(pos, haloRadius, _courierHaloFill)
      ..drawCircle(pos, 7, _courierFill)
      ..drawCircle(
        pos,
        7,
        Paint()
          ..color = mapBaseColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  @override
  bool shouldRepaint(_AuroraDeliveryMapPainter old) {
    return old.mapBaseColor != mapBaseColor ||
        old.mapBlockColor != mapBlockColor ||
        old.roadColor != roadColor ||
        old.routeColor != routeColor ||
        old.originColor != originColor ||
        old.destinationColor != destinationColor ||
        old.courierColor != courierColor ||
        old.courierHaloColor != courierHaloColor;
  }
}
