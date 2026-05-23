import 'package:feature_labs/feature_labs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('AnimatedTimelinePlayground', () {
    // Nota: o playground tem AnimationController em `repeat(reverse:
    // true)`, entao pumpAndSettle trava (a animacao nunca completa).
    // Use pump(Duration) explicito apos interacoes.

    testWidgets('autocycle switch responde ao tap', (tester) async {
      await pumpLabsHarness(tester, const AnimatedTimelinePlayground());
      await tester.pump(const Duration(milliseconds: 16));

      final switchFinder = find.byKey(const Key('timeline-autocycle-switch'));
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
    });

    testWidgets('progress slider muda valor sem lancar', (tester) async {
      await pumpLabsHarness(tester, const AnimatedTimelinePlayground());
      await tester.pump(const Duration(milliseconds: 16));

      // Mira o Slider real dentro do PlaygroundSlider — o tester.drag
      // no PlaygroundSlider em si mira o centro da Column e erra o thumb.
      final inner = find.descendant(
        of: find.byKey(const Key('timeline-progress-slider')),
        matching: find.byType(Slider),
      );
      expect(inner, findsOneWidget);

      await tester.drag(inner, const Offset(60, 0));
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
      // Apos drag, o formatter exibe % — confirma rebuild com valor novo.
      expect(find.textContaining('%'), findsAtLeast(1));
    });

    testWidgets('slider de marcadores aceita drag', (tester) async {
      await pumpLabsHarness(tester, const AnimatedTimelinePlayground());
      await tester.pump(const Duration(milliseconds: 16));

      final inner = find.descendant(
        of: find.byKey(const Key('timeline-markers-slider')),
        matching: find.byType(Slider),
      );
      expect(inner, findsOneWidget);

      await tester.drag(inner, const Offset(80, 0));
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
    });
  });
}
