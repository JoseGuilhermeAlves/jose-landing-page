import 'package:animations/animations.dart';
import 'package:feature_labs/src/widgets/playground_scaffold.dart';
import 'package:flutter/material.dart';

/// Playground do `ParticleFieldPainter`. Reaproveita o widget host
/// `ParticleField` (que ja cuida de controller, throttle de mouse e
/// pointer) e expoe os parametros estruturais via slider.
class ParticleFieldPlayground extends StatefulWidget {
  const ParticleFieldPlayground({super.key});

  @override
  State<ParticleFieldPlayground> createState() =>
      _ParticleFieldPlaygroundState();
}

class _ParticleFieldPlaygroundState extends State<ParticleFieldPlayground> {
  int _particleCount = 36;
  double _linkDistance = 90;
  int _durationSeconds = 12;

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      title: 'Campo de particulas',
      painterName: 'ParticleFieldPainter',
      description:
          'O background do hero. Particulas em drift senoidal sao '
          'empurradas radialmente quando o ponteiro entra no raio de '
          'influencia. Mexa o mouse no preview pra sentir o efeito.',
      preview: ParticleField(
        // Key forca recriacao quando seed muda — caso queira no futuro.
        key: ValueKey('particles-$_particleCount-$_durationSeconds'),
        particleCount: _particleCount,
        linkDistance: _linkDistance,
        duration: Duration(seconds: _durationSeconds),
      ),
      controls: [
        PlaygroundSlider(
          key: const Key('particles-count-slider'),
          label: 'Quantidade',
          value: _particleCount.toDouble(),
          min: 10,
          max: 80,
          divisions: 14,
          formatter: (v) => '${v.round()} particulas',
          onChanged: (v) => setState(() => _particleCount = v.round()),
        ),
        PlaygroundSlider(
          key: const Key('particles-link-slider'),
          label: 'Distancia de link',
          value: _linkDistance,
          min: 30,
          max: 160,
          divisions: 26,
          formatter: (v) => '${v.round()} px',
          onChanged: (v) => setState(() => _linkDistance = v),
        ),
        PlaygroundSlider(
          key: const Key('particles-duration-slider'),
          label: 'Duracao do ciclo',
          value: _durationSeconds.toDouble(),
          min: 4,
          max: 30,
          divisions: 26,
          formatter: (v) => '${v.round()} s',
          onChanged: (v) => setState(() => _durationSeconds = v.round()),
        ),
      ],
    );
  }
}
