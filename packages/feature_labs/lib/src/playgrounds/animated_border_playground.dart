import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_labs/src/widgets/playground_scaffold.dart';
import 'package:flutter/material.dart';

/// Playground do `AnimatedBorderPainter`. Em produto, o controle e
/// hover; aqui exibimos um card que reage ao hover **e** um slider
/// pra forcar o progress manualmente.
class AnimatedBorderPlayground extends StatefulWidget {
  const AnimatedBorderPlayground({super.key});

  @override
  State<AnimatedBorderPlayground> createState() =>
      _AnimatedBorderPlaygroundState();
}

class _AnimatedBorderPlaygroundState extends State<AnimatedBorderPlayground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  bool _useManualProgress = false;
  double _manualProgress = 0.5;
  double _strokeWidth = 1.5;
  double _borderRadius = 16;

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return PlaygroundScaffold(
      title: 'Borda animada',
      painterName: 'AnimatedBorderPainter',
      description:
          'Sob hover, o contorno arredondado cresce de 0 ate o '
          'perimetro completo via extractPath. Saindo do card, recolhe.',
      preview: Center(
        child: SizedBox(
          width: 240,
          height: 140,
          child: MouseRegion(
            onEnter: (_) {
              if (!_useManualProgress) _hoverController.forward();
            },
            onExit: (_) {
              if (!_useManualProgress) _hoverController.reverse();
            },
            child: AnimatedBuilder(
              animation: _hoverController,
              builder: (_, _) {
                final progress = _useManualProgress
                    ? _manualProgress
                    : _hoverController.value;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                        child: Center(
                          child: Text(
                            _useManualProgress
                                ? '${(progress * 100).round()}%'
                                : 'Hover aqui',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: AnimatedBorderPainter(
                          progress: progress,
                          color: colors.primary,
                          strokeWidth: _strokeWidth,
                          borderRadius: _borderRadius,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      controls: [
        PlaygroundSwitch(
          key: const Key('border-manual-switch'),
          label: 'Forcar progress (em vez de hover)',
          value: _useManualProgress,
          onChanged: (v) {
            setState(() {
              _useManualProgress = v;
              if (!v) _hoverController.value = 0;
            });
          },
        ),
        PlaygroundSlider(
          key: const Key('border-progress-slider'),
          label: 'Progress (manual)',
          value: _manualProgress,
          min: 0,
          max: 1,
          formatter: (v) => '${(v * 100).round()}%',
          onChanged: (v) => setState(() {
            _manualProgress = v;
            _useManualProgress = true;
          }),
        ),
        PlaygroundSlider(
          key: const Key('border-stroke-slider'),
          label: 'Stroke width',
          value: _strokeWidth,
          min: 0.5,
          max: 6,
          divisions: 11,
          formatter: (v) => '${v.toStringAsFixed(1)} px',
          onChanged: (v) => setState(() => _strokeWidth = v),
        ),
        PlaygroundSlider(
          key: const Key('border-radius-slider'),
          label: 'Border radius',
          value: _borderRadius,
          min: 0,
          max: 48,
          divisions: 12,
          formatter: (v) => '${v.round()} px',
          onChanged: (v) => setState(() => _borderRadius = v),
        ),
      ],
    );
  }
}
