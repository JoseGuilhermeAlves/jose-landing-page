import 'package:feature_showcase/src/domain/market_category.dart';
import 'package:flutter/material.dart';

/// Glifo da categoria desenhado em painter — usado nos chips do
/// catalogo de bancas e no strip de categorias da home. Mais leve que
/// `AuroraProductIllustration`: stroke unico, sem fill, dimensionado
/// pelo `size` curto.
class AuroraCategoryIcon extends StatelessWidget {
  const AuroraCategoryIcon({
    required this.category,
    required this.color,
    this.size = 22,
    super.key,
  });

  final MarketCategory category;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _AuroraCategoryIconPainter(category: category, color: color),
      ),
    );
  }
}

class _AuroraCategoryIconPainter extends CustomPainter {
  _AuroraCategoryIconPainter({required this.category, required this.color});

  final MarketCategory category;
  final Color color;

  late final Paint _stroke = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _fill = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final unit = size.shortestSide;
    _stroke.strokeWidth = unit * 0.08;
    final cx = size.width / 2;
    final cy = size.height / 2;
    Offset rel(double dx, double dy) => Offset(cx + dx * unit, cy + dy * unit);

    switch (category) {
      case MarketCategory.fruits:
        // Maca pequena.
        canvas.drawCircle(rel(0, 0.05), unit * 0.30, _stroke);
        canvas.drawLine(rel(0, -0.20), rel(0.06, -0.32), _stroke);
      case MarketCategory.greens:
        // Folha.
        final leaf = Path()
          ..moveTo(rel(0, -0.32).dx, rel(0, -0.32).dy)
          ..quadraticBezierTo(
            rel(0.28, 0).dx,
            rel(0.28, 0).dy,
            rel(0, 0.32).dx,
            rel(0, 0.32).dy,
          )
          ..quadraticBezierTo(
            rel(-0.28, 0).dx,
            rel(-0.28, 0).dy,
            rel(0, -0.32).dx,
            rel(0, -0.32).dy,
          )
          ..close();
        canvas
          ..drawPath(leaf, _stroke)
          ..drawLine(rel(0, -0.26), rel(0, 0.26), _stroke);
      case MarketCategory.bakery:
        // Pao oval inclinado.
        canvas
          ..save()
          ..translate(cx, cy)
          ..rotate(-0.2)
          ..drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: unit * 0.62,
              height: unit * 0.36,
            ),
            _stroke,
          )
          ..drawLine(
            Offset(-unit * 0.08, -unit * 0.04),
            Offset(0, -unit * 0.12),
            _stroke,
          )
          ..drawLine(
            Offset(unit * 0.04, -unit * 0.04),
            Offset(unit * 0.12, -unit * 0.12),
            _stroke,
          )
          ..restore();
      case MarketCategory.dairy:
        // Roda de queijo — circulo com setor pintado.
        final r = unit * 0.30;
        canvas
          ..drawCircle(rel(0, 0), r, _stroke)
          ..drawArc(
            Rect.fromCircle(center: rel(0, 0), radius: r),
            -0.5,
            1,
            true,
            _fill,
          );
      case MarketCategory.pantry:
        // Pote/jar.
        final body = Rect.fromLTRB(
          rel(-0.22, -0.18).dx,
          rel(-0.22, -0.18).dy,
          rel(0.22, 0.30).dx,
          rel(0.22, 0.30).dy,
        );
        final lid = Rect.fromLTRB(
          rel(-0.18, -0.30).dx,
          rel(-0.18, -0.30).dy,
          rel(0.18, -0.18).dx,
          rel(0.18, -0.18).dy,
        );
        canvas
          ..drawRect(body, _stroke)
          ..drawRect(lid, _stroke);
    }
  }

  @override
  bool shouldRepaint(_AuroraCategoryIconPainter old) {
    return old.category != category || old.color != color;
  }
}
