import 'package:flutter/rendering.dart';

class ItalyFlagPainter extends CustomPainter {
  const ItalyFlagPainter();

  static final Paint _green = Paint()..color = const Color(0xFF009246);
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _red = Paint()..color = const Color(0xFFCE2B37);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bandW = w / 3;

    canvas
      ..drawRect(Rect.fromLTWH(0, 0, bandW, h), _green)
      ..drawRect(Rect.fromLTWH(bandW, 0, bandW, h), _white)
      ..drawRect(Rect.fromLTWH(bandW * 2, 0, bandW, h), _red);
  }

  @override
  bool shouldRepaint(covariant ItalyFlagPainter oldDelegate) => false;
}
