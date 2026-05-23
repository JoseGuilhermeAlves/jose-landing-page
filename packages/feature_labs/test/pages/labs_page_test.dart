import 'package:feature_labs/feature_labs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('LabsPage', () {
    testWidgets('renderiza um card pra cada playground do catalogo', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpLabsHarness(tester, const LabsPage());
      await tester.pumpAndSettle();

      for (final p in PlaygroundsCatalog.all) {
        expect(
          find.byKey(Key('labs-card-${p.id}')),
          findsOneWidget,
          reason: 'card faltando para ${p.id}',
        );
      }
    });

    testWidgets('tap em card navega pra sub-rota correspondente', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpLabsHarness(tester, const LabsPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('labs-card-particles')));
      await tester.pumpAndSettle();

      // Helper redireciona qualquer sub-rota pra um placeholder
      // identificado por essa key — basta verificar que saimos do index.
      expect(find.byKey(const Key('test-placeholder')), findsOneWidget);
    });
  });
}
