import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Catalogo deterministico pros widget tests. Catalogo legado (sem
  // headline/city/features) — testa que o demo aguenta o caso minimo.
  const sample = [
    Property(
      id: 'a',
      neighborhood: 'Centro',
      type: PropertyType.apartment,
      bedrooms: 1,
      areaM2: 40,
      parkingSpots: 0,
      priceCents: 25000000,
    ),
    Property(
      id: 'b',
      neighborhood: 'Centro',
      type: PropertyType.apartment,
      bedrooms: 3,
      areaM2: 90,
      parkingSpots: 1,
      priceCents: 60000000,
    ),
    Property(
      id: 'c',
      neighborhood: 'Vila Nova',
      type: PropertyType.house,
      bedrooms: 4,
      areaM2: 200,
      parkingSpots: 2,
      priceCents: 110000000,
    ),
  ];

  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: child,
  );

  // Helper — abre o demo na home e empurra a listagem pelo CTA do hero.
  Future<void> openListings(WidgetTester tester) async {
    await tester.pumpWidget(wrap(const RealEstateDemo(properties: sample)));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.tap(find.byKey(const Key('solar-cta-listings')));
    await tester.pumpAndSettle();
  }

  group('RealEstateDemo · home', () {
    testWidgets('renderiza hero da marca Solar', (tester) async {
      tester.view.physicalSize = const Size(900, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrap(const RealEstateDemo(properties: sample)));
      await tester.pump(const Duration(milliseconds: 16));

      // Tagline da marca aparece + chip de bairros + CTA visivel.
      expect(find.text('Sua nova casa cabe aqui.'), findsOneWidget);
      expect(find.byKey(const Key('solar-cta-listings')), findsOneWidget);
      expect(
        find.byKey(const Key('solar-home-neighborhood-Centro')),
        findsOneWidget,
      );
    });

    testWidgets('tap em chip de bairro abre listagem ja filtrada', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrap(const RealEstateDemo(properties: sample)));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byKey(const Key('solar-home-neighborhood-Centro')));
      await tester.pumpAndSettle();

      // Listagem aberta com filtro Centro aplicado — so as duas
      // propriedades do bairro.
      expect(find.text('2 imoveis encontrados'), findsOneWidget);
    });
  });

  group('SolarListingsPage', () {
    testWidgets('lista todos os imoveis sem filtro', (tester) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await openListings(tester);

      // Header de contagem.
      expect(find.text('3 imoveis encontrados'), findsOneWidget);
      expect(find.byKey(const Key('solar-property-card-a')), findsOneWidget);
      expect(find.byKey(const Key('solar-property-card-b')), findsOneWidget);
      expect(find.byKey(const Key('solar-property-card-c')), findsOneWidget);
    });

    testWidgets('chip de bairro filtra a lista', (tester) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await openListings(tester);

      await tester.tap(find.byKey(const Key('solar-neighborhood-chip-Centro')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('2 imoveis encontrados'), findsOneWidget);
      expect(find.byKey(const Key('solar-property-card-c')), findsNothing);
    });

    testWidgets('chip de quartos 4+ casa imoveis com 4 ou mais', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await openListings(tester);

      await tester.tap(find.byKey(const Key('solar-bedroom-chip-4')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('1 imovel encontrado'), findsOneWidget);
      expect(find.byKey(const Key('solar-property-card-c')), findsOneWidget);
    });

    testWidgets('botao "Limpar filtros" zera selecao e some', (tester) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await openListings(tester);
      expect(find.byKey(const Key('solar-clear-filters')), findsNothing);

      await tester.tap(find.byKey(const Key('solar-neighborhood-chip-Centro')));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byKey(const Key('solar-clear-filters')), findsOneWidget);

      await tester.tap(find.byKey(const Key('solar-clear-filters')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('3 imoveis encontrados'), findsOneWidget);
      expect(find.byKey(const Key('solar-clear-filters')), findsNothing);
    });

    testWidgets('combinacao impossivel mostra empty state', (tester) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await openListings(tester);

      // Centro tem 1 e 3 quartos no sample — pedir 4+ zera resultado.
      await tester.tap(find.byKey(const Key('solar-neighborhood-chip-Centro')));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tap(find.byKey(const Key('solar-bedroom-chip-4')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('solar-property-card-a')), findsNothing);
      expect(find.text('Nenhum imovel com esses filtros'), findsOneWidget);
    });
  });

  group('SolarPropertyDetailPage', () {
    testWidgets('abre detalhe via tap no card e mostra headline + preco', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      // Usa o catalogo canonico (com headline) — o sample minimo
      // nao tem headline pra checar.
      await tester.pumpWidget(wrap(const RealEstateDemo()));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tap(find.byKey(const Key('solar-cta-listings')));
      await tester.pumpAndSettle();

      // Tap no primeiro card do catalogo canonico (p-1001).
      await tester.tap(find.byKey(const Key('solar-property-card-p-1001')));
      // SolarNeighborhoodMap na detalhe roda em loop infinito —
      // pumpAndSettle nao termina. Pumps explicitos cobrem o push.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('solar-detail-headline')), findsOneWidget);
      expect(find.byKey(const Key('solar-detail-price')), findsOneWidget);
      // CTA pro corretor.
      expect(find.byKey(const Key('solar-detail-contact-cta')), findsOneWidget);
    });
  });
}
