import 'package:animations/src/painters/particle_field_painter.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Widget host do [ParticleFieldPainter]. Cuida de:
/// - tocar o [AnimationController] em loop e alimentar `tick`;
/// - capturar a posicao do mouse via [MouseRegion];
/// - **throttle** do pointer pra nao repintar a 240Hz no web — sem
///   isso, mover o mouse satura o frame budget.
class ParticleField extends StatefulWidget {
  const ParticleField({
    this.particleCount = 36,
    this.seed = 7,
    this.duration = const Duration(seconds: 12),
    this.pointerThrottle = const Duration(milliseconds: 16),
    this.particleColor,
    this.linkColor,
    this.linkDistance = 90,
    super.key,
  });

  final int particleCount;
  final int seed;
  final Duration duration;

  /// Janela minima entre updates de pointer aplicados ao painter.
  /// Default ~1 frame em 60fps.
  final Duration pointerThrottle;

  final Color? particleColor;
  final Color? linkColor;
  final double linkDistance;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);
  late final Listenable _repaint = Listenable.merge([_controller, _pointer]);
  Duration _lastPointerUpdate = Duration.zero;

  @override
  void didUpdateWidget(covariant ParticleField old) {
    super.didUpdateWidget(old);
    if (old.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pointer.dispose();
    super.dispose();
  }

  /// Relogio monotonico baseado no proprio ticker do controller. Avanca
  /// tanto em tempo real quanto em tempo simulado de teste — diferente
  /// de `SchedulerBinding.currentFrameTimeStamp`, que assert-a quando
  /// lido fora de um frame (e o `MouseRegion.onHover` dispara entre
  /// frames durante o dispatch do pointer).
  Duration get _now => _controller.lastElapsedDuration ?? Duration.zero;

  void _setPointer(Offset? next) {
    // Limpar (null) sempre passa — saida da area precisa ser instantanea
    // pra animacao "soltar" o efeito de empurrao.
    if (next == null) {
      if (_pointer.value != null) {
        _pointer.value = null;
        _lastPointerUpdate = _now;
      }
      return;
    }

    final elapsed = _now - _lastPointerUpdate;
    if (elapsed < widget.pointerThrottle) return;

    _pointer.value = next;
    _lastPointerUpdate = _now;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final particleColor = widget.particleColor ?? colors.primary;
    final linkColor =
        widget.linkColor ?? colors.primary.withValues(alpha: 0.18);

    return MouseRegion(
      opaque: false,
      onHover: (event) => _setPointer(event.localPosition),
      onExit: (_) => _setPointer(null),
      child: CustomPaint(
        isComplex: true,
        willChange: true,
        painter: ParticleFieldPainter(
          controller: _controller,
          pointerListenable: _pointer,
          particleCount: widget.particleCount,
          seed: widget.seed,
          particleColor: particleColor,
          linkColor: linkColor,
          linkDistance: widget.linkDistance,
          repaint: _repaint,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
