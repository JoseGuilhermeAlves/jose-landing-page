import 'package:animations/src/painters/loading_spinner_painter.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Widget pronto para usar o [LoadingSpinnerPainter]. Auto-anima com um
/// [AnimationController] em loop e respeita a cor primaria do tema quando
/// nenhuma cor e provida.
///
/// Em produto: usar nas trocas de rota, fetches mockados do showcase e
/// estados de envio do form de contato.
class LoadingSpinner extends StatefulWidget {
  const LoadingSpinner({
    this.size = 32,
    this.strokeWidth = 3,
    this.color,
    this.duration = const Duration(milliseconds: 1100),
    super.key,
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final Duration duration;

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void didUpdateWidget(covariant LoadingSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.colors.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Semantics(
        label: 'Carregando',
        liveRegion: true,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, _) => CustomPaint(
            painter: LoadingSpinnerPainter(
              progress: _controller.value,
              color: color,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}
