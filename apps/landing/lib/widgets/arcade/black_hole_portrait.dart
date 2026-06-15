import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Retrato do Jose num "portal" de buraco negro — centerpiece do hero.
/// A foto fica LIMPA e em destaque no centro (recortada no rosto/ombros,
/// sem pixelizacao agressiva — pixel-perfect e pra arte vetorial, nao pra
/// headshot), emoldurada por um photon ring neon nitido. Em volta, um
/// disco de acrecao de blocos quadrados vibrante (magenta quente ->
/// ciano) gira numa elipse tiltada: metade de tras antes da foto, metade
/// da frente depois (efeito de lente gravitacional).
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
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
    // Foto ocupa ~52% do diametro — destaque real.
    final horizon = widget.size * 0.52;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _AccretionPainter(
            animation: _controller,
            hot: widget.diskHot,
            cool: widget.diskCool,
            front: false,
          ),
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
                  color: const Color(0xFF080510),
                  // Foto LIMPA, enquadrada no rosto/ombros. cacheWidth alto
                  // mantem nitidez (sem o efeito "pixelizado horrivel").
                  child: Transform.scale(
                    scale: 1.42,
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'assets/images/foto_recortada.webp',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      cacheWidth: 640,
                      excludeFromSemantics: true,
                    ),
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

/// Metade (back/front) do disco de acrecao em blocos quadrados numa elipse
/// achatada. Brilho = raio (quente dentro) + Doppler + swirl girando.
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
  final bool front;

  static const double _tiltY = 0.30;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final horizon = r * 0.52;
    final phase = _animation.value * 2 * math.pi;
    final pb = (r * 0.05).clamp(3.0, 8.0);

    // Bloom difuso atras de tudo (so na passada de tras) — vibrancia.
    if (!front) {
      canvas
        ..drawCircle(
          center,
          r * 0.95,
          Paint()
            ..color = hot.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
        )
        ..drawCircle(
          center,
          r * 0.7,
          Paint()
            ..color = cool.withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
        );
    }

    final innerR = horizon * 1.06;
    final outerR = r * 0.99;
    for (var ringR = innerR; ringR <= outerR; ringR += pb) {
      final steps = (ringR * 2 * math.pi / pb).round().clamp(24, 240);
      for (var i = 0; i < steps; i++) {
        final a = (i / steps) * 2 * math.pi;
        final sin = math.sin(a);
        if ((sin > 0) != front) continue;

        final x = center.dx + math.cos(a) * ringR;
        final y = center.dy + sin * ringR * _tiltY;

        final radial = 1 - ((ringR - innerR) / (outerR - innerR)).clamp(0, 1);
        final doppler = 0.5 + 0.5 * math.cos(a - 0.6);
        final swirl = 0.5 + 0.5 * math.sin(a * 3 - phase);
        final bright = (radial * 0.5 + doppler * 0.34 + swirl * 0.16).clamp(
          0.0,
          1.0,
        );
        // Faixas: corta blocos em swirl baixo longe do centro (gaps).
        if (swirl < 0.22 && radial < 0.55) continue;

        _block.color = _shade(bright);
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

    // Photon ring nitido em volta da foto (passada da frente): aro ciano +
    // nucleo branco. Sem blur — forma crisp.
    if (front) {
      canvas
        ..drawCircle(
          center,
          horizon * 1.05,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = (pb * 0.9).clamp(3.0, 6.0)
            ..isAntiAlias = false
            ..color = cool,
        )
        ..drawCircle(
          center,
          horizon * 1.02,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = (pb * 0.4).clamp(1.5, 3.0)
            ..isAntiAlias = false
            ..color = Colors.white,
        );
    }
  }

  /// Rampa quente->fria->branca quantizada em degraus, neon saturado.
  Color _shade(double b) {
    final q = (b * 6).floor() / 6;
    if (q < 0.18) return cool.withValues(alpha: 0.6);
    if (q < 0.4) return cool;
    if (q < 0.6) return Color.lerp(cool, hot, 0.6)!;
    if (q < 0.82) return hot;
    return Color.lerp(hot, Colors.white, 0.55)!;
  }

  @override
  bool shouldRepaint(_AccretionPainter old) =>
      old.hot != hot || old.cool != cool || old.front != front;
}
