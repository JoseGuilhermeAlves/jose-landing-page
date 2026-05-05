import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_labs/src/widgets/playground_scaffold.dart';
import 'package:flutter/material.dart';

/// Playground do `WaveDividerPainter`. Auto-anima a fase via
/// controller; sliders mexem em amplitude, frequencia e estilo.
class WaveDividerPlayground extends StatefulWidget {
  const WaveDividerPlayground({super.key});

  @override
  State<WaveDividerPlayground> createState() => _WaveDividerPlaygroundState();
}

class _WaveDividerPlaygroundState extends State<WaveDividerPlayground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  bool _autoFlow = true;
  double _manualPhase = 0;
  double _amplitude = 12;
  double _frequency = 2;
  bool _filled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PlaygroundScaffold(
      title: 'Onda divisora',
      painterName: 'WaveDividerPainter',
      description:
          'Senoide horizontal animada — separador entre secoes da '
          'landing. A fase desliza em loop; amplitude e frequencia '
          'controlam a curva.',
      preview: Center(
        child: SizedBox(
          height: 80,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) {
              final phase = _autoFlow ? _controller.value : _manualPhase;
              return CustomPaint(
                painter: WaveDividerPainter(
                  phase: phase,
                  color: colors.primary,
                  amplitude: _amplitude,
                  frequency: _frequency,
                  style: _filled ? PaintingStyle.fill : PaintingStyle.stroke,
                  strokeWidth: 2,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      ),
      controls: [
        PlaygroundSwitch(
          key: const Key('wave-autoflow-switch'),
          label: 'Auto-flow (fase em loop)',
          value: _autoFlow,
          onChanged: (v) => setState(() => _autoFlow = v),
        ),
        PlaygroundSlider(
          key: const Key('wave-phase-slider'),
          label: 'Fase (manual)',
          value: _manualPhase,
          min: 0,
          max: 1,
          formatter: (v) => v.toStringAsFixed(2),
          onChanged: (v) => setState(() {
            _manualPhase = v;
            _autoFlow = false;
          }),
        ),
        PlaygroundSlider(
          key: const Key('wave-amplitude-slider'),
          label: 'Amplitude',
          value: _amplitude,
          min: 0,
          max: 32,
          divisions: 32,
          formatter: (v) => '${v.round()} px',
          onChanged: (v) => setState(() => _amplitude = v),
        ),
        PlaygroundSlider(
          key: const Key('wave-frequency-slider'),
          label: 'Frequencia',
          value: _frequency,
          min: 0.5,
          max: 8,
          divisions: 30,
          formatter: (v) => v.toStringAsFixed(1),
          onChanged: (v) => setState(() => _frequency = v),
        ),
        PlaygroundSwitch(
          key: const Key('wave-fill-switch'),
          label: 'Preencher abaixo',
          value: _filled,
          onChanged: (v) => setState(() => _filled = v),
        ),
      ],
    );
  }
}
