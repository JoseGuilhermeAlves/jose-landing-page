import 'package:flutter/material.dart';

/// Monograma "JGA" desenhado com Path geometrico — substituto do
/// avatar fotografico removido da bio. Sao 3 traços encadeados que
/// sugerem as iniciais sem soletra-las. Pintado em [color] com
/// [strokeWidth] sobre o canto da bio card. Acompanha o ritmo visual
/// do brand sem virar logo formal.
///
/// Construcao das paths e cacheada no construtor — o canvas so
/// `drawPath` por chamada. `shouldRepaint` compara cor + stroke
/// (o resto e geometria estatica).
class JgaMonogramPainter extends CustomPainter {
  JgaMonogramPainter({required this.color, this.strokeWidth = 2});

  final Color color;
  final double strokeWidth;

  late final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true
    ..color = color
    ..strokeWidth = strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    // J — comeca topo, desce ate ~80%, curva esquerda.
    final j = Path()
      ..moveTo(w * 0.18, h * 0.05)
      ..lineTo(w * 0.18, h * 0.72)
      ..quadraticBezierTo(w * 0.18, h * 0.92, w * 0.05, h * 0.92);

    // G — circulo aberto que se conecta ao centro com tracinho
    // horizontal pra dentro.
    final g = Path()
      ..moveTo(w * 0.55, h * 0.18)
      ..quadraticBezierTo(w * 0.30, h * 0.18, w * 0.30, h * 0.50)
      ..quadraticBezierTo(w * 0.30, h * 0.82, w * 0.55, h * 0.82)
      ..quadraticBezierTo(w * 0.68, h * 0.82, w * 0.68, h * 0.66)
      ..lineTo(w * 0.50, h * 0.66);

    // A — triangulo aberto com barra horizontal.
    final a = Path()
      ..moveTo(w * 0.70, h * 0.95)
      ..lineTo(w * 0.85, h * 0.05)
      ..lineTo(w * 1.00, h * 0.95)
      ..moveTo(w * 0.76, h * 0.62)
      ..lineTo(w * 0.94, h * 0.62);

    canvas
      ..drawPath(j, _strokePaint)
      ..drawPath(g, _strokePaint)
      ..drawPath(a, _strokePaint);
  }

  @override
  bool shouldRepaint(covariant JgaMonogramPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;

  bool get isComplex => false;

  bool get willChange => false;
}
