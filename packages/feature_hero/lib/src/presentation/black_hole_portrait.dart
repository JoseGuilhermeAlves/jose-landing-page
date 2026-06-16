import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Retrato do Jose dentro de um buraco negro estilo Gargantua (Interstellar):
/// a foto e o horizonte de eventos no centro; em volta, um disco de acrescimo
/// tilted renderizado com shaders suaves (mais detalhe que blocos pixel).
/// Composto em duas camadas em volta da foto pra preservar o rosto:
///
/// - **atras** (`painter`): bloom + disco inteiro (a foto cobre o miolo, so
///   sobram as asas/topo/base alem da esfera).
/// - **frente** (`foregroundPainter`): metade frontal do disco cruzando por
///   baixo da esfera + arco lente-gravitacional por cima + photon ring fino.
///
/// O disco e desenhado no "plano" do disco (canvas achatado em [_tiltY] ->
/// elipse), com gradiente radial de TEMPERATURA (branco quente no interior ->
/// dourado -> laranja -> magenta -> roxo -> indigo na borda), Doppler beaming
/// (lado que se aproxima mais claro, sweep aditivo) e um hotspot orbitando.
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
    // Foto = horizonte de eventos. photoR e fracao do half; o diametro da
    // foto e photoR * size (deixa espaco em volta pro disco).
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

enum _DiskClip { all, front }

/// Pinta uma das camadas do buraco negro (atras/frente da foto).
class _GargantuaPainter extends CustomPainter {
  _GargantuaPainter({required Animation<double> animation, required this.front})
    : _anim = animation,
      _paint = Paint()..isAntiAlias = true,
      _stroke = (Paint()
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true
        ..strokeCap = StrokeCap.round),
      super(repaint: animation);

  final Animation<double> _anim;
  final bool front;
  final Paint _paint;
  final Paint _stroke;

  /// Raio da foto (esfera/horizonte) como fracao do half-size.
  static const double photoR = 0.46;
  static const double _diskIn = 0.485;
  static const double _diskOut = 0.97;
  // Mais inclinado (elipse mais achatada) = leitura de disco visto de lado.
  static const double _tiltY = 0.32;

  // Rampa de temperatura do disco (interno quente -> externo frio).
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _gold = Color(0xFFFFE6A0);
  static const Color _orange = Color(0xFFFF9A2E);
  static const Color _redOrange = Color(0xFFFF5024);
  static const Color _magenta = Color(0xFFFF2E86);
  static const Color _purple = Color(0xFF9A36FF);
  static const Color _indigo = Color(0xFF3A1C8C);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = size.shortestSide / 2;
    final phase = _anim.value * 2 * math.pi;

    if (!front) {
      _bloom(canvas, center, half);
      _disk(canvas, center, half, phase, clip: _DiskClip.all);
      _pixelMesh(canvas, center, half);
    } else {
      _disk(canvas, center, half, phase, clip: _DiskClip.front);
      _lensArc(canvas, center, half);
      _photonRing(canvas, center, half);
    }
  }

  void _bloom(Canvas canvas, Offset center, double half) {
    _paint
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8A2BE2).withValues(alpha: 0.20),
          const Color(0xFFFF2EA0).withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: half * 1.05))
      ..blendMode = BlendMode.srcOver;
    canvas.drawCircle(center, half * 1.05, _paint);
    _paint.shader = null;
  }

  void _disk(
    Canvas canvas,
    Offset center,
    double half,
    double phase, {
    required _DiskClip clip,
  }) {
    final rOut = _diskOut * half;
    final rIn = _diskIn * half;
    final f = rIn / rOut;

    canvas.save();
    // Metade frontal: so a faixa de baixo (na frente da esfera).
    if (clip == _DiskClip.front) {
      canvas.clipRect(
        Rect.fromLTWH(
          center.dx - rOut,
          center.dy - rOut * _tiltY * 0.12,
          rOut * 2,
          rOut * _tiltY + rOut * 0.5,
        ),
      );
    }
    // Plano do disco: achata verticalmente -> elipse tilted.
    canvas
      ..translate(center.dx, center.dy)
      ..scale(1, _tiltY)
      // Annulus (disco com furo central) como clip.
      ..clipPath(
        Path()
          ..addOval(Rect.fromCircle(center: Offset.zero, radius: rOut))
          ..addOval(Rect.fromCircle(center: Offset.zero, radius: rIn))
          ..fillType = PathFillType.evenOdd,
      );

    // Temperatura (radial): branco no interior -> indigo, fade na borda.
    _paint
      ..shader = RadialGradient(
        colors: const [
          Colors.transparent,
          _white,
          _gold,
          _orange,
          _redOrange,
          _magenta,
          _purple,
          _indigo,
          Colors.transparent,
        ],
        stops: [
          f * 0.94,
          f,
          f + (1 - f) * 0.12,
          f + (1 - f) * 0.28,
          f + (1 - f) * 0.46,
          f + (1 - f) * 0.64,
          f + (1 - f) * 0.80,
          f + (1 - f) * 0.93,
          1.0,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: rOut))
      ..blendMode = BlendMode.srcOver;
    canvas.drawCircle(Offset.zero, rOut, _paint);

    // Doppler: lado esquerdo (aproxima) mais brilhante — sweep aditivo.
    _paint
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.30),
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0.18, 0.5, 0.82, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: rOut))
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(Offset.zero, rOut, _paint);

    // Hotspot orbitando — blob branco quente aditivo.
    final rMid = (rIn + rOut) / 2;
    final spot = Offset(math.cos(phase) * rMid, math.sin(phase) * rMid);
    _paint
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: spot, radius: rOut * 0.34))
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(spot, rOut * 0.34, _paint);

    _paint
      ..shader = null
      ..blendMode = BlendMode.srcOver;
    canvas.restore();
  }

  /// Pixeliza "um pouco": malha de celulas escuras sobre o disco (leitura
  /// de tela de baixa resolucao) sem perder o gradiente suave por baixo.
  void _pixelMesh(Canvas canvas, Offset center, double half) {
    final rOut = _diskOut * half;
    final annulus = Path()
      ..addOval(
        Rect.fromCenter(
          center: center,
          width: rOut * 2,
          height: rOut * 2 * _tiltY,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: center,
          width: _diskIn * half * 2,
          height: _diskIn * half * 2 * _tiltY,
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas
      ..save()
      ..clipPath(annulus);
    final cell = half * 0.05;
    final mesh = Paint()
      ..color = const Color(0xFF0B0118).withValues(alpha: 0.32)
      ..strokeWidth = 1;
    final left = center.dx - rOut;
    final right = center.dx + rOut;
    final top = center.dy - rOut * _tiltY;
    final bottom = center.dy + rOut * _tiltY;
    for (var x = left; x <= right; x += cell) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), mesh);
    }
    for (var y = top; y <= bottom; y += cell) {
      canvas.drawLine(Offset(left, y), Offset(right, y), mesh);
    }
    canvas.restore();
  }

  void _lensArc(Canvas canvas, Offset center, double half) {
    // Luz curvada sobre o topo da esfera — assinatura Gargantua.
    final r = photoR * half * 1.02;
    final rect = Rect.fromCircle(center: center, radius: r);
    const start = math.pi * 1.12;
    const sweep = math.pi * 0.76;

    _stroke
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: [
          _orange.withValues(alpha: 0),
          _gold.withValues(alpha: 0.9),
          _white,
          _gold.withValues(alpha: 0.9),
          _orange.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(rect)
      ..strokeWidth = half * 0.06
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..blendMode = BlendMode.plus;
    canvas.drawArc(rect, start, sweep, false, _stroke);

    _stroke
      ..maskFilter = null
      ..shader = null
      ..color = _white
      ..strokeWidth = half * 0.018
      ..blendMode = BlendMode.srcOver;
    canvas.drawArc(rect, start + 0.12, sweep - 0.24, false, _stroke);
  }

  void _photonRing(Canvas canvas, Offset center, double half) {
    final r = photoR * half;
    _stroke
      ..color = _gold.withValues(alpha: 0.5)
      ..strokeWidth = half * 0.04
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(center, r + half * 0.012, _stroke);

    _stroke
      ..maskFilter = null
      ..color = _white
      ..strokeWidth = half * 0.012
      ..blendMode = BlendMode.srcOver;
    canvas.drawCircle(center, r + half * 0.008, _stroke);
  }

  @override
  bool shouldRepaint(_GargantuaPainter old) => old.front != front;
}
