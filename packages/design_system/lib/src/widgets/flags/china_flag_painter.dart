import 'dart:math' as math;

import 'package:flutter/rendering.dart';

class ChinaFlagPainter extends CustomPainter {
  const ChinaFlagPainter();

  static final Paint _red = Paint()..color = const Color(0xFFDE2910);
  static final Paint _yellow = Paint()..color = const Color(0xFFFFDE00);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _red);

    final bigR = w * 0.14;
    final bigCenter = Offset(w * 0.25, h * 0.3);
    _drawStar(canvas, bigCenter, bigR, _yellow);

    final smallR = w * 0.05;
    final smallCenters = [
      Offset(w * 0.45, h * 0.15),
      Offset(w * 0.52, h * 0.25),
      Offset(w * 0.52, h * 0.38),
      Offset(w * 0.45, h * 0.48),
    ];
    for (final c in smallCenters) {
      _drawStar(canvas, c, smallR, _yellow);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 4 * math.pi / 5;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ChinaFlagPainter oldDelegate) => false;
}
