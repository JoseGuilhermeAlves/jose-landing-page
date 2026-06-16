import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// FINAL BOSS de arcade "Oni Mask" — **reproducao 1:1 pixel-a-pixel** do sprite
/// de referencia (`cosmic-boss-reference-theme/ONI_3.png`, figura inteira do oni
/// neon — mascara + juba + 6 bracos + cauda de serpente — com o fundo branco
/// removido via flood-fill em `assets/images/oni_boss.png`). NAO e
/// re-desenho vetorial nem interpretacao: os pixels sao os da arte, so que
/// reconstruidos no Canvas via [CustomPainter].
///
/// Tecnica (CLAUDE.md / instrucoes-custom-painter.md): em vez de ~130k
/// `drawRect` por frame (mataria o FPS), o sprite e rasterizado **uma vez** num
/// `ui.Image` (decodificado no load) e composto com `drawImageRect` +
/// `FilterQuality.none` — blocos crocantes, nearest-neighbor, uma chamada de
/// desenho. A animacao (respiracao vertical + bloom pulsante) e overlay leve do
/// painter; o sprite em si fica intacto. `RepaintBoundary` isola, `shouldRepaint`
/// real, shader do bloom cacheado por tamanho (zero alocacao no hot loop).
class OniBoss extends StatefulWidget {
  const OniBoss({super.key});

  @override
  State<OniBoss> createState() => _OniBossState();
}

class _OniBossState extends State<OniBoss> with SingleTickerProviderStateMixin {
  static const _assetKey = 'packages/animations/assets/images/oni_boss.png';

  ui.Image? _image;
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    // Ciclo lento (8s) de respiracao/bloom — o boss "pulsa" sem se mexer muito.
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
    _load();
  }

  Future<void> _load() async {
    final data = await rootBundle.load(_assetKey);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() => _image = frame.image);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) return const SizedBox.shrink();
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        isComplex: true,
        willChange: true,
        painter: _OniBossPainter(image, _c),
      ),
    );
  }
}

class _OniBossPainter extends CustomPainter {
  _OniBossPainter(this._image, this._anim) : super(repaint: _anim);

  final ui.Image _image;
  final Animation<double> _anim;

  // Sprite: nearest-neighbor, sem anti-alias — preserva os blocos do pixel-art.
  final Paint _spritePaint = Paint()
    ..isAntiAlias = false
    ..filterQuality = FilterQuality.none;

  // Bloom aditivo por cima do rosto (presenca/pulso). Cor solida, alpha pulsa —
  // shader cacheado, nunca recriado no paint().
  final Paint _glowPaint = Paint()..blendMode = BlendMode.plus;

  // Geometria de desenho recomputada so quando o tamanho muda.
  Size _builtFor = Size.zero;
  late Rect _src;
  late Rect _dst;
  late Offset _faceCenter;
  late double _glowRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    _ensureBuilt(size);

    final t = _anim.value;
    // Respiracao vertical: poucos px num ciclo de 8s.
    final bob = math.sin(t * 2 * math.pi) * size.shortestSide * 0.008;
    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);

    // 1) Sprite 1:1 (pixels reais do GIF) com respiracao vertical.
    canvas
      ..save()
      ..translate(0, bob)
      ..drawImageRect(_image, _src, _dst, _spritePaint);

    // 2) Bloom sutil sobre o rosto — da vida sem mexer nos pixels.
    _glowPaint.color = Colors.white.withValues(alpha: 0.04 + 0.06 * pulse);
    canvas
      ..drawCircle(_faceCenter, _glowRadius * (0.96 + 0.08 * pulse), _glowPaint)
      ..restore();
  }

  void _ensureBuilt(Size size) {
    if (size == _builtFor) return;
    _builtFor = size;

    final iw = _image.width.toDouble();
    final ih = _image.height.toDouble();
    _src = Rect.fromLTWH(0, 0, iw, ih);

    // Contain, colado no topo-direito (o boss espreita do canto da cena).
    final scale = math.min(size.width / iw, size.height / ih);
    final dw = iw * scale;
    final dh = ih * scale;
    final dx = size.width - dw;
    _dst = Rect.fromLTWH(dx, 0, dw, dh);

    // Mascara fica no alto do sprite de corpo inteiro (fx 0.50, fy 0.16).
    _faceCenter = Offset(dx + dw * 0.50, dh * 0.16);
    _glowRadius = dw * 0.18;
    _glowPaint.shader = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: 0.9),
        const Color(0xFFFF2E88).withValues(alpha: 0.4),
        const Color(0x00000000),
      ],
      stops: const [0, 0.4, 1],
    ).createShader(Rect.fromCircle(center: _faceCenter, radius: _glowRadius));
  }

  @override
  bool shouldRepaint(_OniBossPainter oldDelegate) =>
      oldDelegate._image != _image || oldDelegate._anim != _anim;
}
