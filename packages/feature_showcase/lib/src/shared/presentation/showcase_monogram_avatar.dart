import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Avatar de monograma compartilhado pelos mocks (Vitral, Solar) —
/// circulo colorido com iniciais desenhadas via `TextPainter`.
/// Substitui foto real por composicao geometrica; cada marca ajusta
/// tipografia via `fontFamily`/`fontWeight` (Solar usa serif w600 pra
/// reforcar o ar de revista de arquitetura, Vitral usa sans w700).
///
/// Performance: paint e TextPainter cacheados no painter (texto e
/// estatico por instancia) e `shouldRepaint` confronta campos reais.
/// Vive em `RepaintBoundary` no proprio widget.
class ShowcaseMonogramAvatar extends StatelessWidget {
  const ShowcaseMonogramAvatar({
    required this.monogram,
    required this.size,
    this.backgroundColor,
    this.foregroundColor,
    this.fontFamily,
    this.fontWeight = FontWeight.w700,
    super.key,
  });

  /// Iniciais a renderizar (ex.: "ML").
  final String monogram;

  /// Lado do canvas (avatar e circular).
  final double size;

  /// Fundo do circulo — geralmente primary da paleta.
  final Color? backgroundColor;

  /// Cor do monograma — geralmente onPrimary.
  final Color? foregroundColor;

  /// Familia tipografica do monograma (null = default do tema).
  final String? fontFamily;

  /// Peso do monograma.
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? scheme.primary;
    final fg = foregroundColor ?? scheme.onPrimary;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _ShowcaseMonogramAvatarPainter(
          monogram: monogram,
          backgroundColor: bg,
          foregroundColor: fg,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

class _ShowcaseMonogramAvatarPainter extends CustomPainter {
  _ShowcaseMonogramAvatarPainter({
    required this.monogram,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.fontFamily,
    required this.fontWeight,
  });

  final String monogram;
  final Color backgroundColor;
  final Color foregroundColor;
  final String? fontFamily;
  final FontWeight fontWeight;

  late final Paint _bgPaint = Paint()
    ..color = backgroundColor
    ..style = PaintingStyle.fill;

  // TextPainter cacheado — texto/estilo so dependem do raio, entao
  // relayout acontece apenas quando o tamanho muda.
  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  double _layoutRadius = -1;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy);

    canvas.drawCircle(Offset(cx, cy), r, _bgPaint);

    if (r != _layoutRadius) {
      _layoutRadius = r;
      _textPainter
        ..text = TextSpan(
          text: monogram,
          style: TextStyle(
            color: foregroundColor,
            fontFamily: fontFamily,
            fontSize: r * 0.7,
            fontWeight: fontWeight,
            letterSpacing: 0.5,
          ),
        )
        ..layout();
    }
    _textPainter.paint(
      canvas,
      Offset(cx - _textPainter.width / 2, cy - _textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_ShowcaseMonogramAvatarPainter old) {
    return old.monogram != monogram ||
        old.backgroundColor != backgroundColor ||
        old.foregroundColor != foregroundColor ||
        old.fontFamily != fontFamily ||
        old.fontWeight != fontWeight;
  }
}
