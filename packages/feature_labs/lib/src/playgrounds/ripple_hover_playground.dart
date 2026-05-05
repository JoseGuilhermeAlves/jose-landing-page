import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_labs/src/widgets/playground_scaffold.dart';
import 'package:flutter/material.dart';

/// Playground do `RippleHoverPainter`. Diferente dos demais: e
/// disparado por gesto. Tap ou hover no painel anima um ripple a
/// partir do ponto. Sliders ajustam stroke width e maxRadius opcional.
class RippleHoverPlayground extends StatefulWidget {
  const RippleHoverPlayground({super.key});

  @override
  State<RippleHoverPlayground> createState() => _RippleHoverPlaygroundState();
}

class _RippleHoverPlaygroundState extends State<RippleHoverPlayground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  Offset? _center;
  double _strokeWidth = 1.5;

  /// Quando true, o ripple usa um maxRadius fixo (em vez de auto =
  /// canto mais distante do canvas).
  bool _capRadius = false;
  double _maxRadius = 120;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _trigger(Offset position) {
    setState(() => _center = position);
    _controller
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return PlaygroundScaffold(
      title: 'Ripple no hover',
      painterName: 'RippleHoverPainter',
      description:
          'Onda circular que expande do ponto onde o cursor entrou ou '
          'tocou. Alpha decai linearmente conforme o anel se afasta.',
      preview: GestureDetector(
        key: const Key('ripple-tap-target'),
        onTapDown: (details) => _trigger(details.localPosition),
        child: MouseRegion(
          onHover: (event) {
            // Dispara so quando o controller ja parou — evita redisparos
            // a cada frame de mouse.
            if (!_controller.isAnimating) _trigger(event.localPosition);
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(color: colors.surfaceMuted),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, _) {
                    if (_center == null) {
                      return Center(
                        child: Text(
                          'Tap ou passe o mouse aqui',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                      );
                    }
                    return CustomPaint(
                      painter: RippleHoverPainter(
                        center: _center!,
                        progress: _controller.value,
                        color: colors.primary,
                        maxRadius: _capRadius ? _maxRadius : null,
                        strokeWidth: _strokeWidth,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      controls: [
        PlaygroundSlider(
          key: const Key('ripple-stroke-slider'),
          label: 'Stroke width',
          value: _strokeWidth,
          min: 0.5,
          max: 6,
          divisions: 11,
          formatter: (v) => '${v.toStringAsFixed(1)} px',
          onChanged: (v) => setState(() => _strokeWidth = v),
        ),
        PlaygroundSwitch(
          key: const Key('ripple-cap-switch'),
          label: 'Limitar maxRadius',
          value: _capRadius,
          onChanged: (v) => setState(() => _capRadius = v),
        ),
        PlaygroundSlider(
          key: const Key('ripple-max-radius-slider'),
          label: 'Max radius (quando limitado)',
          value: _maxRadius,
          min: 40,
          max: 400,
          divisions: 36,
          formatter: (v) => '${v.round()} px',
          onChanged: (v) => setState(() {
            _maxRadius = v;
            _capRadius = true;
          }),
        ),
      ],
    );
  }
}
