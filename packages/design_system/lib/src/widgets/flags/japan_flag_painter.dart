import 'package:flutter/rendering.dart';

class JapanFlagPainter extends CustomPainter {
  const JapanFlagPainter();

  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _red = Paint()..color = const Color(0xFFBC002D);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _white);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.28, _red);
  }

  @override
  bool shouldRepaint(covariant JapanFlagPainter oldDelegate) => false;
}
