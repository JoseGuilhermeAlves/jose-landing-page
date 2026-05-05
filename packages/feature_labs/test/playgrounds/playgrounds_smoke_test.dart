import 'package:feature_labs/feature_labs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('Playgrounds smoke', () {
    // Cada playground precisa renderizar sem lancar e expor o titulo
    // declarado no PlaygroundScaffold. Especificos (slider, toggle)
    // ficam em testes proprios; este so confirma que a montagem nao
    // quebrou e o back button esta presente.
    final cases = <(String, Widget, String)>[
      (
        'particles',
        const ParticleFieldPlayground(),
        'Campo de particulas',
      ),
      (
        'timeline',
        const AnimatedTimelinePlayground(),
        'Timeline animada',
      ),
      (
        'border',
        const AnimatedBorderPlayground(),
        'Borda animada',
      ),
      (
        'spinner',
        const LoadingSpinnerPlayground(),
        'Spinner customizado',
      ),
      (
        'morphing',
        const MorphingShapePlayground(),
        'Forma morphando',
      ),
      (
        'ripple',
        const RippleHoverPlayground(),
        'Ripple no hover',
      ),
      (
        'wave',
        const WaveDividerPlayground(),
        'Onda divisora',
      ),
    ];

    for (final (id, widget, title) in cases) {
      testWidgets('$id renderiza com titulo "$title" e back button',
          (tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);

        await pumpLabsHarness(tester, widget);
        await tester.pump(const Duration(milliseconds: 16));

        expect(find.text(title), findsOneWidget);
        expect(
          find.byKey(const Key('playground-back-button')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('playground-preview-frame')), findsOneWidget);
      });
    }

  });
}
