import 'package:feature_showcase/src/ecommerce/domain/product_category.dart';
import 'package:flutter/material.dart';

/// Ilustracao geometrica desenhada do produto, por categoria. Substitui
/// stock photos no card de produto, no detalhe e na home da Garoa.
/// Render simples (sem animacao) — paint cacheados, `shouldRepaint`
/// retorna true apenas quando categoria ou cores mudam.
///
/// Uso:
/// ```dart
/// AspectRatio(
///   aspectRatio: 1,
///   child: GaroaProductIllustration(
///     category: product.category,
///   ),
/// )
/// ```
class GaroaProductIllustration extends StatelessWidget {
  const GaroaProductIllustration({
    required this.category,
    this.foregroundColor,
    this.accentColor,
    this.backgroundColor,
    super.key,
  });

  final ProductCategory category;

  /// Cor principal do desenho (silhueta, contornos espessos).
  final Color? foregroundColor;

  /// Cor secundaria (highlight, asas de xicara, etc).
  final Color? accentColor;

  /// Cor de fundo do retangulo (default Colors.transparent).
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = foregroundColor ?? scheme.primary;
    final accent = accentColor ?? scheme.secondary;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _GaroaProductIllustrationPainter(
          category: category,
          foregroundColor: fg,
          accentColor: accent,
          backgroundColor: backgroundColor ?? Colors.transparent,
        ),
      ),
    );
  }
}

class _GaroaProductIllustrationPainter extends CustomPainter {
  _GaroaProductIllustrationPainter({
    required this.category,
    required this.foregroundColor,
    required this.accentColor,
    required this.backgroundColor,
  });

  final ProductCategory category;
  final Color foregroundColor;
  final Color accentColor;
  final Color backgroundColor;

  late final Paint _fillPaint = Paint()
    ..color = foregroundColor
    ..style = PaintingStyle.fill;

  late final Paint _strokePaint = Paint()
    ..color = foregroundColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _accentFill = Paint()
    ..color = accentColor
    ..style = PaintingStyle.fill;

  late final Paint _accentStroke = Paint()
    ..color = accentColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _bgPaint = Paint()
    ..color = backgroundColor
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Fundo opcional — quando transparente, evita o draw.
    if (backgroundColor.a > 0) {
      canvas.drawRect(Offset.zero & size, _bgPaint);
    }

    final unit = size.shortestSide;
    final cx = size.width / 2;
    final cy = size.height / 2;
    Offset rel(double dx, double dy) => Offset(cx + dx * unit, cy + dy * unit);

    switch (category) {
      case ProductCategory.coffee:
        _paintCoffeeBag(canvas, rel, unit);
      case ProductCategory.tabletop:
        _paintMug(canvas, rel, unit);
      case ProductCategory.stationery:
        _paintNotebook(canvas, rel, unit);
      case ProductCategory.bookshop:
        _paintBook(canvas, rel, unit);
    }
  }

  /// Saquinho de cafe — retangulo com aba dobrada e selo redondo.
  void _paintCoffeeBag(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    _strokePaint.strokeWidth = unit * 0.025;

    final body = Path()
      ..moveTo(rel(-0.25, -0.35).dx, rel(-0.25, -0.35).dy)
      ..lineTo(rel(0.25, -0.35).dx, rel(-0.25, -0.35).dy)
      ..lineTo(rel(0.27, 0.40).dx, rel(0.27, 0.40).dy)
      ..lineTo(rel(-0.27, 0.40).dx, rel(0.27, 0.40).dy)
      ..close();

    // Aba dobrada (topo). Mesmo polygon, mas em accent.
    final flap = Path()
      ..moveTo(rel(-0.25, -0.38).dx, rel(-0.25, -0.38).dy)
      ..lineTo(rel(0.25, -0.38).dx, rel(-0.25, -0.38).dy)
      ..lineTo(rel(0.20, -0.30).dx, rel(0.20, -0.30).dy)
      ..lineTo(rel(-0.20, -0.30).dx, rel(0.20, -0.30).dy)
      ..close();

    canvas
      ..drawPath(body, _fillPaint)
      ..drawPath(flap, _accentFill)
      // Selo redondo de origem no centro.
      ..drawCircle(rel(0, 0.05), unit * 0.10, _accentFill)
      ..drawCircle(rel(0, 0.05), unit * 0.10, _accentStroke);
  }

  /// Caneca — capsula com asa lateral e linha de cafe interno.
  void _paintMug(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    _strokePaint.strokeWidth = unit * 0.03;

    // Corpo da caneca.
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rel(-0.25, -0.25).dx,
        rel(-0.25, -0.25).dy,
        rel(0.20, 0.30).dx,
        rel(0.20, 0.30).dy,
      ),
      Radius.circular(unit * 0.05),
    );
    // Asa lateral — anel.
    final handlePath = Path()
      ..moveTo(rel(0.20, -0.10).dx, rel(0.20, -0.10).dy)
      ..arcToPoint(
        rel(0.20, 0.15),
        radius: Radius.circular(unit * 0.18),
      );
    _strokePaint.strokeWidth = unit * 0.035;

    canvas
      ..drawRRect(body, _fillPaint)
      ..drawPath(handlePath, _strokePaint)
      // Linha do cafe (boca da caneca).
      ..drawLine(
        rel(-0.20, -0.18),
        rel(0.15, -0.18),
        _accentStroke..strokeWidth = unit * 0.03,
      );

    // Tres traces sutis sobre o cafe — vapor.
    final vapor = _accentStroke..strokeWidth = unit * 0.018;
    canvas
      ..drawLine(rel(-0.10, -0.36), rel(-0.08, -0.30), vapor)
      ..drawLine(rel(-0.02, -0.38), rel(0, -0.30), vapor)
      ..drawLine(rel(0.08, -0.36), rel(0.10, -0.30), vapor);
  }

  /// Caderno — retangulo com lombada espessa lateral.
  void _paintNotebook(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    _strokePaint.strokeWidth = unit * 0.025;

    // Capa.
    final cover = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rel(-0.28, -0.32).dx,
        rel(-0.28, -0.32).dy,
        rel(0.28, 0.32).dx,
        rel(0.28, 0.32).dy,
      ),
      Radius.circular(unit * 0.03),
    );
    canvas.drawRRect(cover, _fillPaint);

    // Lombada — faixa vertical em accent.
    final spine = Rect.fromLTRB(
      rel(-0.28, -0.32).dx,
      rel(-0.28, -0.32).dy,
      rel(-0.20, 0.32).dx,
      rel(0.20, 0.32).dy,
    );
    canvas.drawRect(spine, _accentFill);

    // Linhas de pagina — tres riscos finos a direita.
    final line = _accentStroke..strokeWidth = unit * 0.012;
    for (var i = -1; i <= 1; i++) {
      final y = i * 0.10;
      canvas.drawLine(rel(-0.05, y), rel(0.18, y), line);
    }

    // Elastico — risco vertical na lateral direita.
    canvas.drawLine(
      rel(0.22, -0.32),
      rel(0.22, 0.32),
      _accentStroke..strokeWidth = unit * 0.02,
    );
  }

  /// Livro de pe — capa retangular com titulo em uma faixa horizontal.
  void _paintBook(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    _strokePaint.strokeWidth = unit * 0.025;

    // Capa retangular em pe (mais alta que larga).
    final cover = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rel(-0.22, -0.35).dx,
        rel(-0.22, -0.35).dy,
        rel(0.22, 0.38).dx,
        rel(0.22, 0.38).dy,
      ),
      Radius.circular(unit * 0.02),
    );
    canvas.drawRRect(cover, _fillPaint);

    // Faixa horizontal de titulo no terco superior.
    final band = Rect.fromLTRB(
      rel(-0.22, -0.05).dx,
      rel(-0.22, -0.05).dy,
      rel(0.22, 0.08).dx,
      rel(0.22, 0.08).dy,
    );
    canvas.drawRect(band, _accentFill);

    // "Linhas" do titulo na faixa.
    final line = _strokePaint..strokeWidth = unit * 0.014;
    canvas
      ..drawLine(rel(-0.16, 0), rel(0.10, 0), line)
      ..drawLine(rel(-0.16, 0.04), rel(0.04, 0.04), line)
      // Marca decorativa no rodape.
      ..drawCircle(rel(0, 0.28), unit * 0.025, _accentFill);
  }

  @override
  bool shouldRepaint(_GaroaProductIllustrationPainter old) {
    return old.category != category ||
        old.foregroundColor != foregroundColor ||
        old.accentColor != accentColor ||
        old.backgroundColor != backgroundColor;
  }
}
