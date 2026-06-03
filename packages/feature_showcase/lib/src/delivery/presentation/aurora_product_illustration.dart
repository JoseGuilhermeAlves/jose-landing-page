import 'dart:math' as math;

import 'package:feature_showcase/src/delivery/domain/market_category.dart';
import 'package:flutter/material.dart';

/// Ilustracao geometrica de produto por categoria. Substitui stock
/// photos em cards de vendor, item e historico. Render simples (sem
/// animacao); `shouldRepaint` so dispara quando categoria ou cores
/// mudam.
class AuroraProductIllustration extends StatelessWidget {
  const AuroraProductIllustration({
    required this.category,
    this.foregroundColor,
    this.accentColor,
    super.key,
  });

  final MarketCategory category;
  final Color? foregroundColor;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = foregroundColor ?? scheme.primary;
    final accent = accentColor ?? scheme.secondary;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _AuroraProductIllustrationPainter(
          category: category,
          foregroundColor: fg,
          accentColor: accent,
        ),
      ),
    );
  }
}

class _AuroraProductIllustrationPainter extends CustomPainter {
  _AuroraProductIllustrationPainter({
    required this.category,
    required this.foregroundColor,
    required this.accentColor,
  });

  final MarketCategory category;
  final Color foregroundColor;
  final Color accentColor;

  late final Paint _fillPaint = Paint()
    ..color = foregroundColor
    ..style = PaintingStyle.fill;

  // Tom de sombra do foreground — versao escurecida pra dar volume no
  // lado inferior/direito das silhuetas.
  late final Paint _shadeFill = Paint()
    ..color = Color.lerp(foregroundColor, const Color(0xFF000000), 0.22)!
    ..style = PaintingStyle.fill;

  // Tom de brilho do foreground — versao clareada pro highlight no
  // lado superior/esquerdo.
  late final Paint _highlightFill = Paint()
    ..color = Color.lerp(foregroundColor, const Color(0xFFFFFFFF), 0.28)!
    ..style = PaintingStyle.fill;

  late final Paint _accentFill = Paint()
    ..color = accentColor
    ..style = PaintingStyle.fill;

  // Tom de brilho do accent — usado na fatia/rotulo pra nao ficar chapado.
  late final Paint _accentHighlightFill = Paint()
    ..color = Color.lerp(accentColor, const Color(0xFFFFFFFF), 0.30)!
    ..style = PaintingStyle.fill;

  late final Paint _stroke = Paint()
    ..color = foregroundColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _accentStroke = Paint()
    ..color = accentColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final unit = size.shortestSide;
    final cx = size.width / 2;
    final cy = size.height / 2;
    Offset rel(double dx, double dy) => Offset(cx + dx * unit, cy + dy * unit);

    _stroke.strokeWidth = unit * 0.04;
    _accentStroke.strokeWidth = unit * 0.04;

    switch (category) {
      case MarketCategory.fruits:
        _paintApple(canvas, rel, unit);
      case MarketCategory.greens:
        _paintLeaf(canvas, rel, unit);
      case MarketCategory.bakery:
        _paintBread(canvas, rel, unit);
      case MarketCategory.dairy:
        _paintCheeseWheel(canvas, rel, unit);
      case MarketCategory.pantry:
        _paintJar(canvas, rel, unit);
    }
  }

  /// Maca — circulo com folhinha em cima e haste curta.
  void _paintApple(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    final bodyRect = Rect.fromCircle(center: rel(0, 0.05), radius: unit * 0.30);
    canvas
      ..drawCircle(rel(0, 0.05), unit * 0.30, _fillPaint)
      // Sombra — meia-lua escura no lado inferior-direito (volume).
      ..save()
      ..clipPath(Path()..addOval(bodyRect))
      ..drawCircle(rel(0.14, 0.13), unit * 0.26, _shadeFill)
      ..restore()
      // Brilho — meia-lua clara em cima a esquerda.
      ..drawCircle(rel(-0.10, -0.06), unit * 0.07, _highlightFill);

    // Haste e folha em accent.
    final stem = Path()
      ..moveTo(rel(0, -0.22).dx, rel(0, -0.22).dy)
      ..lineTo(rel(0.04, -0.32).dx, rel(0.04, -0.32).dy);
    canvas.drawPath(stem, _accentStroke);

    final leaf = Path()
      ..moveTo(rel(0.04, -0.32).dx, rel(0.04, -0.32).dy)
      ..quadraticBezierTo(
        rel(0.18, -0.36).dx,
        rel(0.18, -0.36).dy,
        rel(0.20, -0.22).dx,
        rel(0.20, -0.22).dy,
      )
      ..quadraticBezierTo(
        rel(0.10, -0.28).dx,
        rel(0.10, -0.28).dy,
        rel(0.04, -0.32).dx,
        rel(0.04, -0.32).dy,
      )
      ..close();
    canvas.drawPath(leaf, _accentFill);
  }

  /// Folha — oval com nervuras.
  void _paintLeaf(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    final leaf = Path()
      ..moveTo(rel(0, -0.35).dx, rel(0, -0.35).dy)
      ..quadraticBezierTo(
        rel(0.32, -0.05).dx,
        rel(0.32, -0.05).dy,
        rel(0, 0.35).dx,
        rel(0, 0.35).dy,
      )
      ..quadraticBezierTo(
        rel(-0.32, -0.05).dx,
        rel(-0.32, -0.05).dy,
        rel(0, -0.35).dx,
        rel(0, -0.35).dy,
      )
      ..close();
    canvas
      ..drawPath(leaf, _fillPaint)
      // Metade direita em tom de sombra — separa as duas faces pela
      // nervura central, dando dimensao a folha chapada.
      ..save()
      ..clipPath(leaf)
      ..drawRect(
        Rect.fromLTWH(rel(0, 0).dx, rel(0, -0.40).dy, unit * 0.40, unit * 0.80),
        _shadeFill,
      )
      ..restore()
      // Nervura central.
      ..drawLine(rel(0, -0.30), rel(0, 0.30), _accentStroke);
    // Nervuras laterais.
    for (var i = -2; i <= 2; i++) {
      final y = i * 0.10;
      canvas
        ..drawLine(rel(0, y), rel(-0.16, y + 0.08), _accentStroke)
        ..drawLine(rel(0, y), rel(0.16, y + 0.08), _accentStroke);
    }
  }

  /// Pao — oval inclinado com risco diagonal.
  void _paintBread(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    canvas
      ..save()
      ..translate(rel(0, 0).dx, rel(0, 0).dy)
      ..rotate(-0.2);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: unit * 0.72,
      height: unit * 0.42,
    );
    canvas
      ..drawOval(rect, _fillPaint)
      // Sombra na metade inferior da casca (volume do pao).
      ..save()
      ..clipPath(Path()..addOval(rect))
      ..drawOval(rect.shift(Offset(0, unit * 0.06)), _shadeFill)
      // Brilho na parte de cima.
      ..drawOval(
        Rect.fromCenter(
          center: Offset(0, -unit * 0.10),
          width: unit * 0.52,
          height: unit * 0.16,
        ),
        _highlightFill,
      )
      ..restore()
      // Risco da casca: 3 cortes diagonais.
      ..drawLine(
        Offset(-unit * 0.20, -unit * 0.05),
        Offset(-unit * 0.08, -unit * 0.18),
        _accentStroke,
      )
      ..drawLine(
        Offset(-unit * 0.04, -unit * 0.08),
        Offset(unit * 0.08, -unit * 0.20),
        _accentStroke,
      )
      ..drawLine(
        Offset(unit * 0.12, -unit * 0.10),
        Offset(unit * 0.22, -unit * 0.20),
        _accentStroke,
      )
      ..restore();
  }

  /// Roda de queijo — circulo com fatia em accent + furos.
  void _paintCheeseWheel(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    final r = unit * 0.30;
    final circleRect = Rect.fromCircle(center: rel(0, 0), radius: r);
    // Fatia simetrica centrada no eixo vertical (aponta pra cima),
    // setor de ~57° (1 rad) — start = -pi/2 - sweep/2.
    const wedgeSweep = 1.0;
    const wedgeStart = -math.pi / 2 - wedgeSweep / 2;
    canvas
      ..drawCircle(rel(0, 0), r, _fillPaint)
      // Sombra na metade inferior da roda (volume).
      ..save()
      ..clipPath(Path()..addOval(circleRect))
      ..drawOval(circleRect.shift(Offset(0, r * 0.30)), _shadeFill)
      ..restore()
      // Fatia em accent (setor centrado).
      ..drawArc(circleRect, wedgeStart, wedgeSweep, true, _accentFill)
      // Brilho na fatia.
      ..drawArc(
        Rect.fromCircle(center: rel(0, 0), radius: r * 0.6),
        wedgeStart,
        wedgeSweep,
        true,
        _accentHighlightFill,
      )
      // Furos.
      ..drawCircle(rel(-0.10, 0.04), r * 0.10, _accentFill)
      ..drawCircle(rel(0.06, 0.14), r * 0.08, _accentFill);
  }

  /// Pote/vidro — retangulo arredondado com tampa + rotulo.
  void _paintJar(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rel(-0.22, -0.18).dx,
        rel(-0.22, -0.18).dy,
        rel(0.22, 0.30).dx,
        rel(0.22, 0.30).dy,
      ),
      Radius.circular(unit * 0.04),
    );
    final lid = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rel(-0.20, -0.30).dx,
        rel(-0.20, -0.30).dy,
        rel(0.20, -0.18).dx,
        rel(0.20, -0.18).dy,
      ),
      Radius.circular(unit * 0.03),
    );
    canvas
      ..drawRRect(body, _fillPaint)
      // Volume no vidro: sombra na faixa direita, brilho na esquerda.
      ..save()
      ..clipRRect(body)
      ..drawRect(
        Rect.fromLTRB(rel(0.08, -0.18).dx, body.top, body.right, body.bottom),
        _shadeFill,
      )
      ..drawRect(
        Rect.fromLTRB(
          rel(-0.20, -0.18).dx,
          body.top,
          rel(-0.13, 0.30).dx,
          body.bottom,
        ),
        _highlightFill,
      )
      ..restore()
      ..drawRRect(lid, _accentFill);

    // Rotulo: faixa horizontal em accent.
    final label = Rect.fromLTRB(
      rel(-0.20, -0.02).dx,
      rel(-0.20, -0.02).dy,
      rel(0.20, 0.12).dx,
      rel(0.20, 0.12).dy,
    );
    canvas
      ..drawRect(label, _accentFill)
      // Brilho no topo do rotulo.
      ..drawRect(
        Rect.fromLTRB(label.left, label.top, label.right, label.center.dy),
        _accentHighlightFill,
      )
      // Linha do "produto" dentro do rotulo.
      ..drawLine(rel(-0.12, 0.05), rel(0.12, 0.05), _stroke);
  }

  @override
  bool shouldRepaint(_AuroraProductIllustrationPainter old) {
    return old.category != category ||
        old.foregroundColor != foregroundColor ||
        old.accentColor != accentColor;
  }
}
