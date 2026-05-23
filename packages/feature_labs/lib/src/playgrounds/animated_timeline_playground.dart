import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_labs/src/widgets/playground_scaffold.dart';
import 'package:flutter/material.dart';

/// Playground do `AnimatedTimelinePainter`. Toggle entre auto-cycle
/// (controller em loop) e progress manual via slider; quantidade de
/// marcadores tambem ajustavel.
class AnimatedTimelinePlayground extends StatefulWidget {
  const AnimatedTimelinePlayground({super.key});

  @override
  State<AnimatedTimelinePlayground> createState() =>
      _AnimatedTimelinePlaygroundState();
}

class _AnimatedTimelinePlaygroundState extends State<AnimatedTimelinePlayground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  bool _autoCycle = true;
  double _manualProgress = 0.5;
  int _markerCount = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PlaygroundScaffold(
      title: 'Timeline animada',
      painterName: 'AnimatedTimelinePainter',
      description:
          'Linha vertical que se revela progressivamente via '
          'PathMetrics.extractPath. Cada marcador entra quando a linha '
          'atravessa seu centro.',
      preview: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final progress = _autoCycle ? _controller.value : _manualProgress;
          return CustomPaint(
            painter: AnimatedTimelinePainter(
              progress: progress,
              markerCount: _markerCount,
              lineColor: colors.primary,
              markerColor: colors.surface,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
      controls: [
        PlaygroundSwitch(
          key: const Key('timeline-autocycle-switch'),
          label: 'Auto-cycle',
          value: _autoCycle,
          onChanged: (v) => setState(() => _autoCycle = v),
        ),
        PlaygroundSlider(
          key: const Key('timeline-progress-slider'),
          label: 'Progress (manual)',
          value: _manualProgress,
          min: 0,
          max: 1,
          formatter: (v) => '${(v * 100).round()}%',
          onChanged: (v) => setState(() {
            _manualProgress = v;
            _autoCycle = false;
          }),
        ),
        PlaygroundSlider(
          key: const Key('timeline-markers-slider'),
          label: 'Quantidade de marcadores',
          value: _markerCount.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          formatter: (v) => '${v.round()} marcadores',
          onChanged: (v) => setState(() => _markerCount = v.round()),
        ),
      ],
    );
  }
}
