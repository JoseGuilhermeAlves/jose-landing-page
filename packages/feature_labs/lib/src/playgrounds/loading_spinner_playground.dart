import 'package:animations/animations.dart';
import 'package:feature_labs/src/widgets/playground_scaffold.dart';
import 'package:flutter/material.dart';

/// Playground do `LoadingSpinnerPainter`. O widget host
/// (`LoadingSpinner`) recebe size, strokeWidth e duration via
/// constructor e cuida da animacao.
class LoadingSpinnerPlayground extends StatefulWidget {
  const LoadingSpinnerPlayground({super.key});

  @override
  State<LoadingSpinnerPlayground> createState() =>
      _LoadingSpinnerPlaygroundState();
}

class _LoadingSpinnerPlaygroundState extends State<LoadingSpinnerPlayground> {
  double _size = 64;
  double _strokeWidth = 3;
  int _durationMs = 1100;

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      title: 'Spinner customizado',
      painterName: 'LoadingSpinnerPainter',
      description:
          'Substitui o CircularProgressIndicator nas trocas de rota e '
          'fetches mockados. O arco oscila entre 18% e 92% do circulo '
          'enquanto gira — sensacao de "respirar".',
      preview: Center(
        child: LoadingSpinner(
          // ValueKey pra recriar quando duration mudar (controller le no
          // initState; updates dependem do didUpdateWidget do widget host).
          key: ValueKey('spinner-$_durationMs'),
          size: _size,
          strokeWidth: _strokeWidth,
          duration: Duration(milliseconds: _durationMs),
        ),
      ),
      controls: [
        PlaygroundSlider(
          key: const Key('spinner-size-slider'),
          label: 'Tamanho',
          value: _size,
          min: 16,
          max: 160,
          divisions: 36,
          formatter: (v) => '${v.round()} px',
          onChanged: (v) => setState(() => _size = v),
        ),
        PlaygroundSlider(
          key: const Key('spinner-stroke-slider'),
          label: 'Stroke width',
          value: _strokeWidth,
          min: 1,
          max: 12,
          divisions: 22,
          formatter: (v) => '${v.toStringAsFixed(1)} px',
          onChanged: (v) => setState(() => _strokeWidth = v),
        ),
        PlaygroundSlider(
          key: const Key('spinner-duration-slider'),
          label: 'Duracao do ciclo',
          value: _durationMs.toDouble(),
          min: 300,
          max: 3000,
          divisions: 27,
          formatter: (v) => '${v.round()} ms',
          onChanged: (v) => setState(() => _durationMs = v.round()),
        ),
      ],
    );
  }
}
