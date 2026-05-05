import 'package:feature_labs/feature_labs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('LabsPage', () {
    testWidgets('renderiza um card pra cada playground do catalogo',
        (tester) async {
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

    testWidgets('renderiza secao de decisoes arquiteturais', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpLabsHarness(tester, const LabsPage());
      await tester.pumpAndSettle();

      expect(find.text('Decisoes arquiteturais'), findsOneWidget);
      // Pelo menos 5 cards de decisao (PROJECT.md tem 7 atualmente,
      // mas teste fica resiliente a adicao/remocao).
      expect(
        find.byKey(const Key('architecture-decision-card')),
        findsAtLeast(5),
      );
    });

    testWidgets(
      'botao de GitHub aparece so quando githubUrl e fornecido',
      (tester) async {
        await pumpLabsHarness(tester, const LabsPage());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('labs-github-button')), findsNothing);

        var clicked = '';
        await pumpLabsHarness(
          tester,
          LabsPage(
            githubUrl: 'https://github.com/example/repo',
            onOpenGithub: (url) => clicked = url,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('labs-github-button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('labs-github-button')));
        await tester.pumpAndSettle();
        expect(clicked, 'https://github.com/example/repo');
      },
    );

    testWidgets('tap em card navega pra sub-rota correspondente',
        (tester) async {
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
