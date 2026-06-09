import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Mapa abstrato com rota animada — destaque tecnico do mock Aurora
/// (PROJECT.md §4.3.3 marca este painter como "destaque tecnico"). A
/// composicao desenha, em ordem de paint:
///
/// 1. **Avenidas** desenhadas como stripes largas em `border` color —
///    formam o grid base da cidade;
/// 2. **Quarteiroes** pintados *dentro* das celulas do grid em
///    `surfaceMuted`, com inset pra deixar o asfalto da avenida
///    aparecer entre eles. Tons variam por celula pra dar densidade
///    visual sem virar tabuleiro;
/// 3. **Parque** (uma celula em verde primary 0.22 alpha) e **rio**
///    (Bezier em info color) — landmarks que ancoram a leitura como
///    mapa;
/// 4. **Rota** ligando a banca (origem) ao cliente (destino) em
///    Bezier cubica: halo difuso + segmento percorrido solido +
///    segmento restante tracejado;
/// 5. **Marcadores** diferenciados — origem em ocre accent com glyph
///    de cesta, destino em verde primary com glyph de casa;
/// 6. **Courier** rotacionado por `tangent.angle` (silhueta de moto
///    com tampa branca) e bolha de ETA flutuando acima;
/// 7. **Bussola** + escala no canto inferior direito — assinatura
///    cartografica.
///
/// Performance: o painter recebe o `Listenable` direto via
/// `super(repaint: ...)`, evitando o ciclo `build → layout` da arvore
/// (ver CLAUDE.md). Paints, paths estaticos e a `_blockCells` lista
/// sao cacheados como campos. `shouldRepaint` so dispara quando o
/// progresso ou as cores mudam.
class AuroraDeliveryMap extends StatefulWidget {
  const AuroraDeliveryMap({required this.height, super.key});

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
    final colors = context.colors;
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: CustomPaint(
          isComplex: true,
          willChange: true,
          painter: _AuroraDeliveryMapPainter(
            controller: _controller,
            base: colors.surface,
            block: colors.surfaceMuted,
            street: colors.border,
            route: colors.primary,
            park: colors.primary,
            river: colors.info,
            origin: colors.accent,
            destination: colors.primary,
            onSurface: colors.onSurface,
            onMuted: colors.onSurfaceMuted,
          ),
        ),
      ),
    );
  }
}

class _AuroraDeliveryMapPainter extends CustomPainter {
  _AuroraDeliveryMapPainter({
    required this.controller,
    required this.base,
    required this.block,
    required this.street,
    required this.route,
    required this.park,
    required this.river,
    required this.origin,
    required this.destination,
    required this.onSurface,
    required this.onMuted,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final Color base;
  final Color block;
  final Color street;
  final Color route;
  final Color park;
  final Color river;
  final Color origin;
  final Color destination;
  final Color onSurface;
  final Color onMuted;

  // Linhas de avenida em coordenadas normalizadas [0..1]. Formam um
  // grid 4-colunas × 3-linhas (3 verticais internas + 2 horizontais
  // internas) — bordas da viewport completam as celulas externas.
  static const List<double> _hLines = [0.32, 0.62];
  static const List<double> _vLines = [0.26, 0.52, 0.78];

  // Celulas (col, row) com flag de variacao tonal. Coordenada (0,0)
  // e o canto superior esquerdo do grid.
  static const List<(int, int, bool)> _blockCells = [
    (0, 0, false),
    (1, 0, true),
    (2, 0, false),
    (3, 0, true),
    (0, 1, true),
    (1, 1, false),
    (2, 1, true),
    (3, 1, false),
    (0, 2, false),
    (1, 2, true),
    (2, 2, false),
    (3, 2, true),
  ];

  // Celula que vira parque (em vez de quarteirao normal).
  static const (int, int) _parkCell = (1, 2);

  late final Paint _basePaint = Paint()
    ..color = base
    ..style = PaintingStyle.fill;

  late final Paint _streetPaint = Paint()
    ..color = street
    ..style = PaintingStyle.fill;

  late final Paint _blockPaint = Paint()
    ..color = block
    ..style = PaintingStyle.fill;

  late final Paint _blockAltPaint = Paint()
    ..color = Color.lerp(block, base, 0.35)!
    ..style = PaintingStyle.fill;

  late final Paint _parkPaint = Paint()
    ..color = park.withValues(alpha: 0.22)
    ..style = PaintingStyle.fill;

  late final Paint _parkRingPaint = Paint()
    ..color = park.withValues(alpha: 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  late final Paint _riverPaint = Paint()
    ..color = river.withValues(alpha: 0.32)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 14
    ..strokeCap = StrokeCap.round;

  late final Paint _routeHaloPaint = Paint()
    ..color = route.withValues(alpha: 0.20)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  late final Paint _routePaint = Paint()
    ..color = route
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _routeDashedPaint = Paint()
    ..color = route.withValues(alpha: 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round;

  late final Paint _originFill = Paint()
    ..color = origin
    ..style = PaintingStyle.fill;

  late final Paint _destinationFill = Paint()
    ..color = destination
    ..style = PaintingStyle.fill;

  late final Paint _markerStroke = Paint()
    ..color = base
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  late final Paint _markerShadow = Paint()
    ..color = const Color(0x33000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  late final Paint _courierBody = Paint()
    ..color = route
    ..style = PaintingStyle.fill;

  late final Paint _courierHaloFill = Paint()
    ..color = route.withValues(alpha: 0.16)
    ..style = PaintingStyle.fill;

  late final Paint _whiteFill = Paint()
    ..color = base
    ..style = PaintingStyle.fill;

  late final Paint _treePaint = Paint()
    ..color = park.withValues(alpha: 0.55)
    ..style = PaintingStyle.fill;

  late final Paint _basketHandlePaint = Paint()
    ..color = base
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;

  late final Paint _courierStroke = Paint()
    ..color = base
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  late final Paint _onSurfaceFill = Paint()
    ..color = onSurface
    ..style = PaintingStyle.fill;

  late final Paint _needleDownPaint = Paint()
    ..color = onMuted.withValues(alpha: 0.5)
    ..style = PaintingStyle.fill;

  late final Paint _compassRingPaint = Paint()
    ..color = street
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  late final Paint _scaleOutlinePaint = Paint()
    ..color = onSurface
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  late final Paint _etaBubbleStroke = Paint()
    ..color = route.withValues(alpha: 0.30)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  late final TextPainter _etaPainter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: '12 min',
      style: TextStyle(
        color: route,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
  )..layout();

  late final TextPainter _northPainter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: 'N',
      style: TextStyle(
        color: onSurface,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    ),
  )..layout();

  late final TextPainter _scalePainter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: '300 m',
      style: TextStyle(
        color: onMuted,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    ),
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    canvas
      ..save()
      ..clipRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)),
      )
      ..drawRect(Offset.zero & size, _basePaint);

    _paintStreets(canvas, size);
    _paintBlocks(canvas, size);
    _paintRiver(canvas, size);

    // Rota: Bezier curva da banca (canto inf-esq) ao cliente (canto
    // sup-dir). Usamos PathMetrics pra: (1) extrair o segmento
    // percorrido e o restante; (2) calcular posicao + angulo do
    // courier no instante.
    final originPos = Offset(size.width * 0.16, size.height * 0.82);
    final destPos = Offset(size.width * 0.84, size.height * 0.22);
    final control1 = Offset(size.width * 0.30, size.height * 0.28);
    final control2 = Offset(size.width * 0.72, size.height * 0.78);

    final routePath = Path()
      ..moveTo(originPos.dx, originPos.dy)
      ..cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        destPos.dx,
        destPos.dy,
      );

    final progress = controller.value;
    final metric = routePath.computeMetrics().first;
    final traveledLength = metric.length * progress;

    canvas.drawPath(routePath, _routeHaloPaint);

    if (traveledLength > 0) {
      canvas.drawPath(metric.extractPath(0, traveledLength), _routePaint);
    }
    _drawDashed(
      canvas,
      metric,
      from: traveledLength,
      to: metric.length,
      dashOn: 7,
      dashOff: 5,
    );

    _paintOriginMarker(canvas, originPos);
    _paintDestinationMarker(canvas, destPos);
    _paintCourier(canvas, metric, progress);

    _paintCompass(canvas, size);
    _paintScaleBar(canvas, size);

    canvas.restore();
  }

  /// Desenha as avenidas como retangulos grossos cor de asfalto.
  /// Pintadas *antes* dos blocos, com largura constante; blocos depois
  /// preenchem as celulas internas com inset menor — o resultado e que
  /// a avenida aparece como faixa visivel entre blocos.
  void _paintStreets(Canvas canvas, Size size) {
    const streetThickness = 14.0;
    for (final ny in _hLines) {
      final y = ny * size.height;
      canvas.drawRect(
        Rect.fromLTWH(0, y - streetThickness / 2, size.width, streetThickness),
        _streetPaint,
      );
    }
    for (final nx in _vLines) {
      final x = nx * size.width;
      canvas.drawRect(
        Rect.fromLTWH(x - streetThickness / 2, 0, streetThickness, size.height),
        _streetPaint,
      );
    }
  }

  /// Desenha blocos *dentro* das celulas formadas pelas avenidas.
  /// Cada celula vai do limite (borda da viewport ou meio da avenida
  /// anterior) ate o limite seguinte, com inset interno pra o asfalto
  /// da avenida vazar nos cantos.
  void _paintBlocks(Canvas canvas, Size size) {
    final hStops = <double>[
      0,
      ..._hLines.map((n) => n * size.height),
      size.height,
    ];
    final vStops = <double>[
      0,
      ..._vLines.map((n) => n * size.width),
      size.width,
    ];

    const inset = 9.0;

    for (final cell in _blockCells) {
      final col = cell.$1;
      final row = cell.$2;
      final alt = cell.$3;

      final left = vStops[col] + (col == 0 ? 0 : inset);
      final right = vStops[col + 1] - (col == vStops.length - 2 ? 0 : inset);
      final top = hStops[row] + (row == 0 ? 0 : inset);
      final bottom = hStops[row + 1] - (row == hStops.length - 2 ? 0 : inset);

      final rect = Rect.fromLTRB(left, top, right, bottom);
      if (rect.width <= 0 || rect.height <= 0) continue;

      final rr = RRect.fromRectAndRadius(rect, const Radius.circular(5));

      if (col == _parkCell.$1 && row == _parkCell.$2) {
        canvas
          ..drawRRect(rr, _parkPaint)
          ..drawRRect(rr, _parkRingPaint);
        _paintParkTree(canvas, rect);
      } else {
        canvas.drawRRect(rr, alt ? _blockAltPaint : _blockPaint);
      }
    }
  }

  /// Marca o parque com pequena copa de arvore central pra reforcar
  /// leitura. So um circulo verde mais saturado, sem detalhe excessivo.
  void _paintParkTree(Canvas canvas, Rect rect) {
    final center = rect.center;
    canvas.drawCircle(
      center,
      math.min(rect.width, rect.height) * 0.18,
      _treePaint,
    );
  }

  /// Rio cortando o canto superior direito — Bezier suave com a cor
  /// info (azul-petroleo) em alpha baixo. Ancora a leitura como mapa
  /// urbano (cidade tem rio). Entra pela borda superior e sai pela
  /// borda direita (edge-to-edge), serpenteando — sem stub solto no
  /// canto.
  void _paintRiver(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.66, -size.height * 0.05)
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.10,
        size.width * 0.86,
        size.height * 0.10,
        size.width * 0.90,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.94,
        size.height * 0.32,
        size.width * 1.02,
        size.height * 0.34,
        size.width * 1.05,
        size.height * 0.40,
      );
    canvas.drawPath(path, _riverPaint);
  }

  /// Origem (banca) — quadrado arredondado ocre com cesta estilizada.
  /// Cesta = trapezoide branco no centro + tres pontos representando
  /// produtos. Glyph difere claramente do pin do destino.
  void _paintOriginMarker(Canvas canvas, Offset center) {
    final rect = Rect.fromCenter(center: center, width: 30, height: 30);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(9));
    canvas
      ..drawRRect(rr.shift(const Offset(0, 2)), _markerShadow)
      ..drawRRect(rr, _originFill)
      ..drawRRect(rr, _markerStroke);

    // Cesta: trapezoide invertido (mais largo embaixo).
    final basket = Path()
      ..moveTo(center.dx - 8, center.dy - 3)
      ..lineTo(center.dx + 8, center.dy - 3)
      ..lineTo(center.dx + 6, center.dy + 6)
      ..lineTo(center.dx - 6, center.dy + 6)
      ..close();
    canvas.drawPath(basket, _whiteFill);

    // Alca da cesta.
    final handle = Path()
      ..moveTo(center.dx - 6, center.dy - 3)
      ..quadraticBezierTo(
        center.dx,
        center.dy - 10,
        center.dx + 6,
        center.dy - 3,
      );
    // Alca + tres frutas como pontos.
    canvas
      ..drawPath(handle, _basketHandlePaint)
      ..drawCircle(Offset(center.dx - 3, center.dy + 1), 1.6, _originFill)
      ..drawCircle(Offset(center.dx + 3, center.dy + 1), 1.6, _originFill)
      ..drawCircle(Offset(center.dx, center.dy + 3), 1.6, _originFill);
  }

  /// Destino (cliente) — pin gota verde com glyph de casa branco.
  void _paintDestinationMarker(Canvas canvas, Offset center) {
    // Sombra elipsoide na base.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 16),
        width: 18,
        height: 5,
      ),
      _markerShadow,
    );

    final pinPath = Path()
      ..moveTo(center.dx, center.dy + 14)
      ..quadraticBezierTo(
        center.dx - 14,
        center.dy + 2,
        center.dx - 12,
        center.dy - 8,
      )
      ..arcToPoint(
        Offset(center.dx + 12, center.dy - 8),
        radius: const Radius.circular(12),
      )
      ..quadraticBezierTo(
        center.dx + 14,
        center.dy + 2,
        center.dx,
        center.dy + 14,
      )
      ..close();

    canvas
      ..drawPath(pinPath, _destinationFill)
      ..drawPath(pinPath, _markerStroke);

    // Casa: triangulo de telhado + corpo retangular.
    final roof = Path()
      ..moveTo(center.dx - 6, center.dy - 3)
      ..lineTo(center.dx, center.dy - 9)
      ..lineTo(center.dx + 6, center.dy - 3)
      ..close();
    final body = Rect.fromLTWH(center.dx - 5, center.dy - 4, 10, 7);
    canvas
      ..drawPath(roof, _whiteFill)
      ..drawRect(body, _whiteFill);
  }

  /// Courier em transito — silhueta de scooter rotacionada por
  /// `tangent.angle`, halo pulsante e bolha de ETA flutuando acima.
  ///
  /// O scooter e desenhado em coordenadas locais (origem no centro,
  /// orientado ao longo do eixo +x). `canvas.translate(pos)` +
  /// `canvas.rotate(angle)` alinha com a tangente da rota.
  void _paintCourier(Canvas canvas, ui.PathMetric metric, double progress) {
    final tangent = metric.getTangentForOffset(metric.length * progress);
    if (tangent == null) return;
    final pos = tangent.position;
    final angle = tangent.angle; // radianos, eixo +x da curva

    // Halo pulsante — independente da rotacao do veiculo.
    final pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi * 3);
    final haloRadius = 16 + pulse * 5;

    canvas
      ..drawCircle(pos, haloRadius, _courierHaloFill)
      ..save()
      ..translate(pos.dx, pos.dy)
      ..rotate(angle)
      ..drawOval(
        Rect.fromCenter(center: const Offset(0, 4), width: 16, height: 4),
        _markerShadow,
      );

    // Corpo da scooter (trapezoide alongado no eixo +x).
    final body = Path()
      ..moveTo(-7, -2)
      ..lineTo(6, -3.5)
      ..lineTo(8, 0)
      ..lineTo(6, 3.5)
      ..lineTo(-7, 2)
      ..close();
    canvas
      ..drawPath(body, _courierBody)
      ..drawPath(body, _courierStroke)
      // Tampa branca circular no centro (estilo capa de delivery).
      ..drawCircle(Offset.zero, 3, _whiteFill)
      // Rodas (frente e tras).
      ..drawCircle(const Offset(-5, 3.5), 1.6, _onSurfaceFill)
      ..drawCircle(const Offset(6, 3.5), 1.6, _onSurfaceFill)
      ..restore();

    // Bolha de ETA: nao rotaciona, fica acima do courier.
    _paintEtaBubble(canvas, pos);
  }

  /// Bolha branca arredondada com "12 min" — flutua 22px acima do
  /// courier. Reforca leitura de mapa em tempo real.
  void _paintEtaBubble(Canvas canvas, Offset courierPos) {
    final textSize = _etaPainter.size;
    final bubbleWidth = textSize.width + 16;
    final bubbleHeight = textSize.height + 8;
    final bubbleCenter = Offset(courierPos.dx, courierPos.dy - 22);
    final bubbleRect = Rect.fromCenter(
      center: bubbleCenter,
      width: bubbleWidth,
      height: bubbleHeight,
    );

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          bubbleRect.shift(const Offset(0, 1)),
          const Radius.circular(10),
        ),
        _markerShadow,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(bubbleRect, const Radius.circular(10)),
        _whiteFill,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(bubbleRect, const Radius.circular(10)),
        _etaBubbleStroke,
      );

    // Tail/triangulo apontando pro courier.
    final tail = Path()
      ..moveTo(bubbleCenter.dx - 4, bubbleCenter.dy + bubbleHeight / 2 - 0.5)
      ..lineTo(bubbleCenter.dx, bubbleCenter.dy + bubbleHeight / 2 + 4)
      ..lineTo(bubbleCenter.dx + 4, bubbleCenter.dy + bubbleHeight / 2 - 0.5)
      ..close();
    canvas.drawPath(tail, _whiteFill);

    _etaPainter.paint(
      canvas,
      Offset(
        bubbleCenter.dx - textSize.width / 2,
        bubbleCenter.dy - textSize.height / 2,
      ),
    );
  }

  /// Bussola no canto inferior direito — circulo branco com seta
  /// apontando pra cima e letra "N".
  void _paintCompass(Canvas canvas, Size size) {
    final center = Offset(size.width - 24, size.height - 24);
    const radius = 12.0;

    canvas
      ..drawCircle(center.translate(0, 1), radius, _markerShadow)
      ..drawCircle(center, radius, _whiteFill)
      ..drawCircle(center, radius, _compassRingPaint);

    // Seta apontando pra cima — meio vermelha, meio cinza claro.
    final needleUp = Path()
      ..moveTo(center.dx, center.dy - radius + 3)
      ..lineTo(center.dx - 3, center.dy)
      ..lineTo(center.dx + 3, center.dy)
      ..close();
    canvas.drawPath(needleUp, _originFill);
    final needleDown = Path()
      ..moveTo(center.dx, center.dy + radius - 3)
      ..lineTo(center.dx - 3, center.dy)
      ..lineTo(center.dx + 3, center.dy)
      ..close();
    canvas.drawPath(needleDown, _needleDownPaint);

    _northPainter.paint(
      canvas,
      Offset(
        center.dx - _northPainter.size.width / 2,
        center.dy - radius - _northPainter.size.height - 1,
      ),
    );
  }

  /// Barra de escala no canto inferior esquerdo — duas faixas
  /// alternadas (preta/branca estilo cartografico) com label "300 m".
  void _paintScaleBar(Canvas canvas, Size size) {
    const barWidth = 56.0;
    const barHeight = 4.0;
    const left = 16.0;
    final top = size.height - 16;

    canvas
      ..drawRect(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        _scaleOutlinePaint,
      )
      ..drawRect(
        Rect.fromLTWH(left, top, barWidth / 2, barHeight),
        _onSurfaceFill,
      )
      ..drawRect(
        Rect.fromLTWH(left + barWidth / 2, top, barWidth / 2, barHeight),
        _whiteFill,
      );

    _scalePainter.paint(
      canvas,
      Offset(left + barWidth + 4, top - _scalePainter.size.height / 2 + 2),
    );
  }

  /// Desenha um trecho da path como linha tracejada — itera
  /// `extractPath` em chunks `dashOn` (visivel) + `dashOff` (gap).
  /// Usado pro segmento "remaining" da rota.
  void _drawDashed(
    Canvas canvas,
    ui.PathMetric metric, {
    required double from,
    required double to,
    required double dashOn,
    required double dashOff,
  }) {
    var distance = from;
    while (distance < to) {
      final next = math.min(distance + dashOn, to);
      canvas.drawPath(metric.extractPath(distance, next), _routeDashedPaint);
      distance = next + dashOff;
    }
  }

  @override
  bool shouldRepaint(_AuroraDeliveryMapPainter old) {
    return old.base != base ||
        old.block != block ||
        old.street != street ||
        old.route != route ||
        old.park != park ||
        old.river != river ||
        old.origin != origin ||
        old.destination != destination ||
        old.onSurface != onSurface ||
        old.onMuted != onMuted;
  }
}
