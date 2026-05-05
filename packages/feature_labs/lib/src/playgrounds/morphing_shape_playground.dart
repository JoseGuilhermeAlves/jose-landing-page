import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_labs/src/widgets/playground_scaffold.dart';
import 'package:flutter/material.dart';

/// Playground do `MorphingShapePainter`. Auto-cycle por padrao;
/// alternativamente o usuario fixa um progress especifico pra inspecionar
/// o midpoint (blob) ou os extremos (circulo, quadrado).
class MorphingShapePlayground extends StatefulWidget {
  const MorphingShapePlayground({super.key});

  @override
  State<MorphingShapePlayground> createState() =>
      _MorphingShapePlaygroundState();
}

class _MorphingShapePlaygroundState extends State<MorphingShapePlayground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  bool _autoCycle = true;
  double _manualProgress = 0.25;
  int _sampleCount = 72;
  bool _filled = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PlaygroundScaffold(
      title: 'Forma morphando',
      painterName: 'MorphingShapePainter',
      description:
          'Amostra N pontos ao longo do contorno em coordenadas polares '
          'e interpola o raio em cada angulo. Ciclo: circulo -> blob -> '
          'quadrado.',
      preview: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final progress = _autoCycle ? _controller.value : _manualProgress;
          return CustomPaint(
            painter: MorphingShapePainter(
              progress: progress,
              color: colors.primary,
              style: _filled ? PaintingStyle.fill : PaintingStyle.stroke,
              strokeWidth: 2,
              sampleCount: _sampleCount,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
      controls: [
        PlaygroundSwitch(
          key: const Key('morphing-autocycle-switch'),
          label: 'Auto-cycle',
          value: _autoCycle,
          onChanged: (v) => setState(() => _autoCycle = v),
        ),
        PlaygroundSlider(
          key: const Key('morphing-progress-slider'),
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
          key: const Key('morphing-samples-slider'),
          label: 'Pontos amostrados',
          value: _sampleCount.toDouble(),
          min: 8,
          max: 144,
          divisions: 17,
          formatter: (v) => v.round().toString(),
          onChanged: (v) => setState(() => _sampleCount = v.round()),
        ),
        PlaygroundSwitch(
          key: const Key('morphing-fill-switch'),
          label: 'Preenchido',
          value: _filled,
          onChanged: (v) => setState(() => _filled = v),
        ),
      ],
    );
  }
}
