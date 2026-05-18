import 'dart:math' as math;

import 'package:feature_showcase/src/presentation/realestate/solar_brand.dart';
import 'package:flutter/material.dart';

/// Avatar do corretor Solar — circulo terracota com monograma em serif
/// no centro. Substitui foto real por composicao geometrica; o serif
/// reforca o ar de "revista de arquitetura" da marca.
///
/// Performance: paint cacheado e `shouldRepaint` confrontando campos
/// reais. Vive em `RepaintBoundary` no proprio widget.
class SolarBrokerAvatar extends StatelessWidget {
  const SolarBrokerAvatar({
    required this.monogram,
    required this.size,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  /// Iniciais a renderizar (ex.: "ML").
  final String monogram;

  /// Lado do canvas (avatar e circular).
  final double size;

  /// Fundo do circulo — geralmente primary (terracota) da paleta.
  final Color? backgroundColor;

  /// Cor do monograma — geralmente onPrimary (creme).
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.primary;
    final fg = foregroundColor ?? scheme.onPrimary;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _SolarBrokerAvatarPainter(
          monogram: monogram,
          backgroundColor: bg,
          foregroundColor: fg,
        ),
      ),
    );
  }
}

class _SolarBrokerAvatarPainter extends CustomPainter {
  _SolarBrokerAvatarPainter({
    required this.monogram,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String monogram;
  final Color backgroundColor;
  final Color foregroundColor;

  late final Paint _bgPaint = Paint()
    ..color = backgroundColor
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy);

    canvas.drawCircle(Offset(cx, cy), r, _bgPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: monogram,
        style: TextStyle(
          color: foregroundColor,
          fontFamily: SolarBrand.displayFontFamily,
          fontSize: r * 0.7,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    final offset = Offset(
      cx - textPainter.width / 2,
      cy - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_SolarBrokerAvatarPainter old) {
    return old.monogram != monogram ||
        old.backgroundColor != backgroundColor ||
        old.foregroundColor != foregroundColor;
  }
}
