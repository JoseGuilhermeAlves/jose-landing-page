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
        MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byKey(const Key('home-page')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('rota desconhecida cai em NotFoundPage', (tester) async {
      final router = AppRouter.create(initialLocation: '/lugar-que-nao-existe');

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byKey(const Key('not-found-page')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    test('RoutePaths exporta rotas registradas', () {
      expect(RoutePaths.home, '/');
      expect(RoutePaths.notFoundFallback, '/404');
    });
  });
}
