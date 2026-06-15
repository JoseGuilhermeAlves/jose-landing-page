import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Moldura CRT desenhada por cima de todo o conteudo: scanlines, vinheta
/// de tubo, banda de varredura rolante e flicker sutil. Decorativo e
/// `IgnorePointer` — nunca intercepta toque.
///
/// Scanlines e vinheta sao geometria/shader estaticos, cacheados por
/// tamanho (zero alocacao no hot loop). So a banda rolante e o flicker
/// derivam do tempo. O painter ouve o controller via `super(repaint:)`.
class CrtOverlay extends StatefulWidget {
  const CrtOverlay({required this.tint, super.key});

  /// Tinta do tubo — geralmente o `onSurface` (branco-lavanda) usado com
  /// alpha baixo na banda de varredura.
  final Color tint;

  @override
  State<CrtOverlay> createState() => _CrtOverlayState();
}

class _CrtOverlayState extends State<CrtOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
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
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          willChange: true,
          foregroundPainter: CrtPainter(
            animation: _controller,
            tint: widget.tint,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
