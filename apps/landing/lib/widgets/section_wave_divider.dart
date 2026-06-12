import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Separador animado entre secoes da home — usa o `WaveDividerPainter`
/// (PROJECT.md §5.5). Fica decorativo: nao captura input, e a fase
/// avanca em loop pra que a onda "deslize" continuamente.
///
/// Cor default e `colors.primary` com alpha baixo — discreta. Mude
/// `intensity` pra ter mais contraste em secoes que precisam de
/// transicao mais marcada.
class SectionWaveDivider extends StatefulWidget {
  const SectionWaveDivider({
    this.height = 56,
    this.amplitude = 6,
    this.frequency = 1.6,
    this.intensity = 0.35,
    this.duration = const Duration(seconds: 16),
    super.key,
  });

  final double height;
  final double amplitude;
  final double frequency;

  /// Alpha aplicado em `colors.primary` antes de ir pro painter.
  final double intensity;

  final Duration duration;

  @override
  State<SectionWaveDivider> createState() => _SectionWaveDividerState();
}

class _SectionWaveDividerState extends State<SectionWaveDivider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void didUpdateWidget(covariant SectionWaveDivider old) {
    super.didUpdateWidget(old);
    if (old.duration != widget.duration) {
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
    final colors = context.colors;
    final color = colors.primary.withValues(alpha: widget.intensity);

    // Mobile encolhe o divisor — 56px x5 dividers = 280px de decoracao
    // pura num viewport curto. Cap em 32 corta isso quase pela metade
    // sem perder a transicao ondulada entre secoes.
    final effectiveHeight = context.responsive(
      mobile: widget.height.clamp(0.0, 32.0),
      desktop: widget.height,
    );

    // O painter recebe o controller via `animation:` (repaint direto no
    // RenderCustomPaint) — sem AnimatedBuilder reconstruindo a subarvore
    // a cada frame.
    return IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox(
          height: effectiveHeight,
          child: CustomPaint(
            painter: WaveDividerPainter(
              animation: _controller,
              color: color,
              amplitude: widget.amplitude,
              frequency: widget.frequency,
              strokeWidth: 1,
            ),
            willChange: true,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
