import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Interpola entre tres formas — circulo, blob organico e quadrado —
/// num ciclo continuo guiado por [progress] (PROJECT.md §5.3). Existe
/// pra demonstrar controle de Path: amostra N pontos em coordenadas
/// polares e interpola o raio em cada angulo.
///
/// Mapa do ciclo (com easing em cada metade):
/// - `progress in [0, 0.5]` — circulo -> blob;
/// - `progress in [0.5, 1]` — blob -> quadrado;
/// - alimentar com um controller em loop fecha o ciclo visualmente.
///
/// Performance:
/// - `Paint` cacheado em campo;
/// - amostragem fixa em [sampleCount] pontos (default 72) — mantem
///   o path leve sem custo perceptivel;
/// - `shouldRepaint` so volta `true` quando algo do estado visual muda.
class MorphingShapePainter extends CustomPainter {
  MorphingShapePainter({
    required double progress,
    required this.color,
    this.style = PaintingStyle.fill,
    this.strokeWidth = 1.5,
    this.sampleCount = 72,
  }) : assert(sampleCount >= 8, 'Sample count muito baixo'),
       progress = progress.clamp(0.0, 1.0);

  /// Fase do ciclo (0..1). Externamente alimentado por um
  /// [AnimationController] em loop.
  final double progress;
  final Color color;

  /// `fill` (default) pra blob solido; `stroke` pra contorno.
  final PaintingStyle style;
  final double strokeWidth;

  /// Numero de pontos amostrados ao longo do contorno. Mais pontos =
  /// formas mais lisas, mais custo. 72 e suficiente pra circulo.
  final int sampleCount;

  late final Paint _paint = Paint()
    ..isAntiAlias = true
    ..color = color
    ..style = style
    ..strokeWidth = strokeWidth
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2;
    if (baseRadius <= 0) return;

    final path = Path();
    for (var i = 0; i < sampleCount; i++) {
      final angle = (i / sampleCount) * 2 * math.pi;
      final r = _radiusAt(angle, progress) * baseRadius;
      final p = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    canvas.drawPath(path, _paint);
  }

  /// Raio normalizado (1.0 = `baseRadius`) em cada angulo, em funcao
  /// do progresso. Lerps entre tres "presets":
  /// - circulo: r = 1
  /// - blob: r = 1 + 0.18 * sin(3θ)
  /// - quadrado: r = 1 / max(|cos θ|, |sin θ|)  (raio-ate-a-borda)
  static double _radiusAt(double angle, double progress) {
    const circleR = 1.0;
    final blobR = 1 + 0.18 * math.sin(3 * angle);
    final cosA = math.cos(angle).abs();
    final sinA = math.sin(angle).abs();
    final squareR = 1 / math.max(cosA, sinA).clamp(1e-3, double.infinity);

    if (progress <= 0.5) {
      final t = _easeInOut(progress * 2);
      return _lerp(circleR, blobR, t);
    } else {
      final t = _easeInOut((progress - 0.5) * 2);
      return _lerp(blobR, squareR, t);
    }
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Curva ease-in-out classica (suaviza extremos do morph).
  static double _easeInOut(double t) {
    if (t < 0.5) return 2 * t * t;
    final u = -2 * t + 2;
    return 1 - u * u / 2;
  }

  @override
  bool shouldRepaint(covariant MorphingShapePainter old) {
    return old.progress != progress ||
        old.color != color ||
        old.style != style ||
        old.strokeWidth != strokeWidth ||
        old.sampleCount != sampleCount;
  }

  /// Hint para o `CustomPaint` host: poucas formas, nao vale rasterizar.
  bool get isComplex => false;

  /// Hint para o `CustomPaint` host: anima continuamente.
  bool get willChange => true;
}
