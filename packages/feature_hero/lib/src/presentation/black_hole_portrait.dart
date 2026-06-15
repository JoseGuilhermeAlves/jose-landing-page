import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Retrato do Jose dentro de um buraco negro estilo Gargantua (Interstellar):
/// disco de acrescimo tilted em blocos pixel, com a foto fazendo as vezes do
/// horizonte de eventos no centro. Composto em duas camadas em volta da foto
/// pra manter o rosto LIMPO (o disco centrado cruzaria a cara):
///
/// - **atras** (`painter`): bloom roxo/magenta + as "asas" do disco (porcao
///   do anel tilted que aparece pelos lados, fora da foto) + meia-traseira.
/// - **frente** (`foregroundPainter`): photon ring crisp colado a foto, o
///   arco lente-gravitacional por CIMA (luz curvada sobre o topo da cabeca)
///   e uma faixa frontal por baixo (sobre os ombros). A faixa do meio
///   (rosto) fica livre.
///
/// Rampa de temperatura quente: branco -> dourado -> laranja -> magenta ->
/// roxo (encaixa o look do referencia no tema synthwave). Hotspot orbitando
/// + Doppler beaming (lado que se aproxima mais brilhante).
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
    // Foto = horizonte de eventos. photoR e fracao do half; o diametro da
    // foto e photoR * size (deixa espaco em volta pro disco).
    final photo = widget.size * _BlackHolePainter.photoR;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _BlackHolePainter(
            animation: _controller,
            front: false,
            hot: widget.diskHot,
            cool: widget.diskCool,
          ),
          foregroundPainter: _BlackHolePainter(
            animation: _controller,
            front: true,
            hot: widget.diskHot,
            cool: widget.diskCool,
          ),
          child: Center(
            child: SizedBox.square(
              dimension: photo,
              child: ClipOval(
                child: ColoredBox(
                  color: const Color(0xFF080510),
                  // scale 0.85 mostra rosto + ombros (nao so a cabeca).
                  child: Transform.scale(
                    scale: 0.85,
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'assets/images/foto_recortada.webp',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      cacheWidth: 640,
                      excludeFromSemantics: true,
                      // Sem o asset (ex.: teste), cai num vazio escuro em vez
                      // do placeholder vermelho de imagem quebrada.
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

/// Pinta uma das camadas do disco. `front=false` vai atras da foto (bloom +
/// asas), `front=true` vai na frente (photon ring + arco lente + faixa de
/// baixo). Cores num LUT pre-calculado (raio x brilho) — zero alloc no loop.
class _BlackHolePainter extends CustomPainter {
  _BlackHolePainter({
    required Animation<double> animation,
    required this.front,
    required this.hot,
    required this.cool,
  }) : _animation = animation,
       _block = Paint()..isAntiAlias = false,
       _ring = Paint()
         ..style = PaintingStyle.stroke
         ..isAntiAlias = false,
       _bloomA = (Paint()
         ..color = const Color(0xFF8A2BE2).withValues(alpha: 0.10)
         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26)),
       _bloomB = (Paint()
         ..color = const Color(0xFFFF2EA0).withValues(alpha: 0.08)
         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)),
       super(repaint: animation) {
    _lut = _buildLut();
  }

  final Animation<double> _animation;
  final bool front;
  final Color hot;
  final Color cool;

  final Paint _block;
  final Paint _ring;
  final Paint _bloomA;
  final Paint _bloomB;

  // Geometria (coords normalizadas u,v em [-1,1] relativas ao half-size).
  static const double photoR = 0.56; // raio da foto (horizonte de eventos)
  static const double _tiltY = 0.34; // achatamento do plano do disco
  static const double _diskIn = 0.60; // raio eliptico interno do disco
  static const double _diskOut = 1.34; // raio eliptico externo (asas largas)

  late final List<List<Color>> _lut;
  static const int _radialBands = 7;
  static const int _brightLevels = 7;

  /// Rampa quente do disco (branco->dourado->laranja->magenta->roxo) cruzada
  /// com niveis de brilho. Banda 0 = interno quente, banda 6 = externo frio.
  List<List<Color>> _buildLut() {
    Color baseFor(double t) {
      const stops = [
        Color(0xFFFFFFFF),
        Color(0xFFFFE89A),
        Color(0xFFFF9A2E),
        Color(0xFFFF3C6E),
        Color(0xFFFF2EA0),
        Color(0xFF8A3CFF),
        Color(0xFF2A1A66),
      ];
      final pos = (t.clamp(0.0, 1.0)) * (stops.length - 1);
      final lo = pos.floor().clamp(0, stops.length - 1);
      final hi = (lo + 1).clamp(0, stops.length - 1);
      return Color.lerp(stops[lo], stops[hi], pos - lo)!;
    }

    Color applyBright(Color base, double f) {
      final dark = Color.lerp(const Color(0xFF0A0014), base, 0.20)!;
      if (f <= 0.55) return Color.lerp(dark, base, f / 0.55)!;
      return Color.lerp(base, const Color(0xFFFFFFFF), (f - 0.55) / 0.45)!;
    }

    return List.generate(_radialBands, (rb) {
      final base = baseFor(rb / (_radialBands - 1));
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

  /// Brilho de uma celula do disco: base + Doppler (esquerda mais clara) +
  /// hotspot orbitando (cabeca nitida + cauda) + realce radial interno.
  double _diskBright(double ang, double t, double phase) {
    final doppler = 0.5 + 0.5 * math.cos(ang - math.pi);
    final sd = _signedDelta(ang, phase);
    final double spot;
    if (sd.abs() < 0.4) {
      spot = 1 - sd.abs() / 0.4;
    } else if (sd > 0 && sd < 2.0) {
      spot = (1 - sd / 2.0) * 0.5;
    } else {
      spot = 0;
    }
    return (0.28 + 0.42 * doppler + 0.85 * spot + (1 - t) * 0.15)
        .clamp(0.0, 1.0);
  }

  Color _diskColor(double t, double bright) {
    final rb = (t.clamp(0.0, 1.0) * (_radialBands - 1)).round();
    final bl = (bright.clamp(0.0, 1.0) * (_brightLevels - 1)).round();
    return _lut[rb][bl];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = size.shortestSide / 2;
    final phase = _animation.value * 2 * math.pi;
    final pb = (half * 0.05).clamp(3.5, 9.0);
    final grid = (size.shortestSide / pb).round();

    if (!front) {
      // Bloom roxo/magenta sutil — hugs o disco, nao lava o fundo.
      canvas
        ..drawCircle(center, half * 0.92, _bloomA)
        ..drawCircle(center, half * 0.68, _bloomB);
    }

    void block(double u, double v, Color c) {
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
        final ang = math.atan2(v, u);
        // Coordenada radial no plano tilted do disco.
        final er = math.sqrt(u * u + (v / _tiltY) * (v / _tiltY));
        final inDisk = er >= _diskIn && er <= _diskOut;
        final t = ((er - _diskIn) / (_diskOut - _diskIn)).clamp(0.0, 1.0);

        if (!front) {
          // ATRAS: disco inteiro (a foto cobre o miolo; sobram as asas).
          if (!inDisk) continue;
          block(u, v, _diskColor(t, _diskBright(ang, t, phase)));
        } else {
          // FRENTE: arco lente por cima + faixa frontal por baixo. Rosto
          // (faixa central) fica livre.
          final overTop = rr > photoR * 0.97 &&
              rr < photoR * 1.24 &&
              v < -photoR * 0.34;
          final frontBand = inDisk && v > photoR * 0.62;
          if (!overTop && !frontBand) continue;

          if (overTop) {
            // Arco lente: circular (segue a foto), mais quente no topo.
            final topness = (-v / rr).clamp(0.0, 1.0); // 1 no topo
            final bright = (0.45 + 0.5 * topness +
                    0.4 * (1 - _signedDelta(ang, phase).abs() / math.pi))
                .clamp(0.0, 1.0);
            final tt = ((rr - photoR * 0.97) / (photoR * 0.27)).clamp(0.0, 1.0);
            block(u, v, _diskColor(tt * 0.5, bright));
          } else {
            block(u, v, _diskColor(t, _diskBright(ang, t, phase)));
          }
        }
      }
    }

    if (front) {
      // Photon ring crisp colado a foto.
      _ring
        ..strokeWidth = pb * 0.5
        ..color = const Color(0xFFFFFFFF);
      canvas.drawCircle(center, half * photoR + pb * 0.5, _ring);
    }
  }

  @override
  bool shouldRepaint(_BlackHolePainter old) =>
      old.front != front || old.hot != hot || old.cool != cool;
}
