import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Avatar do profissional Vitral — circulo colorido com monograma em
/// sans bold no centro. Substitui foto real por composicao geometrica.
class VitralSpecialistAvatar extends StatelessWidget {
  const VitralSpecialistAvatar({
    required this.monogram,
    required this.size,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  /// Iniciais a renderizar (ex.: "SA").
  final String monogram;

  /// Lado do canvas (avatar e circular).
  final double size;

  /// Fundo do circulo — geralmente derivado da categoria do
  /// profissional ou da paleta primaria.
  final Color? backgroundColor;

  /// Cor do monograma.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.primary;
    final fg = foregroundColor ?? scheme.onPrimary;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _VitralSpecialistAvatarPainter(
          monogram: monogram,
          backgroundColor: bg,
          foregroundColor: fg,
        ),
      ),
    );
  }
}

class _VitralSpecialistAvatarPainter extends CustomPainter {
  _VitralSpecialistAvatarPainter({
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
          fontSize: r * 0.7,
          fontWeight: FontWeight.w700,
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
  bool shouldRepaint(_VitralSpecialistAvatarPainter old) {
    return old.monogram != monogram ||
        old.backgroundColor != backgroundColor ||
        old.foregroundColor != foregroundColor;
  }
}
