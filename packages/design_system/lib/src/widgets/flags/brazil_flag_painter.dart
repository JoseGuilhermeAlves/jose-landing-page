import 'dart:math' as math;

import 'package:flutter/rendering.dart';

class BrazilFlagPainter extends CustomPainter {
  const BrazilFlagPainter();

  static final Paint _green = Paint()..color = const Color(0xFF009739);
  static final Paint _yellow = Paint()..color = const Color(0xFFFEDD00);
  static final Paint _blue = Paint()..color = const Color(0xFF002776);
  static final Paint _white = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _green);

    canvas
      ..save()
      ..translate(cx, cy)
      ..rotate(math.pi / 4);
    final diamondSize = w * 0.34;
    canvas
      ..drawRect(
        Rect.fromCenter(center: Offset.zero, width: diamondSize * 2, height: diamondSize * 1.3),
        _yellow,
      )
      ..restore();

    final circleRadius = w * 0.18;
    canvas.drawCircle(Offset(cx, cy), circleRadius, _blue);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: circleRadius * 0.85),
      0.15,
      math.pi * 0.7,
      false,
      _white,
    );
  }

  @override
  bool shouldRepaint(covariant BrazilFlagPainter oldDelegate) => false;
}
