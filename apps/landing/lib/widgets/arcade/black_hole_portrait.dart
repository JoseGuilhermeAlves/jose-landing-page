import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Retrato do Jose dentro de um buraco negro pixel-art — o centerpiece do
/// hero Arcade. Um disco de acrecao de blocos quadrados gira em torno do
/// horizonte de eventos (escuro), com a metade de tras desenhada antes da
/// foto e a da frente depois (efeito de lente). A foto
/// (`foto_recortada.webp`) e renderizada **pixel perfect**: decodificada
/// em baixa resolucao (`cacheWidth`) e ampliada com `FilterQuality.none`
/// (nearest-neighbor), batendo com a estetica 8/16-bit.
class BlackHolePortrait extends StatefulWidget {
  const BlackHolePortrait({
    required this.diskHot,
    required this.diskCool,
    required this.size,
    super.key,
  });

  /// Cor quente do disco (interno) — magenta neon.
  final Color diskHot;

  /// Cor fria do disco (externo) — ciano neon.
  final Color diskCool;

  final double size;

  @override
  State<BlackHolePortrait> createState() => _BlackHolePortraitState();
}

class _BlackHolePortraitState extends State<BlackHolePortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Rotacao lenta do disco — uma volta a cada 14s.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Diametro do horizonte (onde a foto vive) ~ 46% do tamanho total.
    final horizon = widget.size * 0.46;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          // Metade de tras do disco + glow.
          painter: _AccretionPainter(
            animation: _controller,
            hot: widget.diskHot,
            cool: widget.diskCool,
            front: false,
          ),
          // Metade da frente do disco + photon ring (sobre a foto).
          foregroundPainter: _AccretionPainter(
            animation: _controller,
            hot: widget.diskHot,
            cool: widget.diskCool,
            front: true,
          ),
          child: Center(
            child: SizedBox.square(
              dimension: horizon,
              child: ClipOval(
                child: ColoredBox(
                  color: const Color(0xFF05030A),
                  child: Image.asset(
                    'assets/images/foto_recortada.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    // Pixel perfect: decodifica pequeno + amplia nearest.
                    cacheWidth: 88,
                    filterQuality: FilterQuality.none,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Desenha metade do disco de acrecao (back ou front) como blocos
/// quadrados numa elipse achatada (tilt). Brilho combina raio (mais quente
/// dentro), Doppler (um lado mais claro) e a fase de rotacao.
class _AccretionPainter extends CustomPainter {
  _AccretionPainter({
    required Animation<double> animation,
    required this.hot,
    required this.cool,
    required this.front,
  }) : _animation = animation,
       _block = Paint()..isAntiAlias = false,
       super(repaint: animation);

  final Animation<double> _animation;
  final Color hot;
  final Color cool;
  final Paint _block;

  /// true = metade frontal (sin > 0, desenhada sobre a foto).
  final bool front;

  /// Achatamento vertical do disco (tilt).
  static const double _tiltY = 0.34;

  /// Direcao da luz pros mini-planetas (upper-left), normalizada.
  static const _lx = -0.57;
  static const _ly = -0.63;
  static const _lz = 0.53;

  /// Planetas em orbita: (raio rel ao R, tamanho rel, velocidade, fase,
  /// paleta 5 cores shadow->light). Raios diferentes pra dar parallax.
  static const List<_Orbit> _orbits = [
    _Orbit(0.64, 0.062, 1, 0, [
      Color(0xFF0A2E33),
      Color(0xFF0E6B6B),
      Color(0xFF12B5A6),
      Color(0xFF49E0C0),
      Color(0xFFB8FFF0),
    ]),
    _Orbit(0.80, 0.05, -0.7, 2.1, [
      Color(0xFF3A0A2A),
      Color(0xFF7A1452),
      Color(0xFFC0307E),
      Color(0xFFF26AAE),
      Color(0xFFFFD0EA),
    ]),
    _Orbit(0.95, 0.075, 0.55, 4, [
      Color(0xFF332300),
      Color(0xFF6B4A00),
      Color(0xFFB5860A),
      Color(0xFFE0B33E),
      Color(0xFFFFEDB8),
    ]),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final horizon = r * 0.46;
    final phase = _animation.value * 2 * math.pi;
    // Bloco pixel: lado fixo proporcional, sem AA.
    final pb = (r * 0.052).clamp(3.0, 9.0);

    // Glow do disco (so na passada de tras, atras de tudo).
    if (!front) {
      final glow = Paint()
        ..color = hot.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(center, r * 0.8, glow);
    }

    // Aneis concentricos de blocos, do horizonte ate a borda.
    final innerR = horizon * 1.04;
    final outerR = r * 0.99;
    for (var ringR = innerR; ringR <= outerR; ringR += pb) {
      // Densidade angular proporcional ao raio (mais blocos fora).
      final steps = (ringR * 2 * math.pi / pb).round().clamp(24, 220);
      for (var i = 0; i < steps; i++) {
        final a = (i / steps) * 2 * math.pi;
        final sin = math.sin(a);
        // Separa metade frente/tras pela posicao vertical aparente.
        final isFront = sin > 0;
        if (isFront != front) continue;

        final x = center.dx + math.cos(a) * ringR;
        final y = center.dy + sin * ringR * _tiltY;

        // Brilho: radial (inner quente) + doppler (cos) + swirl girando.
        final radial = 1 - ((ringR - innerR) / (outerR - innerR)).clamp(0, 1);
        final doppler = 0.5 + 0.5 * math.cos(a - 0.6);
        final swirl = 0.5 + 0.5 * math.sin(a * 3 - phase);
        final bright = (radial * 0.5 + doppler * 0.32 + swirl * 0.18).clamp(
          0.0,
          1.0,
        );

        // Gap radial entre alguns aneis pra dar leitura de "faixas".
        if (swirl < 0.18 && radial < 0.5) continue;

        final color = _shade(bright);
        _block
          ..color = color
          ..maskFilter = null;
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: pb + 0.5,
            height: pb + 0.5,
          ),
          _block,
        );
      }
    }

    // Planetas em orbita — desenhados na passada (frente/tras) que casa
    // com a posicao vertical aparente de cada um.
    for (final o in _orbits) {
      final a = o.offset + phase * o.speed;
      final sin = math.sin(a);
      if ((sin > 0) != front) continue;
      final cx = center.dx + math.cos(a) * (r * o.orbit);
      final cy = center.dy + sin * (r * o.orbit) * _tiltY;
      _paintMiniPlanet(canvas, Offset(cx, cy), r * o.size, o.palette);
    }

    // Photon ring: aro fino brilhante no horizonte (passada da frente).
    if (front) {
      // Aro crisp (sem blur — formas pixel-perfect; bloom fica so no glow).
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (pb * 0.6).clamp(2.0, 5.0)
        ..isAntiAlias = false
        ..color = Colors.white.withValues(alpha: 0.85);
      canvas.drawCircle(center, horizon * 1.02, ring);
    }
  }

  /// Mini-planeta pixel: esfera em grid de blocos, sombreamento lambert
  /// quantizado na paleta + outline. Mesma gramatica dos planetas da secao
  /// Sobre, em escala menor.
  void _paintMiniPlanet(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> palette,
  ) {
    final grid = ((radius * 2) / 4).round().clamp(7, 12);
    final px = (radius * 2) / grid;
    final origin = Offset(center.dx - radius, center.dy - radius);
    final edgeBand = 1 - (2.4 / grid);

    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        final u = ((gx + 0.5) / grid) * 2 - 1;
        final v = ((gy + 0.5) / grid) * 2 - 1;
        final d2 = u * u + v * v;
        if (d2 > 1) continue;

        Color color;
        if (d2 > edgeBand) {
          color = palette[0];
        } else {
          final nz = math.sqrt(1 - d2);
          var b = (u * _lx + v * _ly + nz * _lz).clamp(0.0, 1.0);
          b = b * b * (3 - 2 * b);
          color = palette[(b * 4.999).floor().clamp(0, 4)];
        }
        _block.color = color;
        canvas.drawRect(
          Rect.fromLTWH(
            origin.dx + gx * px,
            origin.dy + gy * px,
            px + 0.5,
            px + 0.5,
          ),
          _block,
        );
      }
    }
  }

  /// Mapeia brilho 0..1 numa rampa quente->fria->branca, quantizada em
  /// degraus pra leitura pixel.
  Color _shade(double b) {
    final q = (b * 5).floor() / 5; // 6 degraus
    if (q < 0.2) return cool.withValues(alpha: 0.55);
    if (q < 0.45) return cool;
    if (q < 0.7) return Color.lerp(cool, hot, 0.5)!;
    if (q < 0.9) return hot;
    return Color.lerp(hot, Colors.white, 0.6)!;
  }

  @override
  bool shouldRepaint(_AccretionPainter old) =>
      old.hot != hot || old.cool != cool || old.front != front;
}

/// Spec de um planeta em orbita ao redor do buraco negro.
class _Orbit {
  const _Orbit(this.orbit, this.size, this.speed, this.offset, this.palette);

  /// Raio da orbita relativo ao raio total do widget.
  final double orbit;

  /// Tamanho do planeta relativo ao raio total.
  final double size;

  /// Velocidade angular (sinal = sentido).
  final double speed;

  /// Fase inicial (rad).
  final double offset;

  /// Paleta 5 cores [shadow..light].
  final List<Color> palette;
}
