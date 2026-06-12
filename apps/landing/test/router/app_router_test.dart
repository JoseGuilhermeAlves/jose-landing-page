import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landing/presentation/locale_cubit.dart';
import 'package:landing/router/app_router.dart';
import 'package:landing/router/route_paths.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  // Sem isso o VisibilityDetector (SectionVisibility da home) agenda um
  // Timer de 500ms que fica pendente quando o teste descarta a arvore.
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

    test('RoutePaths exporta rotas registradas', () {
      expect(RoutePaths.home, '/');
      expect(RoutePaths.notFoundFallback, '/404');
    });
  });
}
