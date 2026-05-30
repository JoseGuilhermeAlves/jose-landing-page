import 'package:flutter/rendering.dart';

class GermanyFlagPainter extends CustomPainter {
  const GermanyFlagPainter();

  static final Paint _black = Paint()..color = const Color(0xFF000000);
  static final Paint _red = Paint()..color = const Color(0xFFDD0000);
  static final Paint _gold = Paint()..color = const Color(0xFFFFCC00);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bandH = h / 3;

    canvas
      ..drawRect(Rect.fromLTWH(0, 0, w, bandH), _black)
      ..drawRect(Rect.fromLTWH(0, bandH, w, bandH), _red)
      ..drawRect(Rect.fromLTWH(0, bandH * 2, w, bandH), _gold);
  }

  @override
  bool shouldRepaint(covariant GermanyFlagPainter oldDelegate) => false;
}
