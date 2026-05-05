import 'package:design_system/design_system.dart';
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

    test('RoutePaths exporta todas as rotas registradas em uma constante',
        () {
      // Pegadinha facil de cometer: adicionar rota em um lugar e esquecer
      // de centralizar a string. Forcamos referencia simbolica.
      expect(RoutePaths.home, '/');
      expect(RoutePaths.labs, '/labs');
    });
  });
}
