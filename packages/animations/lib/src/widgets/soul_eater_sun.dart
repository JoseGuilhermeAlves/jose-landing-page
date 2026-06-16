import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sol estilo "Soul Eater": disco dourado com sunburst de raios em zigue-zague
/// e uma cara maniaca rindo — olhos arregalados, sobrancelhas inclinadas,
/// bochechas coradas e um sorrisao escancarado cheio de dentes. Desenhado em
/// CustomPaint (paths), pra encaixar como corpo celeste do hero.
class SoulEaterSun extends StatelessWidget {
  const SoulEaterSun({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(size: Size.infinite, painter: _SoulEaterSunPainter()),
    );
  }
}

class _SoulEaterSunPainter extends CustomPainter {
  const _SoulEaterSunPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final p = Paint()..isAntiAlias = true;

    // --- Raios em zigue-zague (sunburst) atras do disco ---
    const spikes = 14;
    final rayOuter = r * 0.99;
    final rayInner = r * 0.7;
    final rays = Path();
    for (var i = 0; i <= spikes * 2; i++) {
      final ang = (i / (spikes * 2)) * 2 * math.pi - math.pi / 2;
      final rad = i.isEven ? rayOuter : rayInner;
      final pt = Offset(c.dx + math.cos(ang) * rad, c.dy + math.sin(ang) * rad);
      i == 0 ? rays.moveTo(pt.dx, pt.dy) : rays.lineTo(pt.dx, pt.dy);
    }
    rays.close();
    p
      ..shader = RadialGradient(
        colors: const [Color(0xFFFFC42E), Color(0xFFFF8A1E)],
      ).createShader(Rect.fromCircle(center: c, radius: rayOuter));
    canvas.drawPath(rays, p);
    p.shader = null;

    final discR = r * 0.7;

    // --- Disco do sol ---
    p.shader = RadialGradient(
      colors: const [Color(0xFFFFF1A6), Color(0xFFFFD23E), Color(0xFFFFA224)],
      stops: const [0.0, 0.55, 1.0],
      center: const Alignment(-0.2, -0.25),
    ).createShader(Rect.fromCircle(center: c, radius: discR));
    canvas.drawCircle(c, discR, p);
    p
      ..shader = null
      ..style = PaintingStyle.stroke
      ..strokeWidth = discR * 0.04
      ..color = const Color(0xFFC8631A);
    canvas.drawCircle(c, discR, p);
    p.style = PaintingStyle.fill;

    _face(canvas, c, discR, p);
  }

  void _face(Canvas canvas, Offset c, double r, Paint p) {
    const black = Color(0xFF2A1606);

    // --- Bochechas coradas ---
    p.color = const Color(0x55FF5A3C);
    canvas
      ..drawCircle(Offset(c.dx - r * 0.52, c.dy + r * 0.18), r * 0.16, p)
      ..drawCircle(Offset(c.dx + r * 0.52, c.dy + r * 0.18), r * 0.16, p);

    // --- Olhos: brancos arregalados + pupila + glint ---
    for (final sx in [-1.0, 1.0]) {
      final eye = Offset(c.dx + sx * r * 0.34, c.dy - r * 0.28);
      p.color = Colors.white;
      canvas.drawOval(
        Rect.fromCenter(
          center: eye,
          width: r * 0.34,
          height: r * 0.44,
        ),
        p,
      );
      p.color = black;
      canvas.drawCircle(
        Offset(eye.dx + sx * r * 0.03, eye.dy + r * 0.05),
        r * 0.1,
        p,
      );
      p.color = Colors.white;
      canvas.drawCircle(
        Offset(eye.dx + sx * r * 0.06, eye.dy + r * 0.01),
        r * 0.035,
        p,
      );
    }

    // --- Sobrancelhas inclinadas (cara maniaca) ---
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round
      ..color = black;
    canvas
      ..drawLine(
        Offset(c.dx - r * 0.56, c.dy - r * 0.56),
        Offset(c.dx - r * 0.2, c.dy - r * 0.42),
        p,
      )
      ..drawLine(
        Offset(c.dx + r * 0.56, c.dy - r * 0.56),
        Offset(c.dx + r * 0.2, c.dy - r * 0.42),
        p,
      );
    p.style = PaintingStyle.fill;

    // --- Boca: sorrisao escancarado com dentes ---
    final mouth = Path()
      ..moveTo(c.dx - r * 0.5, c.dy + r * 0.12)
      ..quadraticBezierTo(
        c.dx,
        c.dy + r * 0.18,
        c.dx + r * 0.5,
        c.dy + r * 0.12,
      )
      ..quadraticBezierTo(
        c.dx + r * 0.34,
        c.dy + r * 0.82,
        c.dx,
        c.dy + r * 0.82,
      )
      ..quadraticBezierTo(
        c.dx - r * 0.34,
        c.dy + r * 0.82,
        c.dx - r * 0.5,
        c.dy + r * 0.12,
      )
      ..close();
    p.color = const Color(0xFF5A0E12);
    canvas
      ..save()
      ..clipPath(mouth)
      ..drawPath(mouth, p);
    // lingua
    p.color = const Color(0xFFE8506A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.74),
        width: r * 0.7,
        height: r * 0.5,
      ),
      p,
    );
    // dentes (faixa branca em zigue-zague no topo da boca)
    final teeth = Path()..moveTo(c.dx - r * 0.5, c.dy + r * 0.12);
    const n = 7;
    for (var i = 0; i <= n; i++) {
      final x = c.dx - r * 0.5 + (r * 1.0) * (i / n);
      final y = c.dy + r * 0.12 + (i.isEven ? 0 : r * 0.16);
      teeth.lineTo(x, y);
    }
    teeth
      ..lineTo(c.dx + r * 0.5, c.dy - r * 0.1)
      ..lineTo(c.dx - r * 0.5, c.dy - r * 0.1)
      ..close();
    p.color = Colors.white;
    canvas
      ..drawPath(teeth, p)
      ..restore();
    // contorno da boca
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.05
      ..color = black;
    canvas.drawPath(mouth, p);
    p.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(_SoulEaterSunPainter oldDelegate) => false;
}
