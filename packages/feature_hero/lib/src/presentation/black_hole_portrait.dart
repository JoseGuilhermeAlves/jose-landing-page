import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Retrato do Jose dentro de um buraco negro estilo Gargantua (Interstellar),
/// em PIXEL ART. A foto e o horizonte de eventos; em volta, um disco de
/// acrescimo TILTED bem raso ([_tiltY] baixo): por isso ele cruza FINO pela
/// frente/atras (esmagado na vertical) mas se ESTENDE LARGO e grosso nas
/// pontas (esquerda/direita). A esfera oculta o disco, entao so uma faixa
/// fina passa na frente do rosto.
///
/// Duas camadas em volta da foto:
/// - **atras** (`painter`): bloom + as pontas largas do disco (fora da foto).
/// - **frente** (`foregroundPainter`): faixa fina cruzando a frente + arco
///   lente por cima + photon ring, tudo em blocos.
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
    final photo = widget.size * _GargantuaPainter.photoR;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _GargantuaPainter(animation: _controller, front: false),
          foregroundPainter: _GargantuaPainter(
            animation: _controller,
            front: true,
          ),
          child: Center(
            child: SizedBox.square(
              dimension: photo,
              child: ClipOval(
                child: ColoredBox(
                  color: const Color(0xFF080510),
                  child: Transform.scale(
                    scale: 0.85,
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'assets/images/foto_recortada.webp',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      cacheWidth: 640,
                      excludeFromSemantics: true,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Color(0xFF080510)),
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

/// Pinta uma camada do buraco negro em blocos pixel. `front=false` = pontas
/// largas atras da foto; `front=true` = faixa fina na frente + arco + ring.
class _GargantuaPainter extends CustomPainter {
  _GargantuaPainter({required Animation<double> animation, required this.front})
    : _anim = animation,
      _block = Paint()..isAntiAlias = false,
      _bloomA = (Paint()
        ..color = const Color(0xFF8A2BE2).withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26)),
      _bloomB = (Paint()
        ..color = const Color(0xFFFF7A1E).withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)),
      super(repaint: animation) {
    _lut = _buildLut();
  }

  final Animation<double> _anim;
  final bool front;
  final Paint _block;
  final Paint _bloomA;
  final Paint _bloomB;

  /// Raio da foto (esfera) como fracao do half-size.
  static const double photoR = 0.42;
  // Tilt raso => faixa fina na frente, pontas largas. Anel hugando a esfera.
  static const double _tiltY = 0.18;
  static const double _rIn = 0.40;
  static const double _rOut = 0.99;

  late final List<List<Color>> _lut;
  static const int _radialBands = 7;
  static const int _brightLevels = 7;

  List<List<Color>> _buildLut() {
    const ramp = [
      Color(0xFFFFFFFF),
      Color(0xFFFFE6A0),
      Color(0xFFFF9A2E),
      Color(0xFFFF5024),
      Color(0xFFFF2E86),
      Color(0xFF9A36FF),
      Color(0xFF3A1C8C),
    ];
    Color applyBright(Color base, double f) {
      final dark = Color.lerp(const Color(0xFF0A0014), base, 0.22)!;
      if (f <= 0.55) return Color.lerp(dark, base, f / 0.55)!;
      return Color.lerp(base, const Color(0xFFFFFFFF), (f - 0.55) / 0.45)!;
    }

    return List.generate(_radialBands, (rb) {
      final base = ramp[rb];
      return List.generate(
        _brightLevels,
        (bl) => applyBright(base, bl / (_brightLevels - 1)),
      );
    });
  }

  double _signedDelta(double a, double b) {
    var d = (a - b) % (2 * math.pi);
    if (d > math.pi) d -= 2 * math.pi;
    return d;
  }

  /// Brilho de uma celula do disco.
  double _bright(double u, double v, double t, double phase) {
    final screenAng = math.atan2(v, u);
    final doppler = 0.5 + 0.5 * math.cos(screenAng - math.pi); // claro a esq.
    // Hotspot orbita no plano do disco.
    final diskAng = math.atan2(v / _tiltY, u);
    final sd = _signedDelta(diskAng, phase);
    final double spot;
    if (sd.abs() < 0.5) {
      spot = 1 - sd.abs() / 0.5;
    } else if (sd > 0 && sd < 2.2) {
      spot = (1 - sd / 2.2) * 0.5;
    } else {
      spot = 0;
    }
    return (0.26 + 0.42 * doppler + 0.8 * spot + (1 - t) * 0.16)
        .clamp(0.0, 1.0);
  }

  Color _color(double t, double bright) {
    final rb = (t.clamp(0.0, 1.0) * (_radialBands - 1)).round();
    final bl = (bright.clamp(0.0, 1.0) * (_brightLevels - 1)).round();
    return _lut[rb][bl];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = size.shortestSide / 2;
    final phase = _anim.value * 2 * math.pi;
    final pb = (half * 0.032).clamp(2.5, 6.5);
    final grid = (size.shortestSide / pb).round();
    final ringHalf = pb / half * 0.9; // espessura do photon ring em norm.

    if (!front) {
      canvas
        ..drawCircle(center, half * 0.95, _bloomA)
        ..drawCircle(center, half * 0.7, _bloomB);
    }

    void px(double u, double v, Color c) {
      _block.color = c;
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

    for (var gy = 0; gy < grid; gy++) {
      for (var gx = 0; gx < grid; gx++) {
        final u = ((gx + 0.5) / grid) * 2 - 1;
        final v = ((gy + 0.5) / grid) * 2 - 1;
        final rr = math.sqrt(u * u + v * v);
        final cv = v / _tiltY;
        final dr = math.sqrt(u * u + cv * cv);
        final onDisk = dr >= _rIn && dr <= _rOut;
        final t = ((dr - _rIn) / (_rOut - _rIn)).clamp(0.0, 1.0);
        final inSphere = rr < photoR;

        if (!front) {
          // ATRAS: pontas largas do disco (fora da esfera).
          if (!onDisk || inSphere) continue;
          px(u, v, _color(t, _bright(u, v, t, phase)));
        } else {
          // Photon ring crisp na borda da esfera.
          if ((rr - photoR).abs() < ringHalf) {
            px(u, v, const Color(0xFFFFFFFF));
            continue;
          }
          // Arco lente por cima da esfera (luz curvada).
          if (v < 0 && rr > photoR && rr < photoR * 1.2) {
            final topness = (-v / rr).clamp(0.0, 1.0);
            if (topness > 0.35) {
              px(u, v, _color(0.12, 0.6 + 0.4 * topness));
              continue;
            }
          }
          // Faixa fina cruzando a frente (sobre a parte de baixo da esfera).
          if (onDisk && v > 0 && inSphere) {
            px(u, v, _color(t, _bright(u, v, t, phase)));
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GargantuaPainter old) => old.front != front;
}
