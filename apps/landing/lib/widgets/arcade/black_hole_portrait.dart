import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Retrato do Jose num portal neon — centerpiece do hero. A foto fica
/// LIMPA e em destaque no centro; em volta (sempre FORA do circulo da
/// foto, nunca cruzando o rosto) ha um anel de blocos pixel magenta->ciano
/// com um arco brilhante girando devagar (leitura de "buraco negro" sem o
/// disco tiltado que cortava a foto). Bloom CRT atras.
class BlackHolePortrait extends StatefulWidget {
  const BlackHolePortrait({
    required this.diskHot,
    required this.diskCool,
    required this.size,
    super.key,
  });

  final Color diskHot;
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
      duration: const Duration(seconds: 10),
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
    // Foto ocupa ~64% do diametro — destaque real, anel em volta.
    final photo = widget.size * 0.64;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          // Anel + arco + bloom desenhados ATRAS; ficam fora da foto.
          painter: _PortalRingPainter(
            animation: _controller,
            hot: widget.diskHot,
            cool: widget.diskCool,
          ),
          child: Center(
            child: SizedBox.square(
              dimension: photo,
              child: ClipOval(
                child: ColoredBox(
                  color: const Color(0xFF080510),
                  // scale 0.9 mostra rosto + ombros (nao so a cabeca).
                  child: Transform.scale(
                    scale: 0.9,
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

/// Anel de blocos pixel ao redor da foto (annulus, sem tilt — nunca cruza
/// o rosto) com um arco brilhante girando. Bloom difuso atras.
class _PortalRingPainter extends CustomPainter {
  _PortalRingPainter({
    required Animation<double> animation,
    required this.hot,
    required this.cool,
  }) : _animation = animation,
       _block = Paint()..isAntiAlias = false,
       super(repaint: animation);

  final Animation<double> _animation;
  final Color hot;
  final Color cool;
  final Paint _block;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = size.shortestSide / 2;
    final phase = _animation.value * 2 * math.pi;

    // Raio normalizado da foto (0..1 de half). Anel vive logo fora dela.
    const photoR = 0.64;
    const ringIn = 0.66;
    const ringOut = 0.97;
    final pb = (half * 0.045).clamp(3.0, 9.0);
    final grid = (size.shortestSide / pb).round();

    // Bloom atras (camada de blur, nunca borra os blocos).
    canvas
      ..drawCircle(
        center,
        half * 0.9,
        Paint()
          ..color = hot.withValues(alpha: 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
      )
      ..drawCircle(
        center,
        half * 0.7,
        Paint()
          ..color = cool.withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );

    // Annulus de blocos. Cor interpola magenta(perto)->ciano(fora); um arco
    // girando acende uma faixa angular em branco-quente.
    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        final u = ((gx + 0.5) / grid) * 2 - 1;
        final v = ((gy + 0.5) / grid) * 2 - 1;
        final rr = math.sqrt(u * u + v * v);
        if (rr < ringIn || rr > ringOut) continue;

        final t = ((rr - ringIn) / (ringOut - ringIn)).clamp(0.0, 1.0);
        var color = Color.lerp(hot, cool, t)!;

        // Arco girando: realca uma janela angular.
        final ang = math.atan2(v, u);
        final d = _angDelta(ang, phase);
        if (d < 0.5) {
          color = Color.lerp(color, Colors.white, (0.5 - d) / 0.5 * 0.8)!;
        }
        // Quantiza alpha em 2 niveis pra leitura pixel.
        _block.color = color.withValues(alpha: t < 0.5 ? 0.95 : 0.75);
        canvas.drawRect(
          Rect.fromLTWH(
            center.dx + u * half - pb / 2,
            center.dy + v * half - pb / 2,
            pb + 0.6,
            pb + 0.6,
          ),
          _block,
        );
      }
    }

    // Aro fino crisp exatamente na borda da foto (moldura).
    canvas.drawCircle(
      center,
      half * photoR + pb * 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = pb * 0.5
        ..isAntiAlias = false
        ..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  /// Distancia angular minima (0..pi) entre dois angulos.
  double _angDelta(double a, double b) {
    var d = (a - b).abs() % (2 * math.pi);
    if (d > math.pi) d = 2 * math.pi - d;
    return d;
  }

  @override
  bool shouldRepaint(_PortalRingPainter old) =>
      old.hot != hot || old.cool != cool;
}
