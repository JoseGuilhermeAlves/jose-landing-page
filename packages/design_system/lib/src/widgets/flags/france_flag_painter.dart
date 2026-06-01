import 'package:flutter/rendering.dart';

class FranceFlagPainter extends CustomPainter {
  const FranceFlagPainter();

  static final Paint _blue = Paint()..color = const Color(0xFF0055A4);
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _red = Paint()..color = const Color(0xFFEF4135);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bandW = w / 3;

    canvas
      ..drawRect(Rect.fromLTWH(0, 0, bandW, h), _blue)
      ..drawRect(Rect.fromLTWH(bandW, 0, bandW, h), _white)
      ..drawRect(Rect.fromLTWH(bandW * 2, 0, bandW, h), _red);
  }

  @override
  bool shouldRepaint(covariant FranceFlagPainter oldDelegate) => false;
}
