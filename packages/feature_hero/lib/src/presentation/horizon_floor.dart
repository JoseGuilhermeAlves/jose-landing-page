import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Chao Outrun do hero: grid em perspectiva que corre em direcao ao
/// observador, com a linha do horizonte no TOPO da caixa. Fica confinado ao
/// rodape do hero (antes o grid ocupava o fundo da pagina inteira e cruzava
/// o texto inteiro). O topo e a base sao dissolvidos por mascara pra o chao
/// "nascer" do fundo e morrer na proxima secao sem borda dura.
///
/// Respeita `disableAnimations` (para o grid parado). Decorativo.
class HorizonFloor extends StatefulWidget {
  const HorizonFloor({required this.near, required this.far, super.key});

  /// Cor das linhas perto do observador (base).
  final Color near;

  /// Cor das linhas no horizonte.
  final Color far;

  @override
  State<HorizonFloor> createState() => _HorizonFloorState();
}

class _HorizonFloorState extends State<HorizonFloor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

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
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, 0.55, 1],
        ).createShader,
        child: RepaintBoundary(
          child: CustomPaint(
            willChange: true,
            painter: _HorizonFloorPainter(
              animation: _controller,
              near: widget.near,
              far: widget.far,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _HorizonFloorPainter extends CustomPainter {
  _HorizonFloorPainter({
    required this.animation,
    required this.near,
    required this.far,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color near;
  final Color far;

  static const int _verticalLines = 21;
  static const int _horizontalLines = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final vx = w / 2;
    final t = animation.value;

    final line = Paint()
      ..strokeWidth = 1
      ..isAntiAlias = true;

    // Raios convergindo no ponto de fuga (centro do horizonte).
    for (var i = 0; i <= _verticalLines; i++) {
      final f = i / _verticalLines;
      final baseX = (f - 0.5) * w * 2.6 + vx;
      line.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [far.withValues(alpha: 0.05), near.withValues(alpha: 0.35)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawLine(
        Offset(vx + (baseX - vx) * 0.04, 0),
        Offset(baseX, h),
        line,
      );
    }
    line.shader = null;

    // Linhas horizontais aceleram ao se aproximar (perspectiva).
    for (var i = 0; i < _horizontalLines; i++) {
      final p = (i / _horizontalLines + t) % 1.0;
      final yp = math.pow(p, 2.2).toDouble();
      final y = yp * h;
      line.color = Color.lerp(
        far,
        near,
        yp,
      )!.withValues(alpha: (0.08 + yp * 0.4).clamp(0.0, 0.5));
      canvas.drawLine(Offset(0, y), Offset(w, y), line);
    }

    // Horizonte: linha fina com brilho suave.
    canvas
      ..drawLine(
        Offset.zero,
        Offset(w, 0),
        Paint()
          ..color = far.withValues(alpha: 0.35)
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawLine(
        Offset.zero,
        Offset(w, 0),
        Paint()
          ..color = far.withValues(alpha: 0.8)
          ..strokeWidth = 1,
      );
  }

  @override
  bool shouldRepaint(_HorizonFloorPainter old) =>
      old.near != near || old.far != far || old.animation != animation;
}
