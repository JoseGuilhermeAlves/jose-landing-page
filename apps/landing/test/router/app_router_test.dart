import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landing/presentation/locale_cubit.dart';
import 'package:landing/router/app_router.dart';
import 'package:landing/router/route_paths.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  group('AppRouter', () {
    testWidgets('rota inicial / renderiza HomePage', (tester) async {
      final router = AppRouter.create();

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => LocaleCubit(),
          child: MaterialApp.router(
            theme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byKey(const Key('home-page')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('rota desconhecida cai em NotFoundPage', (tester) async {
      final router = AppRouter.create(initialLocation: '/lugar-que-nao-existe');

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => LocaleCubit(),
          child: MaterialApp.router(
            theme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byKey(const Key('not-found-page')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('rota /demo/:id renderiza o mock pelo id', (tester) async {
      final router = AppRouter.create(
        initialLocation: RoutePaths.demoFor('delivery'),
      );

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => LocaleCubit(),
          child: MaterialApp.router(
            theme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            routerConfig: router,
          ),
        ),
      );
      // Pumps explicitos: o mock tem painters em loop infinito (pumpAndSettle
      // travaria).
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DeliveryDemo), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('rota /demo/:id com id desconhecido cai em NotFoundPage', (
      tester,
    ) async {
      final router = AppRouter.create(initialLocation: '/demo/inexistente');

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => LocaleCubit(),
          child: MaterialApp.router(
            theme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byKey(const Key('not-found-page')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    test('RoutePaths exporta rotas registradas', () {
      expect(RoutePaths.home, '/');
      expect(RoutePaths.notFoundFallback, '/404');
      expect(RoutePaths.demoFor('delivery'), '/demo/delivery');
    });
  });
}
