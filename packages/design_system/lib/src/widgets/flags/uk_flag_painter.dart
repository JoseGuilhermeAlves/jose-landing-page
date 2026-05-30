import 'package:flutter/rendering.dart';

class UkFlagPainter extends CustomPainter {
  const UkFlagPainter();

  static final Paint _blue = Paint()..color = const Color(0xFF012169);
  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _red = Paint()..color = const Color(0xFFC8102E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _blue);

    final diagW = w * 0.18;
    final diagNarrow = w * 0.06;

    // White diagonals
    _drawLine(canvas, 0, 0, w, h, diagW, _white);
    _drawLine(canvas, w, 0, 0, h, diagW, _white);

    // Red diagonals (thinner)
    _drawLine(canvas, 0, 0, w, h, diagNarrow, _red);
    _drawLine(canvas, w, 0, 0, h, diagNarrow, _red);

    // White cross
    final crossW = w * 0.22;
    canvas
      ..drawRect(Rect.fromCenter(center: Offset(cx, cy), width: crossW, height: h), _white)
      ..drawRect(Rect.fromCenter(center: Offset(cx, cy), width: w, height: crossW), _white);

    // Red cross
    final crossN = w * 0.12;
    canvas
      ..drawRect(Rect.fromCenter(center: Offset(cx, cy), width: crossN, height: h), _red)
      ..drawRect(Rect.fromCenter(center: Offset(cx, cy), width: w, height: crossN), _red);
  }

  void _drawLine(Canvas canvas, double x1, double y1, double x2, double y2, double width, Paint paint) {
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      paint..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(covariant UkFlagPainter oldDelegate) => false;
}
