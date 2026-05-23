import 'package:feature_showcase/src/scheduling/domain/service_category.dart';
import 'package:flutter/material.dart';

/// Ilustracao geometrica por [ServiceCategory] — substitui stock photos
/// nos cards de servico, especialista e detalhe. Sem animacao;
/// `shouldRepaint` so dispara quando categoria ou cores mudam.
class VitralCategoryIllustration extends StatelessWidget {
  const VitralCategoryIllustration({
    required this.category,
    this.foregroundColor,
    this.accentColor,
    super.key,
  });

  final ServiceCategory category;
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
        painter: _VitralCategoryIllustrationPainter(
          category: category,
          foregroundColor: fg,
          accentColor: accent,
        ),
      ),
    );
  }
}

class _VitralCategoryIllustrationPainter extends CustomPainter {
  _VitralCategoryIllustrationPainter({
    required this.category,
    required this.foregroundColor,
    required this.accentColor,
  });

  final ServiceCategory category;
  final Color foregroundColor;
  final Color accentColor;

  late final Paint _fill = Paint()
    ..color = foregroundColor
    ..style = PaintingStyle.fill;

  late final Paint _accentFill = Paint()
    ..color = accentColor
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
    _stroke.strokeWidth = unit * 0.05;
    _accentStroke.strokeWidth = unit * 0.04;
    final cx = size.width / 2;
    final cy = size.height / 2;
    Offset rel(double dx, double dy) => Offset(cx + dx * unit, cy + dy * unit);

    switch (category) {
      case ServiceCategory.consulting:
        _paintConsulting(canvas, rel, unit);
      case ServiceCategory.photography:
        _paintPhotography(canvas, rel, unit);
      case ServiceCategory.design:
        _paintDesign(canvas, rel, unit);
      case ServiceCategory.marketing:
        _paintMarketing(canvas, rel, unit);
    }
  }

  /// Consultoria — duas bolhas de fala sobrepostas.
  void _paintConsulting(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    final bubble1 = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rel(-0.35, -0.30).dx,
        rel(-0.35, -0.30).dy,
        rel(0.10, 0.08).dx,
        rel(0.10, 0.08).dy,
      ),
      Radius.circular(unit * 0.08),
    );
    final bubble2 = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rel(-0.05, -0.05).dx,
        rel(-0.05, -0.05).dy,
        rel(0.40, 0.32).dx,
        rel(0.40, 0.32).dy,
      ),
      Radius.circular(unit * 0.08),
    );

    canvas
      ..drawRRect(bubble1, _fill)
      ..drawRRect(bubble2, _accentFill);

    // Triangulo (rabicho) da bolha 1.
    final tail = Path()
      ..moveTo(rel(-0.28, 0.08).dx, rel(-0.28, 0.08).dy)
      ..lineTo(rel(-0.20, 0.18).dx, rel(-0.20, 0.18).dy)
      ..lineTo(rel(-0.18, 0.08).dx, rel(-0.18, 0.08).dy)
      ..close();
    canvas
      ..drawPath(tail, _fill)
      // Linhas de texto dentro das bolhas.
      ..drawLine(rel(-0.30, -0.20), rel(0, -0.20), _accentStroke)
      ..drawLine(rel(-0.30, -0.10), rel(-0.05, -0.10), _accentStroke)
      ..drawLine(rel(0, 0.10), rel(0.30, 0.10), _stroke)
      ..drawLine(rel(0, 0.20), rel(0.20, 0.20), _stroke);
  }

  /// Fotografia — corpo de camera com lente e botao.
  void _paintPhotography(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rel(-0.36, -0.22).dx,
        rel(-0.36, -0.22).dy,
        rel(0.36, 0.30).dx,
        rel(0.36, 0.30).dy,
      ),
      Radius.circular(unit * 0.05),
    );
    // Visor pequeno em cima.
    final viewfinder = Rect.fromLTRB(
      rel(-0.10, -0.30).dx,
      rel(-0.10, -0.30).dy,
      rel(0.10, -0.22).dx,
      rel(0.10, -0.22).dy,
    );
    canvas
      ..drawRRect(body, _fill)
      ..drawRect(viewfinder, _fill)
      // Lente — circulos concentricos no centro.
      ..drawCircle(rel(0, 0.04), unit * 0.20, _accentFill)
      ..drawCircle(rel(0, 0.04), unit * 0.14, _fill)
      ..drawCircle(rel(0, 0.04), unit * 0.08, _accentFill)
      // Botao disparador (canto superior direito).
      ..drawCircle(rel(0.26, -0.16), unit * 0.04, _accentFill);
  }

  /// Design — paleta com pinceladas circulares.
  void _paintDesign(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    // "Paleta" — meia-lua arredondada (oval + recorte de furo).
    final palette = Path()
      ..addOval(
        Rect.fromCenter(
          center: rel(0, 0.02),
          width: unit * 0.74,
          height: unit * 0.58,
        ),
      )
      ..fillType = PathFillType.evenOdd
      // Furo do dedo no canto superior esquerdo.
      ..addOval(
        Rect.fromCenter(
          center: rel(-0.20, -0.05),
          width: unit * 0.10,
          height: unit * 0.10,
        ),
      );
    canvas
      ..drawPath(palette, _fill)
      // Bolhas de tinta em accent + alpha.
      ..drawCircle(rel(-0.05, -0.05), unit * 0.05, _accentFill)
      ..drawCircle(
        rel(0.10, 0.08),
        unit * 0.06,
        Paint()..color = accentColor.withValues(alpha: 0.7),
      )
      ..drawCircle(
        rel(0.22, -0.08),
        unit * 0.045,
        Paint()..color = accentColor.withValues(alpha: 0.5),
      )
      // Pincel inclinado descendo do canto inferior direito.
      ..save()
      ..translate(rel(0.28, 0.22).dx, rel(0.28, 0.22).dy)
      ..rotate(-0.6)
      ..drawRect(
        Rect.fromLTWH(-unit * 0.04, -unit * 0.18, unit * 0.08, unit * 0.25),
        _fill,
      )
      ..drawRect(
        Rect.fromLTWH(-unit * 0.04, -unit * 0.20, unit * 0.08, unit * 0.04),
        _accentFill,
      )
      ..restore();
  }

  /// Marketing — barras de grafico ascendente com seta de tendencia.
  void _paintMarketing(
    Canvas canvas,
    Offset Function(double, double) rel,
    double unit,
  ) {
    // Quatro barras ascendentes.
    final bars = [(-0.28, 0.10), (-0.10, 0.04), (0.08, -0.05), (0.26, -0.16)];
    for (var i = 0; i < bars.length; i++) {
      final b = bars[i];
      final rect = Rect.fromLTRB(
        rel(b.$1 - 0.05, b.$2).dx,
        rel(b.$1 - 0.05, b.$2).dy,
        rel(b.$1 + 0.05, 0.30).dx,
        rel(b.$1 + 0.05, 0.30).dy,
      );
      canvas.drawRect(rect, i == bars.length - 1 ? _accentFill : _fill);
    }

    // Seta de tendencia em accent passando pelo topo das barras.
    final arrow = Path()
      ..moveTo(rel(-0.30, 0.06).dx, rel(-0.30, 0.06).dy)
      ..lineTo(rel(-0.12, 0).dx, rel(-0.12, 0).dy)
      ..lineTo(rel(0.06, -0.10).dx, rel(0.06, -0.10).dy)
      ..lineTo(rel(0.30, -0.22).dx, rel(0.30, -0.22).dy);
    // Cabeca da seta.
    final head = Path()
      ..moveTo(rel(0.30, -0.22).dx, rel(0.30, -0.22).dy)
      ..lineTo(rel(0.20, -0.18).dx, rel(0.20, -0.18).dy)
      ..moveTo(rel(0.30, -0.22).dx, rel(0.30, -0.22).dy)
      ..lineTo(rel(0.24, -0.30).dx, rel(0.24, -0.30).dy);
    canvas
      ..drawPath(arrow, _accentStroke)
      ..drawPath(head, _accentStroke);
  }

  @override
  bool shouldRepaint(_VitralCategoryIllustrationPainter old) {
    return old.category != category ||
        old.foregroundColor != foregroundColor ||
        old.accentColor != accentColor;
  }
}
