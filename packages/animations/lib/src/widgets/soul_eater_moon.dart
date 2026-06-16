import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lua estilo "Soul Eater": disco creme em crescente, cara sonolenta e
/// sinistra — um olho grande de palpebra pesada, nariz pontudo, sorriso de
/// dentes afiados e sangue pingando da boca. Desenhada em CustomPaint.
class SoulEaterMoon extends StatelessWidget {
  const SoulEaterMoon({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(size: Size.infinite, painter: _SoulEaterMoonPainter()),
    );
  }
}

class _SoulEaterMoonPainter extends CustomPainter {
  const _SoulEaterMoonPainter();

  static const Color _cream = Color(0xFFEDE4C2);
  static const Color _shade = Color(0xFFC9BE96);
  static const Color _dark = Color(0xFF1C1410);
  static const Color _blood = Color(0xFFB01530);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final discR = r * 0.94;
    final p = Paint()..isAntiAlias = true;
    final bounds = Offset.zero & size;

    // --- Disco creme com crescente carvado (transparente) ---
    canvas.saveLayer(bounds, Paint());
    p.shader = RadialGradient(
      colors: const [_cream, _shade],
      stops: const [0.6, 1.0],
      center: const Alignment(-0.3, -0.3),
    ).createShader(Rect.fromCircle(center: c, radius: discR));
    canvas.drawCircle(c, discR, p);
    p.shader = null;
    // Carve do crescente (sombra a direita, transparente).
    p.blendMode = BlendMode.clear;
    canvas.drawCircle(Offset(c.dx + r * 0.66, c.dy - r * 0.08), discR, p);
    p.blendMode = BlendMode.srcOver;
    canvas.restore();

    _face(canvas, c, r, p);
  }

  void _face(Canvas canvas, Offset c, double r, Paint p) {
    // --- Olho grande, palpebra pesada ---
    final eye = Offset(c.dx - r * 0.18, c.dy - r * 0.3);
    final ew = r * 0.5;
    final eh = r * 0.46;
    p.color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: eye, width: ew, height: eh),
      p,
    );
    // Iris + pupila + glint.
    p.color = const Color(0xFF3A2A1A);
    canvas.drawCircle(Offset(eye.dx + r * 0.04, eye.dy + r * 0.04), r * 0.13, p);
    p.color = Colors.black;
    canvas.drawCircle(Offset(eye.dx + r * 0.04, eye.dy + r * 0.04), r * 0.07, p);
    p.color = Colors.white;
    canvas.drawCircle(Offset(eye.dx - r * 0.01, eye.dy - r * 0.01), r * 0.03, p);

    // Palpebra pesada: tampa metade de cima do olho.
    final lid = Path()
      ..addArc(
        Rect.fromCenter(center: eye, width: ew, height: eh),
        math.pi,
        math.pi,
      )
      ..lineTo(eye.dx - ew / 2, eye.dy - eh * 0.18)
      ..quadraticBezierTo(
        eye.dx,
        eye.dy - eh * 0.5,
        eye.dx + ew / 2,
        eye.dy - eh * 0.18,
      )
      ..close();
    p.color = _shade;
    canvas.drawPath(lid, p);

    // Contorno do olho + cilios.
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.025
      ..strokeCap = StrokeCap.round
      ..color = _dark;
    canvas.drawOval(Rect.fromCenter(center: eye, width: ew, height: eh), p);
    for (var i = 0; i < 3; i++) {
      final a = math.pi * (0.62 + i * 0.12);
      final base = Offset(
        eye.dx + math.cos(a) * ew / 2,
        eye.dy + math.sin(a) * eh / 2,
      );
      canvas.drawLine(
        base,
        Offset(base.dx - r * 0.02, base.dy + r * 0.12),
        p,
      );
    }
    // Olheira/bolsa sob o olho.
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(eye.dx, eye.dy + eh * 0.55),
        width: ew * 0.9,
        height: eh * 0.7,
      ),
      0.2,
      math.pi - 0.4,
      false,
      p,
    );
    p.style = PaintingStyle.fill;

    // --- Nariz pontudo ---
    final nose = Path()
      ..moveTo(c.dx - r * 0.16, c.dy + r * 0.06)
      ..lineTo(c.dx - r * 0.42, c.dy + r * 0.2)
      ..lineTo(c.dx - r * 0.14, c.dy + r * 0.22)
      ..close();
    p.color = _shade;
    canvas.drawPath(nose, p);

    // --- Boca: sorriso sinistro com dentes afiados ---
    final mouth = Path()
      ..moveTo(c.dx - r * 0.42, c.dy + r * 0.3)
      ..quadraticBezierTo(
        c.dx - r * 0.05,
        c.dy + r * 0.42,
        c.dx + r * 0.28,
        c.dy + r * 0.28,
      )
      ..quadraticBezierTo(
        c.dx - r * 0.02,
        c.dy + r * 0.66,
        c.dx - r * 0.42,
        c.dy + r * 0.3,
      )
      ..close();
    p.color = _dark;
    canvas
      ..save()
      ..clipPath(mouth)
      ..drawPath(mouth, p);
    // Dentes afiados (triangulos brancos no topo).
    p.color = Colors.white;
    const n = 6;
    for (var i = 0; i < n; i++) {
      final x0 = c.dx - r * 0.42 + (r * 0.7) * (i / n);
      final x1 = c.dx - r * 0.42 + (r * 0.7) * ((i + 1) / n);
      final y = c.dy + r * 0.3 + i * r * 0.005;
      final tooth = Path()
        ..moveTo(x0, y)
        ..lineTo(x1, y)
        ..lineTo((x0 + x1) / 2, y + r * 0.14)
        ..close();
      canvas.drawPath(tooth, p);
    }
    canvas.restore();
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.025
      ..color = _dark;
    canvas.drawPath(mouth, p);
    p.style = PaintingStyle.fill;

    // --- Sangue pingando ---
    p.color = _blood;
    final drips = [
      (Offset(c.dx - r * 0.34, c.dy + r * 0.44), r * 0.22),
      (Offset(c.dx - r * 0.16, c.dy + r * 0.52), r * 0.32),
      (Offset(c.dx + r * 0.02, c.dy + r * 0.46), r * 0.18),
    ];
    for (final (top, len) in drips) {
      final drip = Path()
        ..moveTo(top.dx - r * 0.05, top.dy)
        ..quadraticBezierTo(
          top.dx - r * 0.06,
          top.dy + len * 0.7,
          top.dx,
          top.dy + len,
        )
        ..quadraticBezierTo(
          top.dx + r * 0.06,
          top.dy + len * 0.7,
          top.dx + r * 0.05,
          top.dy,
        )
        ..close();
      canvas.drawPath(drip, p);
    }
    // Gota solta.
    canvas.drawCircle(Offset(c.dx - r * 0.16, c.dy + r * 0.92), r * 0.06, p);
  }

  @override
  bool shouldRepaint(_SoulEaterMoonPainter oldDelegate) => false;
}
