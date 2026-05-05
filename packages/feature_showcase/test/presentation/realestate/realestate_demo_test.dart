import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: child,
      );

  // Catalogo deterministico pros widget tests.
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

  group('RealEstateDemo', () {
    testWidgets('renderiza um card pra cada imovel sem filtro',
        (tester) async {
      // Largura grande pra todos os 3 cards caberem na tela do tester.
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrap(const RealEstateDemo(properties: sample)));
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.byKey(const Key('realestate-property-card')),
        findsNWidgets(3),
      );
    });

    testWidgets('chip de bairro filtra a lista', (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrap(const RealEstateDemo(properties: sample)));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(
        find.byKey(const Key('realestate-neighborhood-chip-Centro')),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(const Key('realestate-property-card')),
        findsNWidgets(2),
      );
      expect(find.text('2 imoveis'), findsOneWidget);
    });

    testWidgets('chip de quartos 4+ casa imoveis com 4 ou mais',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrap(const RealEstateDemo(properties: sample)));
      await tester.pump(const Duration(milliseconds: 16));

      await tester
          .tap(find.byKey(const Key('realestate-bedroom-chip-4')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(const Key('realestate-property-card')),
        findsOneWidget,
      );
      expect(find.text('1 imovel'), findsOneWidget);
    });

    testWidgets('botao "Limpar filtros" reaparece e zera a selecao',
        (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrap(const RealEstateDemo(properties: sample)));
      await tester.pump(const Duration(milliseconds: 16));

      // Sem filtros, botao nao existe ainda.
      expect(
        find.byKey(const Key('realestate-clear-filters')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const Key('realestate-neighborhood-chip-Centro')),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(const Key('realestate-clear-filters')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('realestate-clear-filters')));
      await tester.pump(const Duration(milliseconds: 50));

      // Tudo de volta.
      expect(
        find.byKey(const Key('realestate-property-card')),
        findsNWidgets(3),
      );
      expect(
        find.byKey(const Key('realestate-clear-filters')),
        findsNothing,
      );
    });

    testWidgets('combinacao impossivel mostra empty state', (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(wrap(const RealEstateDemo(properties: sample)));
      await tester.pump(const Duration(milliseconds: 16));

      // Centro tem 1 e 3 quartos no sample — pedir 4+ zera resultado.
      await tester.tap(
        find.byKey(const Key('realestate-neighborhood-chip-Centro')),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await tester
          .tap(find.byKey(const Key('realestate-bedroom-chip-4')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(const Key('realestate-property-card')),
        findsNothing,
      );
      expect(find.text('Nenhum imovel com esses filtros'), findsOneWidget);
    });
  });
}
