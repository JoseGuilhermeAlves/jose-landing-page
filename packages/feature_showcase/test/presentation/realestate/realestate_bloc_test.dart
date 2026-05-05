import 'package:bloc_test/bloc_test.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Catalogo enxuto pra exercitar todos os filtros sem ruido.
  const properties = [
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
    Property(
      id: 'd',
      neighborhood: 'Vila Nova',
      type: PropertyType.house,
      bedrooms: 5,
      areaM2: 280,
      parkingSpots: 3,
      priceCents: 180000000,
    ),
  ];

  RealEstateBloc makeBloc() =>
      RealEstateBloc(initialProperties: properties);

  group('RealEstateBloc', () {
    test('estado inicial: sem filtros, lista filtrada = catalogo todo', () {
      final bloc = makeBloc();
      expect(bloc.state.filtered, properties);
      expect(bloc.state.hasActiveFilters, isFalse);
      bloc.close();
    });

    blocTest<RealEstateBloc, RealEstateState>(
      'NeighborhoodSelected aplica filtro por bairro',
      build: makeBloc,
      act: (bloc) =>
          bloc.add(const RealEstateNeighborhoodSelected('Centro')),
      verify: (bloc) {
        expect(bloc.state.selectedNeighborhood, 'Centro');
        expect(bloc.state.filtered.map((p) => p.id), ['a', 'b']);
      },
    );

    blocTest<RealEstateBloc, RealEstateState>(
      'NeighborhoodSelected re-emitido limpa o filtro (toggle)',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(const RealEstateNeighborhoodSelected('Centro'))
        ..add(const RealEstateNeighborhoodSelected('Centro')),
      verify: (bloc) {
        expect(bloc.state.selectedNeighborhood, isNull);
        expect(bloc.state.filtered, properties);
      },
    );

    blocTest<RealEstateBloc, RealEstateState>(
      'BedroomsSelected = 4 abrange imoveis com 4 ou mais',
      build: makeBloc,
      act: (bloc) => bloc.add(const RealEstateBedroomsSelected(4)),
      verify: (bloc) {
        expect(bloc.state.filtered.map((p) => p.id), ['c', 'd']);
      },
    );

    blocTest<RealEstateBloc, RealEstateState>(
      'BedroomsSelected = 1 filtra exato',
      build: makeBloc,
      act: (bloc) => bloc.add(const RealEstateBedroomsSelected(1)),
      verify: (bloc) {
        expect(bloc.state.filtered.map((p) => p.id), ['a']);
      },
    );

    blocTest<RealEstateBloc, RealEstateState>(
      'MaxPriceChanged filtra por teto de preco',
      build: makeBloc,
      act: (bloc) =>
          bloc.add(const RealEstateMaxPriceChanged(60000000)),
      verify: (bloc) {
        expect(bloc.state.filtered.map((p) => p.id), ['a', 'b']);
      },
    );

    blocTest<RealEstateBloc, RealEstateState>(
      'MaxPriceChanged(null) limpa o filtro de preco',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(const RealEstateMaxPriceChanged(60000000))
        ..add(const RealEstateMaxPriceChanged(null)),
      verify: (bloc) {
        expect(bloc.state.maxPriceCents, isNull);
        expect(bloc.state.filtered, properties);
      },
    );

    blocTest<RealEstateBloc, RealEstateState>(
      'filtros se compoem (AND): bairro + quartos + preco',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(const RealEstateNeighborhoodSelected('Vila Nova'))
        ..add(const RealEstateBedroomsSelected(4))
        ..add(const RealEstateMaxPriceChanged(150000000)),
      verify: (bloc) {
        // Vila Nova + 4+ + ate 1.5M = so 'c' (110M, 4 quartos).
        expect(bloc.state.filtered.map((p) => p.id), ['c']);
        expect(bloc.state.hasActiveFilters, isTrue);
      },
    );

    blocTest<RealEstateBloc, RealEstateState>(
      'FiltersCleared zera tudo',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(const RealEstateNeighborhoodSelected('Centro'))
        ..add(const RealEstateBedroomsSelected(2))
        ..add(const RealEstateMaxPriceChanged(50000000))
        ..add(const RealEstateFiltersCleared()),
      verify: (bloc) {
        expect(bloc.state.selectedNeighborhood, isNull);
        expect(bloc.state.selectedBedrooms, isNull);
        expect(bloc.state.maxPriceCents, isNull);
        expect(bloc.state.filtered, properties);
        expect(bloc.state.hasActiveFilters, isFalse);
      },
    );

    blocTest<RealEstateBloc, RealEstateState>(
      'filtros que nao casam com nada produzem lista vazia',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(const RealEstateNeighborhoodSelected('Centro'))
        // Centro so tem 1 e 3 quartos — 4+ filtra tudo.
        ..add(const RealEstateBedroomsSelected(4)),
      verify: (bloc) => expect(bloc.state.filtered, isEmpty),
    );
  });
}
