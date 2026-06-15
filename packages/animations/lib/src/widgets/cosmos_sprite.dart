import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Corpos celestes recortados do sprite-sheet `cosmos_3.png` (752x605),
/// empacotado em `packages/animations/assets`. Em vez de reproduzir os
/// planetas proceduralmente (que nunca bate a referencia), recortamos os
/// sprites reais e desenhamos pixel-perfect (nearest-neighbor). Os
/// retangulos sao em px da imagem fonte.
enum CelestialBody { lava, saturn, ice, earth, sun, moon, portal, asteroids }

/// Retangulo fonte (px) de cada corpo dentro de cosmos_3.png.
const Map<CelestialBody, Rect> kCosmosSrc = {
  CelestialBody.lava: Rect.fromLTWH(300, 22, 172, 168),
  CelestialBody.saturn: Rect.fromLTWH(505, 66, 210, 156),
  CelestialBody.ice: Rect.fromLTWH(0, 104, 162, 172),
  CelestialBody.earth: Rect.fromLTWH(246, 414, 172, 178),
  CelestialBody.sun: Rect.fromLTWH(2, 400, 192, 176),
  CelestialBody.moon: Rect.fromLTWH(508, 488, 188, 117),
  CelestialBody.portal: Rect.fromLTWH(344, 244, 134, 128),
  CelestialBody.asteroids: Rect.fromLTWH(146, 92, 120, 128),
};

/// Carrega (uma vez) a `ui.Image` do sprite-sheet do cosmos.
abstract final class CosmosAtlas {
  static Future<ui.Image>? _future;

  static Future<ui.Image> load() => _future ??= _decode();

  static Future<ui.Image> _decode() async {
    final data = await rootBundle.load(
      'packages/animations/assets/cosmos_3.png',
    );
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

/// Desenha um [body] do atlas escalado pra preencher o widget, pixel-perfect
/// (FilterQuality.none), mantendo a proporcao do recorte (contain). Enquanto
/// a imagem carrega, ocupa o espaco sem pintar.
class CelestialSprite extends StatefulWidget {
  const CelestialSprite({required this.body, super.key});

  final CelestialBody body;

  @override
  State<CelestialSprite> createState() => _CelestialSpriteState();
}

class _CelestialSpriteState extends State<CelestialSprite> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    CosmosAtlas.load().then((img) {
      if (mounted) setState(() => _image = img);
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) return const SizedBox.shrink();
    return CustomPaint(
      painter: _SpritePainter(image: image, src: kCosmosSrc[widget.body]!),
      size: Size.infinite,
    );
  }
}

class _SpritePainter extends CustomPainter {
  _SpritePainter({required this.image, required this.src})
    : _paint = Paint()
        ..isAntiAlias = false
        ..filterQuality = FilterQuality.none;

  final ui.Image image;
  final Rect src;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / src.width).clamp(0.0, size.height / src.height);
    final w = src.width * scale;
    final h = src.height * scale;
    final dst = Rect.fromLTWH(
      (size.width - w) / 2,
      (size.height - h) / 2,
      w,
      h,
    );
    canvas.drawImageRect(image, src, dst, _paint);
  }

  @override
  bool shouldRepaint(_SpritePainter old) =>
      old.image != image || old.src != src;
}
