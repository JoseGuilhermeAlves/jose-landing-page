import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Backdrop animado do hero da home Vitral — grid de "linhas de hora"
/// horizontais com um cursor luminoso varrendo verticalmente, evocando
/// agenda/cronograma sem ser literal demais.
///
/// Performance: paints cacheados, `super(repaint:)` direto pro
/// controller. Vive em `RepaintBoundary` no caller.
class VitralHeroBackdrop extends StatefulWidget {
  const VitralHeroBackdrop({
    required this.gridColor,
    required this.cursorColor,
    super.key,
  });

  /// Cor das linhas do grid (geralmente primary com alpha baixo).
  final Color gridColor;

  /// Cor do cursor varrendo o grid (geralmente accent translucido).
  final Color cursorColor;

  @override
  State<VitralHeroBackdrop> createState() => _VitralHeroBackdropState();
}

class _VitralHeroBackdropState extends State<VitralHeroBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        isComplex: true,
        willChange: true,
        painter: _VitralHeroBackdropPainter(
          controller: _controller,
          gridColor: widget.gridColor,
          cursorColor: widget.cursorColor,
        ),
      ),
    );
  }
}

class _VitralHeroBackdropPainter extends CustomPainter {
  _VitralHeroBackdropPainter({
    required this.controller,
    required this.gridColor,
    required this.cursorColor,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final Color gridColor;
  final Color cursorColor;

  late final Paint _gridPaint = Paint()
    ..color = gridColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  late final Paint _gridStrongPaint = Paint()
    ..color = gridColor.withValues(alpha: gridColor.a * 1.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  late final Paint _cursorPaint = Paint()
    ..color = cursorColor
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final phase = controller.value;

    // Grid de linhas horizontais a cada 10% da altura. As de 0%, 50%
    // e 100% ficam um pouco mais grossas (linhas-marca de hora cheia).
    for (var y = 0.0; y <= size.height; y += size.height * 0.10) {
      final yi = (y / (size.height * 0.10)).round();
      final paint = (yi % 5 == 0) ? _gridStrongPaint : _gridPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Linhas verticais em 4 colunas — simulam "ticks de dia".
    for (var i = 0; i < 4; i++) {
      final x = size.width * (i / 4);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _gridPaint);
    }

    // Cursor: faixa horizontal subindo lentamente, deixando rastro fade
    // simulado por uma faixa de altura fixa.
    final cursorY = (1 - phase) * size.height;
    final cursorRect = Rect.fromLTWH(
      0,
      cursorY - size.height * 0.04,
      size.width,
      size.height * 0.06,
    );
    canvas.drawRect(cursorRect, _cursorPaint);

    // Marcador pulsante na intersecao do cursor com a coluna 2.
    final markerX = size.width * 0.50;
    final pulseR = 5 + 3 * math.sin(phase * 2 * math.pi * 4);
    canvas.drawCircle(
      Offset(markerX, cursorY - size.height * 0.01),
      pulseR,
      Paint()..color = cursorColor.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_VitralHeroBackdropPainter old) {
    return old.gridColor != gridColor || old.cursorColor != cursorColor;
  }
}
