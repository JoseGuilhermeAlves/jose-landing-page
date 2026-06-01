import 'package:flutter/rendering.dart';

class RussiaFlagPainter extends CustomPainter {
  const RussiaFlagPainter();

  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _blue = Paint()..color = const Color(0xFF0039A6);
  static final Paint _red = Paint()..color = const Color(0xFFD52B1E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bandH = h / 3;

    canvas
      ..drawRect(Rect.fromLTWH(0, 0, w, bandH), _white)
      ..drawRect(Rect.fromLTWH(0, bandH, w, bandH), _blue)
      ..drawRect(Rect.fromLTWH(0, bandH * 2, w, bandH), _red);
  }

  @override
  bool shouldRepaint(covariant RussiaFlagPainter oldDelegate) => false;
}
