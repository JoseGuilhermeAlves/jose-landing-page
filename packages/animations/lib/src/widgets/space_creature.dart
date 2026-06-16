import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Criaturas/objetos espaciais desenhados em CustomPainter — usados como
/// "corpos" do mapa de dominios (em vez de planetas), pra deixar a cena mais
/// variada e divertida: disco voador, alien, beholder, meteoro e satelite.
/// Cada uma preenche a caixa dada; estaticas (nao animam).
enum SpaceCreature { ufo, alien, beholder, meteor, satellite }

class SpaceCreatureView extends StatelessWidget {
  const SpaceCreatureView({required this.creature, super.key});

  final SpaceCreature creature;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: SpaceCreaturePainter(creature),
      ),
    );
  }
}

class SpaceCreaturePainter extends CustomPainter {
  const SpaceCreaturePainter(this.creature);

  final SpaceCreature creature;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final p = Paint()..isAntiAlias = true;
    switch (creature) {
      case SpaceCreature.ufo:
        _ufo(canvas, c, r, p);
      case SpaceCreature.alien:
        _alien(canvas, c, r, p);
      case SpaceCreature.beholder:
        _beholder(canvas, c, r, p);
      case SpaceCreature.meteor:
        _meteor(canvas, c, r, p);
      case SpaceCreature.satellite:
        _satellite(canvas, c, r, p);
    }
  }

  // --- Disco voador: feixe + corpo metalico + domo + luzes neon ---
  void _ufo(Canvas canvas, Offset c, double r, Paint p) {
    // Feixe de abducao.
    final beam = Path()
      ..moveTo(c.dx - r * 0.22, c.dy + r * 0.1)
      ..lineTo(c.dx - r * 0.6, c.dy + r * 0.9)
      ..lineTo(c.dx + r * 0.6, c.dy + r * 0.9)
      ..lineTo(c.dx + r * 0.22, c.dy + r * 0.1)
      ..close();
    p.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF36E0FF).withValues(alpha: 0.45),
        const Color(0xFF36E0FF).withValues(alpha: 0),
      ],
    ).createShader(Rect.fromLTWH(c.dx - r * 0.6, c.dy, r * 1.2, r * 0.9));
    canvas.drawPath(beam, p);
    p.shader = null;

    // Domo (vidro ciano).
    final domeRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy - r * 0.16),
      width: r * 0.9,
      height: r * 0.8,
    );
    p.shader = RadialGradient(
      colors: const [Color(0xFFCDF7FF), Color(0xFF3FB6D8)],
      center: const Alignment(-0.3, -0.4),
    ).createShader(domeRect);
    canvas.drawArc(domeRect, math.pi, math.pi, true, p);
    p.shader = null;

    // Corpo (saucer) metalico.
    final body = Rect.fromCenter(
      center: Offset(c.dx, c.dy + r * 0.02),
      width: r * 1.9,
      height: r * 0.66,
    );
    p.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFB9C6D6), Color(0xFF5A6B82), Color(0xFF2E3950)],
    ).createShader(body);
    canvas.drawOval(body, p);
    p.shader = null;

    // Luzes neon na borda.
    const lights = [Color(0xFFFF3CAC), Color(0xFF36E0FF), Color(0xFFFFD23E)];
    for (var i = 0; i < 5; i++) {
      final t = i / 4;
      final x = c.dx - r * 0.78 + r * 1.56 * t;
      p.color = lights[i % lights.length];
      canvas.drawCircle(Offset(x, c.dy + r * 0.14), r * 0.09, p);
    }
  }

  // --- Alien classico: cabeca verde + olhos amendoados ---
  void _alien(Canvas canvas, Offset c, double r, Paint p) {
    final head = Path()
      ..moveTo(c.dx, c.dy + r * 0.9)
      ..cubicTo(
        c.dx - r * 1.0, c.dy + r * 0.2,
        c.dx - r * 0.86, c.dy - r * 0.9,
        c.dx, c.dy - r * 0.86,
      )
      ..cubicTo(
        c.dx + r * 0.86, c.dy - r * 0.9,
        c.dx + r * 1.0, c.dy + r * 0.2,
        c.dx, c.dy + r * 0.9,
      )
      ..close();
    p.shader = RadialGradient(
      colors: const [Color(0xFFB6FF8E), Color(0xFF4FBF4A), Color(0xFF2C7A33)],
      stops: const [0.0, 0.6, 1.0],
      center: const Alignment(-0.2, -0.3),
    ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawPath(head, p);
    p
      ..shader = null
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03
      ..color = const Color(0xFF205226);
    canvas.drawPath(head, p);
    p.style = PaintingStyle.fill;

    // Olhos amendoados pretos com glint.
    for (final sx in [-1.0, 1.0]) {
      canvas
        ..save()
        ..translate(c.dx + sx * r * 0.34, c.dy - r * 0.02)
        ..rotate(sx * 0.5);
      p.color = Colors.black;
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: r * 0.34, height: r * 0.6),
        p,
      );
      p.color = Colors.white.withValues(alpha: 0.85);
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(0, -8),
          width: r * 0.1,
          height: r * 0.2,
        ),
        p,
      );
      canvas.restore();
    }
    // Narinas + boca fina.
    p
      ..color = const Color(0xFF205226)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(c.dx - r * 0.16, c.dy + r * 0.5),
      Offset(c.dx + r * 0.16, c.dy + r * 0.5),
      p,
    );
    p.style = PaintingStyle.fill;
  }

  // --- Beholder: esfera + olho central + tentaculos-olho + boca dentada ---
  void _beholder(Canvas canvas, Offset c, double r, Paint p) {
    // Tentaculos com olhinhos.
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF7A2E9E);
    final eyeTips = <Offset>[];
    for (var i = 0; i < 5; i++) {
      final ang = -math.pi / 2 + (i - 2) * 0.5;
      final tip = Offset(
        c.dx + math.cos(ang) * r * 0.95,
        c.dy + math.sin(ang) * r * 0.95,
      );
      final ctrl = Offset(
        c.dx + math.cos(ang) * r * 0.5 + (i.isEven ? r * 0.12 : -r * 0.12),
        c.dy + math.sin(ang) * r * 0.5,
      );
      final path = Path()
        ..moveTo(c.dx + math.cos(ang) * r * 0.5, c.dy + math.sin(ang) * r * 0.5)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);
      canvas.drawPath(path, p);
      eyeTips.add(tip);
    }
    p.style = PaintingStyle.fill;
    for (final tip in eyeTips) {
      p.color = const Color(0xFFFFE36A);
      canvas.drawCircle(tip, r * 0.1, p);
      p.color = Colors.black;
      canvas.drawCircle(tip, r * 0.045, p);
    }

    // Corpo esferico.
    p.shader = RadialGradient(
      colors: const [Color(0xFFC04FE0), Color(0xFF7A1E9E), Color(0xFF3A0E52)],
      stops: const [0.0, 0.6, 1.0],
      center: const Alignment(-0.3, -0.3),
    ).createShader(Rect.fromCircle(center: c, radius: r * 0.66));
    canvas.drawCircle(c, r * 0.66, p);
    p.shader = null;

    // Olho central.
    final eye = Offset(c.dx, c.dy - r * 0.12);
    p.color = Colors.white;
    canvas.drawCircle(eye, r * 0.3, p);
    p.color = const Color(0xFF1EA0C0);
    canvas.drawCircle(eye, r * 0.16, p);
    p.color = Colors.black;
    canvas.drawCircle(eye, r * 0.08, p);
    p.color = Colors.white;
    canvas.drawCircle(Offset(eye.dx - r * 0.04, eye.dy - r * 0.04), r * 0.03, p);

    // Boca dentada (faixa larga em baixo).
    final mouth = Path()
      ..moveTo(c.dx - r * 0.42, c.dy + r * 0.3)
      ..quadraticBezierTo(c.dx, c.dy + r * 0.42, c.dx + r * 0.42, c.dy + r * 0.3)
      ..quadraticBezierTo(c.dx, c.dy + r * 0.6, c.dx - r * 0.42, c.dy + r * 0.3)
      ..close();
    p.color = const Color(0xFF1A0510);
    canvas
      ..save()
      ..clipPath(mouth)
      ..drawPath(mouth, p);
    p.color = Colors.white;
    for (var i = 0; i < 6; i++) {
      final x0 = c.dx - r * 0.42 + (r * 0.84) * (i / 6);
      final x1 = c.dx - r * 0.42 + (r * 0.84) * ((i + 1) / 6);
      final tooth = Path()
        ..moveTo(x0, c.dy + r * 0.3)
        ..lineTo(x1, c.dy + r * 0.3)
        ..lineTo((x0 + x1) / 2, c.dy + r * 0.44)
        ..close();
      canvas.drawPath(tooth, p);
    }
    canvas.restore();
  }

  // --- Meteoro: rocha irregular com crateras + rastro de fogo ---
  void _meteor(Canvas canvas, Offset c, double r, Paint p) {
    // Rastro de fogo (atras, vindo do canto superior-direito).
    final trail = Path()
      ..moveTo(c.dx + r * 0.2, c.dy - r * 0.5)
      ..lineTo(c.dx + r * 1.1, c.dy - r * 1.1)
      ..lineTo(c.dx + r * 0.7, c.dy + r * 0.1)
      ..close();
    p.shader = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        const Color(0xFFFFE36A).withValues(alpha: 0.9),
        const Color(0xFFFF6A1E).withValues(alpha: 0.6),
        const Color(0xFFFF2E5A).withValues(alpha: 0),
      ],
    ).createShader(Rect.fromLTWH(c.dx, c.dy - r * 1.1, r * 1.1, r * 1.2));
    canvas.drawPath(trail, p);
    p.shader = null;

    // Rocha irregular (poligono seed-fixo).
    final rng = math.Random(42);
    final rock = Path();
    const n = 11;
    for (var i = 0; i <= n; i++) {
      final ang = (i / n) * 2 * math.pi;
      final rad = r * (0.6 + rng.nextDouble() * 0.22);
      final pt = Offset(c.dx + math.cos(ang) * rad, c.dy + math.sin(ang) * rad);
      i == 0 ? rock.moveTo(pt.dx, pt.dy) : rock.lineTo(pt.dx, pt.dy);
    }
    rock.close();
    p.shader = RadialGradient(
      colors: const [Color(0xFF8A7A6E), Color(0xFF5A4A42), Color(0xFF2E2420)],
      stops: const [0.0, 0.6, 1.0],
      center: const Alignment(-0.4, -0.4),
    ).createShader(Rect.fromCircle(center: c, radius: r * 0.8));
    canvas.drawPath(rock, p);
    p.shader = null;

    // Borda de fogo no lado que "queima".
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..color = const Color(0xFFFF8A2E).withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(rock, p);
    p
      ..style = PaintingStyle.fill
      ..maskFilter = null;

    // Crateras.
    p.color = const Color(0xFF2E2420);
    for (final (dx, dy, cr) in [
      (-0.2, -0.1, 0.16),
      (0.18, 0.22, 0.12),
      (-0.05, 0.3, 0.09),
    ]) {
      canvas.drawCircle(Offset(c.dx + r * dx, c.dy + r * dy), r * cr, p);
    }
  }

  // --- Satelite: corpo + paineis solares + antena/dish ---
  void _satellite(Canvas canvas, Offset c, double r, Paint p) {
    // Paineis solares (asas).
    void panel(double sign) {
      final rect = Rect.fromCenter(
        center: Offset(c.dx + sign * r * 0.62, c.dy),
        width: r * 0.7,
        height: r * 0.9,
      );
      p.color = const Color(0xFF1E3A6E);
      canvas.drawRect(rect, p);
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF5AC8FF);
      for (var i = 1; i < 3; i++) {
        final x = rect.left + rect.width * i / 3;
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), p);
      }
      for (var i = 1; i < 4; i++) {
        final y = rect.top + rect.height * i / 4;
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), p);
      }
      p.style = PaintingStyle.fill;
    }

    panel(-1);
    panel(1);

    // Corpo central (caixa metalica).
    final body = Rect.fromCenter(
      center: c,
      width: r * 0.5,
      height: r * 0.7,
    );
    p.shader = const LinearGradient(
      colors: [Color(0xFFD6DEE8), Color(0xFF8A97A8)],
    ).createShader(body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(r * 0.06)),
      p,
    );
    p.shader = null;

    // Antena.
    p
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04
      ..color = const Color(0xFFB9C6D6);
    canvas.drawLine(
      Offset(c.dx, c.dy - r * 0.35),
      Offset(c.dx + r * 0.1, c.dy - r * 0.7),
      p,
    );
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFFFF3CAC);
    canvas.drawCircle(Offset(c.dx + r * 0.1, c.dy - r * 0.7), r * 0.06, p);

    // Dish parabolica.
    p.color = const Color(0xFFE8EEF6);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + r * 0.42),
        width: r * 0.5,
        height: r * 0.4,
      ),
      math.pi,
      math.pi,
      true,
      p,
    );
  }

  @override
  bool shouldRepaint(SpaceCreaturePainter old) => old.creature != creature;
}
