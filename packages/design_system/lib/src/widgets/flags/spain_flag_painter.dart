import 'package:flutter/rendering.dart';

class SpainFlagPainter extends CustomPainter {
  const SpainFlagPainter();

  static final Paint _red = Paint()..color = const Color(0xFFAA151B);
  static final Paint _yellow = Paint()..color = const Color(0xFFF1BF00);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bandH = h / 4;

    canvas
      ..drawRect(Rect.fromLTWH(0, 0, w, bandH), _red)
      ..drawRect(Rect.fromLTWH(0, bandH, w, bandH * 2), _yellow)
      ..drawRect(Rect.fromLTWH(0, bandH * 3, w, bandH), _red);
  }

  @override
  bool shouldRepaint(covariant SpainFlagPainter oldDelegate) => false;
}
