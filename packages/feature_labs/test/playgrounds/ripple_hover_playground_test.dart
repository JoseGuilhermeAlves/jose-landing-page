import 'package:feature_labs/feature_labs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('RippleHoverPlayground', () {
    testWidgets(
      'estado inicial mostra cta "tap ou passe o mouse"',
      (tester) async {
        await pumpLabsHarness(tester, const RippleHoverPlayground());
        await tester.pump(const Duration(milliseconds: 16));

        expect(find.textContaining('Tap ou passe o mouse'), findsOneWidget);
      },
    );

    testWidgets('tap no painel inicia o ripple', (tester) async {
      await pumpLabsHarness(tester, const RippleHoverPlayground());
      await tester.pump(const Duration(milliseconds: 16));

      final target = find.byKey(const Key('ripple-tap-target'));
      expect(target, findsOneWidget);

      // tapAt usa coordenadas globais. Pegamos o center do widget.
      final center = tester.getCenter(target);
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 50));

      // Apos o tap, o cta sumiu (estado mudou).
      expect(find.textContaining('Tap ou passe o mouse'), findsNothing);
      // E o controller do ripple esta animando — pumpAndSettle drena.
      await tester.pumpAndSettle(const Duration(milliseconds: 1200));
    });

    testWidgets('cap radius switch alterna comportamento', (tester) async {
      await pumpLabsHarness(tester, const RippleHoverPlayground());
      await tester.pump(const Duration(milliseconds: 16));

      final cap = find.byKey(const Key('ripple-cap-switch'));
      expect(cap, findsOneWidget);
      await tester.tap(cap);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
