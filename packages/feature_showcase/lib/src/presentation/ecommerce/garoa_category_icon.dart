import 'package:feature_showcase/src/domain/product_category.dart';
import 'package:flutter/material.dart';

/// Glifo da categoria, desenhado em painter. Substitui o IconData
/// generico do Material por uma silhueta unica da Garoa, usado nos
/// chips de categoria da home e na barra de filtros do catalogo.
class GaroaCategoryIcon extends StatelessWidget {
  const GaroaCategoryIcon({
    required this.category,
    required this.color,
    this.size = 24,
    super.key,
  });

  final ProductCategory category;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _GaroaCategoryIconPainter(
          category: category,
          color: color,
        ),
      ),
    );
  }
}

class _GaroaCategoryIconPainter extends CustomPainter {
  _GaroaCategoryIconPainter({required this.category, required this.color});

  final ProductCategory category;
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
      case ProductCategory.coffee:
        // Grao de cafe — oval com risco central.
        final beanRect = Rect.fromCenter(
          center: Offset(cx, cy),
          width: unit * 0.55,
          height: unit * 0.75,
        );
        canvas
          ..drawOval(beanRect, _stroke)
          ..drawLine(rel(0, -0.30), rel(0, 0.30), _stroke);
      case ProductCategory.tabletop:
        // Caneca mini — retangulo + asa.
        final body = Rect.fromLTRB(
          rel(-0.28, -0.18).dx,
          rel(-0.28, -0.18).dy,
          rel(0.18, 0.30).dx,
          rel(0.18, 0.30).dy,
        );
        final handle = Path()
          ..moveTo(rel(0.18, -0.08).dx, rel(0.18, -0.08).dy)
          ..arcToPoint(
            rel(0.18, 0.18),
            radius: Radius.circular(unit * 0.16),
          );
        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(body, Radius.circular(unit * 0.05)),
            _stroke,
          )
          ..drawPath(handle, _stroke);
      case ProductCategory.stationery:
        // Caderno — retangulo com tres linhas internas.
        final cover = Rect.fromLTRB(
          rel(-0.30, -0.30).dx,
          rel(-0.30, -0.30).dy,
          rel(0.30, 0.30).dx,
          rel(0.30, 0.30).dy,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(cover, Radius.circular(unit * 0.03)),
          _stroke,
        );
        for (var i = -1; i <= 1; i++) {
          final y = i * 0.13;
          canvas.drawLine(rel(-0.16, y), rel(0.16, y), _stroke);
        }
      case ProductCategory.bookshop:
        // Livro fechado — retangulo em pe com lombada espessa.
        final book = Rect.fromLTRB(
          rel(-0.22, -0.32).dx,
          rel(-0.22, -0.32).dy,
          rel(0.22, 0.32).dx,
          rel(0.22, 0.32).dy,
        );
        final spine = Rect.fromLTRB(
          rel(-0.22, -0.32).dx,
          rel(-0.22, -0.32).dy,
          rel(-0.12, 0.32).dx,
          rel(0.12, 0.32).dy,
        );
        canvas
          ..drawRect(book, _stroke)
          ..drawRect(spine, _fill);
    }
  }

  @override
  bool shouldRepaint(_GaroaCategoryIconPainter old) {
    return old.category != category || old.color != color;
  }
}
