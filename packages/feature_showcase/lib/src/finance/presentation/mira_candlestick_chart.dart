import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/finance/domain/candle.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/util/mira_format.dart';
import 'package:flutter/material.dart';

/// Candlestick chart com crosshair interativo — destaque tecnico do
/// mock Mira. Ao tocar ou arrastar o dedo no chart, um crosshair
/// (linha vertical + horizontal) segue o cursor; uma tooltip
/// monoespacada flutua mostrando OHLC + volume da vela apontada.
///
/// O grafico tem reveal animation no primeiro frame — todas as velas
/// aparecem progressivamente da esquerda pra direita em 800ms via
/// `_reveal` controller. Quando o crosshair esta ativo, o reveal e
/// considerado completo (pra nao "esconder" velas que o usuario ja
/// quer inspecionar).
///
/// Performance: o painter recebe o `Listenable` (reveal controller)
/// direto via `super(repaint:)` durante a entrada. Depois que a
/// animacao termina, `_crosshairIndex` dispara setState que recria o
/// painter com o novo valor (`shouldRepaint` confronta indices).
class MiraCandlestickChart extends StatefulWidget {
  const MiraCandlestickChart({
    required this.candles,
    required this.height,
    super.key,
  });

  /// Serie OHLC pra desenhar. Ordem do mais antigo (index 0) ao
  /// mais recente (index n-1).
  final List<Candle> candles;

  /// Altura do canvas; largura sai do parent.
  final double height;

  @override
  State<MiraCandlestickChart> createState() => _MiraCandlestickChartState();
}

class _MiraCandlestickChartState extends State<MiraCandlestickChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  int? _crosshairIndex;

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  /// Converte coordenada local em indice de vela. Retorna null quando
  /// fora do plot area (margem direita pros labels de preco).
  int? _indexFromLocal(Offset local, Size canvasSize) {
    if (widget.candles.isEmpty) return null;
    const left = _MiraCandlestickPainter.padLeft;
    const right = _MiraCandlestickPainter.padRight;
    final plotWidth = canvasSize.width - left - right;
    if (plotWidth <= 0) return null;
    if (local.dx < left || local.dx > canvasSize.width - right) return null;
    final relX = (local.dx - left) / plotWidth;
    final i = (relX * widget.candles.length).floor();
    return i.clamp(0, widget.candles.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => setState(() {
              _crosshairIndex = _indexFromLocal(
                d.localPosition,
                constraints.biggest,
              );
            }),
            onPanStart: (d) => setState(() {
              _crosshairIndex = _indexFromLocal(
                d.localPosition,
                constraints.biggest,
              );
            }),
            onPanUpdate: (d) => setState(() {
              _crosshairIndex = _indexFromLocal(
                d.localPosition,
                constraints.biggest,
              );
            }),
            onPanCancel: () => setState(() => _crosshairIndex = null),
            child: RepaintBoundary(
              child: CustomPaint(
                isComplex: true,
                willChange: true,
                painter: _MiraCandlestickPainter(
                  candles: widget.candles,
                  crosshairIndex: _crosshairIndex,
                  reveal: _reveal,
                  upColor: colors.success,
                  downColor: colors.error,
                  gridColor: colors.border,
                  surfaceColor: colors.surface,
                  textColor: colors.onSurface,
                  mutedColor: colors.onSurfaceMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiraCandlestickPainter extends CustomPainter {
  _MiraCandlestickPainter({
    required this.candles,
    required this.crosshairIndex,
    required this.reveal,
    required this.upColor,
    required this.downColor,
    required this.gridColor,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
  }) : super(repaint: reveal);

  final List<Candle> candles;
  final int? crosshairIndex;
  final Animation<double> reveal;
  final Color upColor;
  final Color downColor;
  final Color gridColor;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;

  static const double padLeft = 8;
  static const double padRight = 60;
  static const double padTop = 14;
  static const double padBottom = 22;
  static const int gridLineCount = 5;

  late final Paint _gridPaint = Paint()
    ..color = gridColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6;

  late final Paint _upFill = Paint()
    ..color = upColor
    ..style = PaintingStyle.fill;

  late final Paint _downFill = Paint()
    ..color = downColor
    ..style = PaintingStyle.fill;

  late final Paint _upWick = Paint()
    ..color = upColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.3;

  late final Paint _downWick = Paint()
    ..color = downColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.3;

  late final Paint _crosshairPaint = Paint()
    ..color = textColor.withValues(alpha: 0.45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty || size.width <= 0 || size.height <= 0) return;

    final plot = Rect.fromLTRB(
      padLeft,
      padTop,
      size.width - padRight,
      size.height - padBottom,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    final priceRange = _priceRange();
    final minPrice = priceRange.$1;
    final maxPrice = priceRange.$2;
    final priceSpan = (maxPrice - minPrice).clamp(1, double.infinity);

    _paintGrid(canvas, plot, minPrice, maxPrice, priceSpan);
    _paintDateLabels(canvas, plot);

    final revealProgress = reveal.value;

    // Velas. Com reveal ativo, cortamos um clipRect crescendo da
    // esquerda pra direita pra fazer o efeito de "desenho".
    final revealActive = crosshairIndex == null && revealProgress < 1;
    if (revealActive) {
      canvas
        ..save()
        ..clipRect(
          Rect.fromLTWH(
            plot.left,
            plot.top,
            plot.width * revealProgress,
            plot.height,
          ),
        );
    }

    _paintCandles(canvas, plot, minPrice, priceSpan);

    if (revealActive) {
      canvas.restore();
    }

    if (crosshairIndex != null) {
      _paintCrosshair(canvas, plot, minPrice, priceSpan, size);
    }
  }

  (double, double) _priceRange() {
    var min = candles.first.lowCents.toDouble();
    var max = candles.first.highCents.toDouble();
    for (final c in candles) {
      if (c.lowCents < min) min = c.lowCents.toDouble();
      if (c.highCents > max) max = c.highCents.toDouble();
    }
    // Padding vertical de 5% pra que as wicks nao encostem na borda.
    final padPx = (max - min) * 0.06;
    return (min - padPx, max + padPx);
  }

  void _paintGrid(
    Canvas canvas,
    Rect plot,
    double minPrice,
    double maxPrice,
    num priceSpan,
  ) {
    for (var i = 0; i < gridLineCount; i++) {
      final t = i / (gridLineCount - 1);
      final y = plot.top + plot.height * t;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), _gridPaint);

      final price = (maxPrice - (maxPrice - minPrice) * t).round();
      final tp = TextPainter(
        text: TextSpan(
          text: formatMiraPrice(price),
          style: TextStyle(
            color: mutedColor,
            fontSize: 9,
            fontFamily: MiraBrand.monoFontFamily,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(plot.right + 4, y - tp.size.height / 2));
    }
  }

  void _paintDateLabels(Canvas canvas, Rect plot) {
    if (candles.length < 4) return;
    const labelCount = 4;
    for (var i = 0; i < labelCount; i++) {
      final t = i / (labelCount - 1);
      final idx = (t * (candles.length - 1)).round();
      final x = plot.left + plot.width * t;
      final tp = TextPainter(
        text: TextSpan(
          text: formatMiraShortDate(candles[idx].timestamp),
          style: TextStyle(
            color: mutedColor,
            fontSize: 9,
            fontFamily: MiraBrand.monoFontFamily,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final textX = (x - tp.size.width / 2).clamp(
        plot.left,
        plot.right - tp.size.width,
      );
      tp.paint(canvas, Offset(textX, plot.bottom + 5));
    }
  }

  void _paintCandles(Canvas canvas, Rect plot, double minPrice, num priceSpan) {
    final slot = plot.width / candles.length;
    final bodyWidth = math.max(1.6, slot * 0.62);

    double yForPrice(num p) =>
        plot.top + (1 - (p - minPrice) / priceSpan) * plot.height;

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final cx = plot.left + (i + 0.5) * slot;

      final yOpen = yForPrice(c.openCents);
      final yClose = yForPrice(c.closeCents);
      final yHigh = yForPrice(c.highCents);
      final yLow = yForPrice(c.lowCents);

      final isUp = c.isBullish;
      final wickPaint = isUp ? _upWick : _downWick;
      final bodyFill = isUp ? _upFill : _downFill;

      // Wick: linha vertical no centro de high a low.
      canvas.drawLine(Offset(cx, yHigh), Offset(cx, yLow), wickPaint);

      // Body: retangulo de open a close.
      var bodyTop = math.min(yOpen, yClose);
      var bodyBottom = math.max(yOpen, yClose);
      if (bodyBottom - bodyTop < 1.2) {
        // Doji — desenha como linha bem fina pra nao virar pixel solto.
        bodyTop -= 0.6;
        bodyBottom += 0.6;
      }

      canvas.drawRect(
        Rect.fromLTRB(
          cx - bodyWidth / 2,
          bodyTop,
          cx + bodyWidth / 2,
          bodyBottom,
        ),
        bodyFill,
      );
    }
  }

  void _paintCrosshair(
    Canvas canvas,
    Rect plot,
    double minPrice,
    num priceSpan,
    Size canvasSize,
  ) {
    final idx = crosshairIndex!.clamp(0, candles.length - 1);
    final c = candles[idx];
    final slot = plot.width / candles.length;
    final cx = plot.left + (idx + 0.5) * slot;

    double yForPrice(num p) =>
        plot.top + (1 - (p - minPrice) / priceSpan) * plot.height;
    final closeY = yForPrice(c.closeCents);

    // Linhas dashed manualmente — escalonadas em 4px on/3px off.
    _drawDashedLine(
      canvas,
      Offset(cx, plot.top),
      Offset(cx, plot.bottom),
      _crosshairPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(plot.left, closeY),
      Offset(plot.right, closeY),
      _crosshairPaint,
    );

    _paintCrosshairTooltip(canvas, plot, idx, cx, closeY, canvasSize);
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dashOn = 4.0;
    const dashOff = 3.0;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final stepX = dx / length;
    final stepY = dy / length;
    var traveled = 0.0;
    while (traveled < length) {
      final segEnd = math.min(traveled + dashOn, length);
      canvas.drawLine(
        Offset(from.dx + stepX * traveled, from.dy + stepY * traveled),
        Offset(from.dx + stepX * segEnd, from.dy + stepY * segEnd),
        paint,
      );
      traveled = segEnd + dashOff;
    }
  }

  void _paintCrosshairTooltip(
    Canvas canvas,
    Rect plot,
    int idx,
    double cx,
    double closeY,
    Size canvasSize,
  ) {
    final c = candles[idx];
    final isUp = c.isBullish;
    final priceColor = isUp ? upColor : downColor;

    // Linhas da tooltip — 4 linhas: data + preco grande, O/H, L/C, Vol.
    final lines = <_TooltipLine>[
      _TooltipLine(
        leading: formatMiraShortDate(c.timestamp),
        trailing: formatMiraPrice(c.closeCents),
        trailingColor: priceColor,
        bold: true,
      ),
      _TooltipLine(
        leading: 'O ${formatMiraPrice(c.openCents)}',
        trailing: 'H ${formatMiraPrice(c.highCents)}',
      ),
      _TooltipLine(
        leading: 'L ${formatMiraPrice(c.lowCents)}',
        trailing: 'C ${formatMiraPrice(c.closeCents)}',
      ),
      _TooltipLine(
        leading: 'Vol',
        trailing: formatMiraVolume(c.volume),
        trailingColor: mutedColor,
      ),
    ];

    final lineWidgets = lines.map((line) {
      final leadingTp = TextPainter(
        text: TextSpan(
          text: line.leading,
          style: TextStyle(
            color: line.bold ? textColor : mutedColor,
            fontSize: line.bold ? 11 : 10,
            fontWeight: line.bold ? FontWeight.w700 : FontWeight.w500,
            fontFamily: MiraBrand.monoFontFamily,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final trailingTp = TextPainter(
        text: TextSpan(
          text: line.trailing,
          style: TextStyle(
            color: line.trailingColor ?? textColor,
            fontSize: line.bold ? 12 : 10,
            fontWeight: line.bold ? FontWeight.w800 : FontWeight.w600,
            fontFamily: MiraBrand.monoFontFamily,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return (leadingTp, trailingTp);
    }).toList();

    // Dimensiona o box pelo maior par.
    var contentWidth = 0.0;
    var contentHeight = 0.0;
    for (final pair in lineWidgets) {
      final leading = pair.$1;
      final trailing = pair.$2;
      final width = leading.size.width + 14 + trailing.size.width;
      if (width > contentWidth) contentWidth = width;
      contentHeight += math.max(leading.size.height, trailing.size.height) + 3;
    }
    contentHeight -= 3;

    const padX = 10.0;
    const padY = 8.0;
    final boxWidth = contentWidth + padX * 2;
    final boxHeight = contentHeight + padY * 2;

    // Posiciona o box. Direita do crosshair por padrao, esquerda se
    // nao couber. Vertical: cola no topo do plot mas evita encostar
    // no crosshair horizontal.
    final preferRight = cx < canvasSize.width / 2;
    var boxLeft = preferRight ? cx + 12 : cx - 12 - boxWidth;
    if (boxLeft < plot.left) boxLeft = plot.left;
    if (boxLeft + boxWidth > plot.right) boxLeft = plot.right - boxWidth;

    var boxTop = plot.top + 4;
    if ((closeY - boxTop).abs() < boxHeight + 8) {
      boxTop = plot.bottom - boxHeight - 4;
    }

    final boxRect = Rect.fromLTWH(boxLeft, boxTop, boxWidth, boxHeight);

    // Sombra + corpo + borda.
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          boxRect.shift(const Offset(0, 2)),
          const Radius.circular(8),
        ),
        Paint()
          ..color = const Color(0x55000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(boxRect, const Radius.circular(8)),
        Paint()
          ..color = surfaceColor
          ..style = PaintingStyle.fill,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(boxRect, const Radius.circular(8)),
        Paint()
          ..color = gridColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

    var cursorY = boxRect.top + padY;
    for (final pair in lineWidgets) {
      final leading = pair.$1;
      final trailing = pair.$2;
      final rowHeight = math.max(leading.size.height, trailing.size.height);
      leading.paint(canvas, Offset(boxRect.left + padX, cursorY));
      trailing.paint(
        canvas,
        Offset(
          boxRect.right - padX - trailing.size.width,
          cursorY + (rowHeight - trailing.size.height) / 2,
        ),
      );
      cursorY += rowHeight + 3;
    }
  }

  @override
  bool shouldRepaint(_MiraCandlestickPainter old) {
    return !identical(old.candles, candles) ||
        old.crosshairIndex != crosshairIndex ||
        old.upColor != upColor ||
        old.downColor != downColor ||
        old.gridColor != gridColor ||
        old.surfaceColor != surfaceColor ||
        old.textColor != textColor ||
        old.mutedColor != mutedColor;
  }
}

class _TooltipLine {
  const _TooltipLine({
    required this.leading,
    required this.trailing,
    this.trailingColor,
    this.bold = false,
  });

  final String leading;
  final String trailing;
  final Color? trailingColor;
  final bool bold;
}
