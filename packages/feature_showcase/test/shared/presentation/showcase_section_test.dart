import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );

  group('ShowcaseSection', () {
    testWidgets('renderiza um ShowcaseCard pra cada nicho do catalogo', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.byType(ShowcaseCard),
        findsNWidgets(ShowcaseCatalog.all.length),
      );
    });

    testWidgets('todos os templates do catalogo tem demo plugada', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      // Todos os nichos da vitrine ja estao com hasDemo=true; nao
      // existe mais badge "em breve" na home.
      expect(find.textContaining('em breve'), findsNothing);
    });

    testWidgets('tap no card de delivery abre o DeliveryDemo em modal', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byKey(const Key('showcase-card-delivery')));
      // pumpAndSettle nao serve aqui porque o `AuroraHeroBackdrop` e o
      // mapa do DeliveryDemo rodam em loop infinito. Pumpamos frames
      // fixos pra a route de modal terminar de abrir.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(DeliveryDemo), findsOneWidget);
    });

    testWidgets('tap no card de scheduling abre o SchedulingDemo em modal', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      // Scheduling fica em row 2 do grid no viewport de teste (800px),
      // entao precisa rolar pra ficar dentro da hit area antes do tap.
      final card = find.byKey(const Key('showcase-card-scheduling'));
      await tester.ensureVisible(card);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(card);
      // pumpAndSettle nao serve aqui porque o `VitralHeroBackdrop` e o
      // relogio do SchedulingDemo rodam em loop infinito. Pumpamos
      // frames fixos pra a route de modal terminar de abrir.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(SchedulingDemo), findsOneWidget);
    });

    testWidgets('tap no card de fitness abre o FitnessDemo em modal', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      final card = find.byKey(const Key('showcase-card-fitness'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      // PulsoHomePage tem painters animando em loop infinito (athlete
      // figure, activity rings); pumpAndSettle nao termina. Pumps
      // explicitos cobrem o push da MaterialPageRoute + um frame extra
      // pra o Theme/Bloc montarem.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FitnessDemo), findsOneWidget);
    });

    testWidgets('tap no card de imobiliaria abre o RealEstateDemo em modal', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      final card = find.byKey(const Key('showcase-card-realestate'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      // SolarHomePage tem SolarHeroBackdrop animando em loop;
      // pumpAndSettle nao termina. Pumps explicitos cobrem o push.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(RealEstateDemo), findsOneWidget);
    });

    testWidgets('tap no card de finance abre o FinanceDemo em modal', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      final card = find.byKey(const Key('showcase-card-finance'));
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FinanceDemo), findsOneWidget);
    });
  });
}
