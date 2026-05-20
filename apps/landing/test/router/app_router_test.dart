import 'package:design_system/design_system.dart';
import 'package:feature_labs/labs_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landing/router/app_router.dart';
import 'package:landing/router/route_paths.dart';

void main() {
  group('AppRouter', () {
    testWidgets('rota inicial / renderiza HomePage', (tester) async {
      final router = AppRouter.create();

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: router,
        ),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byKey(const Key('home-page')), findsOneWidget);

      // tear down animacoes pendentes
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('rota /labs renderiza LabsPage (deferred-loaded)',
        (tester) async {
      final router = AppRouter.create(initialLocation: RoutePaths.labs);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: router,
        ),
      );
      // Espera o loadLibrary do deferred resolver no test runtime.
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('labs-page')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('rota desconhecida cai em NotFoundPage', (tester) async {
      final router = AppRouter.create(initialLocation: '/lugar-que-nao-existe');

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.dark(),
          routerConfig: router,
        ),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byKey(const Key('not-found-page')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'sub-rotas de /labs renderizam o playground correspondente',
      (tester) async {
        // Mapa id -> (path, key esperada do playground). As keys vem do
        // PlaygroundScaffold, que tem playground-back-button + frame.
        const cases = <(String, String)>[
          (LabsRoutePaths.particles, 'Campo de particulas'),
          (LabsRoutePaths.timeline, 'Timeline animada'),
          (LabsRoutePaths.border, 'Borda animada'),
          (LabsRoutePaths.spinner, 'Spinner customizado'),
          (LabsRoutePaths.morphing, 'Forma morphando'),
          (LabsRoutePaths.ripple, 'Ripple no hover'),
          (LabsRoutePaths.wave, 'Onda divisora'),
        ];

        for (final (path, expectedTitle) in cases) {
          final router = AppRouter.create(initialLocation: path);
          await tester.pumpWidget(
            MaterialApp.router(
              theme: AppTheme.dark(),
              routerConfig: router,
            ),
          );
          // pumpAndSettle drena o loadLibrary do deferred wrapper.
          // Alguns playgrounds tem AnimationController em repeat —
          // por isso usamos pump explicito ao inves de settle.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 16));

          expect(
            find.byKey(const Key('playground-back-button')),
            findsOneWidget,
            reason: 'back button faltando em $path',
          );
          expect(
            find.text(expectedTitle),
            findsOneWidget,
            reason: 'titulo "$expectedTitle" faltando em $path',
          );

          await tester.pumpWidget(const SizedBox());
        }
      },
    );

    test('RoutePaths exporta todas as rotas registradas em uma constante',
        () {
      // Pegadinha facil de cometer: adicionar rota em um lugar e esquecer
      // de centralizar a string. Forcamos referencia simbolica.
      expect(RoutePaths.home, '/');
      expect(RoutePaths.labs, '/labs');
      expect(RoutePaths.labs, LabsRoutePaths.index);
    });
  });
}
