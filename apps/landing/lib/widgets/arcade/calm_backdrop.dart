import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fundo global da landing: cor solida + duas luzes neon muito difusas +
/// um campo de estrelas fraco e ESTATICO. Substitui o grid Outrun animado
/// que ficava atras de todas as secoes (as linhas cruzavam o texto e
/// prejudicavam a leitura). O grid agora vive so no chao do hero.
///
/// Sem animacao: pinta uma vez e fica em cache no `RepaintBoundary`.
class CalmBackdrop extends StatelessWidget {
  const CalmBackdrop({
    required this.background,
    required this.glowA,
    required this.glowB,
    required this.starColor,
    super.key,
  });

  final Color background;
  final Color glowA;
  final Color glowB;
  final Color starColor;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _CalmBackdropPainter(
          background: background,
          glowA: glowA,
          glowB: glowB,
          starColor: starColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _CalmBackdropPainter extends CustomPainter {
  _CalmBackdropPainter({
    required this.background,
    required this.glowA,
    required this.glowB,
    required this.starColor,
  });

  final Color background;
  final Color glowA;
  final Color glowB;
  final Color starColor;

  static const int _starCount = 120;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = background);

    void glow(Offset center, double radius, Color color, double alpha) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    final r = math.max(size.width, size.height);
    glow(Offset(size.width * 0.12, -size.height * 0.05), r * 0.55, glowA, 0.10);
    glow(Offset(size.width * 0.95, size.height * 1.05), r * 0.6, glowB, 0.08);

    final rng = math.Random(4242);
    final paint = Paint();
    for (var i = 0; i < _starCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = rng.nextDouble() < 0.85 ? 1.0 : 2.0;
      paint.color = starColor.withValues(alpha: 0.12 + rng.nextDouble() * 0.28);
      canvas.drawRect(
        Rect.fromLTWH(x.roundToDouble(), y.roundToDouble(), s, s),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CalmBackdropPainter old) =>
      old.background != background ||
      old.glowA != glowA ||
      old.glowB != glowB ||
      old.starColor != starColor;
}
