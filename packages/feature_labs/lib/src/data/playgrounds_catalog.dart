import 'package:feature_labs/src/domain/playground_descriptor.dart';
import 'package:feature_labs/src/router/labs_route_paths.dart';
import 'package:flutter/material.dart';

/// Catalogo dos 7 playgrounds — espelha 1:1 os Custom Painters do
/// `package:animations`. Ordem aqui define ordem dos cards na home
/// do `/labs`.
abstract final class PlaygroundsCatalog {
  static const List<PlaygroundDescriptor> all = [
    PlaygroundDescriptor(
      id: 'particles',
      label: 'Campo de particulas',
      shortDescription:
          'Particulas reagindo ao mouse — o background do hero. Mexa '
          'em quantidade, distancia de link e raio de influencia.',
      routePath: LabsRoutePaths.particles,
      icon: Icons.scatter_plot_outlined,
      painterName: 'ParticleFieldPainter',
    ),
    PlaygroundDescriptor(
      id: 'timeline',
      label: 'Timeline animada',
      shortDescription:
          'Linha temporal que se revela conforme entra na viewport, '
          'usando PathMetrics.extractPath.',
      routePath: LabsRoutePaths.timeline,
      icon: Icons.timeline_outlined,
      painterName: 'AnimatedTimelinePainter',
    ),
    PlaygroundDescriptor(
      id: 'border',
      label: 'Borda animada',
      shortDescription:
          'Contorno arredondado que se desenha sob hover — micro '
          'interacao usada nos cards de servicos.',
      routePath: LabsRoutePaths.border,
      icon: Icons.crop_square_outlined,
      painterName: 'AnimatedBorderPainter',
    ),
    PlaygroundDescriptor(
      id: 'spinner',
      label: 'Spinner customizado',
      shortDescription:
          'Substituto do CircularProgressIndicator nas trocas de '
          'rota — arco que cresce, encolhe e gira.',
      routePath: LabsRoutePaths.spinner,
      icon: Icons.refresh_outlined,
      painterName: 'LoadingSpinnerPainter',
    ),
    PlaygroundDescriptor(
      id: 'morphing',
      label: 'Forma morphando',
      shortDescription:
          'Interpolacao polar circulo -> blob -> quadrado. Demonstra '
          'controle de Path em coordenadas polares.',
      routePath: LabsRoutePaths.morphing,
      icon: Icons.auto_awesome_outlined,
      painterName: 'MorphingShapePainter',
    ),
    PlaygroundDescriptor(
      id: 'ripple',
      label: 'Ripple no hover',
      shortDescription:
          'Onda circular que expande do ponto onde o cursor entra. '
          'Tap o painel pra ver.',
      routePath: LabsRoutePaths.ripple,
      icon: Icons.touch_app_outlined,
      painterName: 'RippleHoverPainter',
    ),
    PlaygroundDescriptor(
      id: 'wave',
      label: 'Onda divisora',
      shortDescription:
          'Senoide horizontal animada — separador entre secoes. Mexa '
          'em amplitude, frequencia e fase.',
      routePath: LabsRoutePaths.wave,
      icon: Icons.waves_outlined,
      painterName: 'WaveDividerPainter',
    ),
  ];
}
