import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Moldura CRT desenhada por cima do conteudo: scanlines, vinheta de tubo,
/// banda de varredura rolante e flicker sutil. Use como `foregroundPainter`
/// num `CustomPaint` envolto em `IgnorePointer` (decorativo, nunca toca).
///
/// Scanlines e vinheta sao geometria/shader estaticos, cacheados por tamanho
/// (zero alocacao no hot loop). So a banda rolante e o flicker derivam do
/// tempo. O host instancia passando o controller em `super(repaint:)`.
class CrtPainter extends CustomPainter {
  CrtPainter({required Animation<double> animation, required this.tint})
    : _animation = animation,
      _scanlinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.18),
      _bandPaint = Paint(),
      _flickerPaint = Paint(),
      super(repaint: animation);

  final Animation<double> _animation;

  /// Tinta do tubo — geralmente o `onSurface` (branco-lavanda) usado com
  /// alpha baixo na banda de varredura.
  final Color tint;

  final Paint _scanlinePaint;
  final Paint _bandPaint;
  final Paint _flickerPaint;

  /// Espacamento das scanlines em px logicos.
  static const double _scanGap = 3;

  // Geometria/shader cacheados por tamanho.
  Size _cachedSize = Size.zero;
  Path _scanlines = Path();
  Paint _vignette = Paint();

  void _syncCache(Size size) {
    if (size == _cachedSize) return;
    _cachedSize = size;

    // Scanlines: uma Path com todas as linhas horizontais, desenhada num
    // unico drawPath por frame.
    final path = Path();
    for (var y = 0.0; y < size.height; y += _scanGap) {
      path
        ..moveTo(0, y)
        ..lineTo(size.width, y);
    }
    _scanlines = path;

    // Vinheta: radial escura nas bordas, transparente no centro.
    final center = size.center(Offset.zero);
    _vignette = Paint()
      ..shader =
          const RadialGradient(
            radius: 0.95,
            colors: [Color(0x00000000), Color(0x00000000), Color(0x73000000)],
            stops: [0.0, 0.62, 1.0],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.longestSide * 0.62),
          );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _syncCache(size);
    final rect = Offset.zero & size;
    final t = _animation.value;

    // Scanlines (estaticas).
    canvas.drawPath(_scanlines, _scanlinePaint);

    // Banda de varredura: gradiente vertical claro descendo devagar.
    final bandCenter = (t * 1.4 - 0.2) * size.height;
    final bandHeight = size.height * 0.18;
    final bandRect = Rect.fromLTWH(
      0,
      bandCenter - bandHeight / 2,
      size.width,
      bandHeight,
    );
    _bandPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        tint.withValues(alpha: 0),
        tint.withValues(alpha: 0.06),
        tint.withValues(alpha: 0),
      ],
    ).createShader(bandRect);
    canvas
      ..drawRect(bandRect, _bandPaint)
      // Vinheta (estatica).
      ..drawRect(rect, _vignette);

    // Flicker: leve oscilacao de brilho global do tubo.
    final flicker = 0.015 + 0.015 * math.sin(t * 6.283 * 3);
    _flickerPaint.color = tint.withValues(alpha: flicker);
    canvas.drawRect(rect, _flickerPaint);
  }

  @override
  bool shouldRepaint(CrtPainter oldDelegate) => oldDelegate.tint != tint;
}
