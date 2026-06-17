import 'package:bloc_test/bloc_test.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinanceBloc', () {
    FinanceBloc build() => FinanceBloc(
      initialHoldings: MiraPortfolioCatalog.initial,
      initialTrades: MiraTradesCatalog.initial,
    );

    test('estado inicial: holdings e trades carregados', () {
      final bloc = build();
      expect(bloc.state.holdings, MiraPortfolioCatalog.initial);
      expect(bloc.state.trades.length, MiraTradesCatalog.initial.length);
      expect(bloc.state.favoriteIds, contains('PETR4'));
      expect(bloc.state.favoriteIds, contains('MGLU3'));
    });

    blocTest<FinanceBloc, FinanceState>(
      'favorite toggle: adiciona quando ausente',
      build: build,
      seed: () =>
          const FinanceState(holdings: [], trades: [], favoriteIds: {'PETR4'}),
      act: (bloc) => bloc.add(const FinanceFavoriteToggled('VALE3')),
      expect: () => [
        isA<FinanceState>().having((s) => s.favoriteIds, 'favoriteIds', {
          'PETR4',
          'VALE3',
        }),
      ],
    );

    blocTest<FinanceBloc, FinanceState>(
      'favorite toggle: remove quando presente',
      build: build,
      seed: () => const FinanceState(
        holdings: [],
        trades: [],
        favoriteIds: {'PETR4', 'VALE3'},
      ),
      act: (bloc) => bloc.add(const FinanceFavoriteToggled('VALE3')),
      expect: () => [
        isA<FinanceState>().having((s) => s.favoriteIds, 'favoriteIds', {
          'PETR4',
        }),
      ],
    );

    blocTest<FinanceBloc, FinanceState>(
      'buy: adiciona holding novo quando nao havia posicao',
      build: build,
      seed: () => const FinanceState(holdings: [], trades: [], favoriteIds: {}),
      act: (bloc) => bloc.add(
        const FinanceTradeExecuted(
          assetId: 'MGLU3',
          side: OrderSide.buy,
          quantity: 50,
          priceCents: 1000,
        ),
      ),
      verify: (bloc) {
        final h = bloc.state.holdingOf('MGLU3');
        expect(h, isNotNull);
        expect(h!.quantity, 50);
        expect(h.avgPriceCents, 1000);
        expect(bloc.state.trades.first.assetId, 'MGLU3');
        expect(bloc.state.trades.first.side, OrderSide.buy);
      },
    );

    blocTest<FinanceBloc, FinanceState>(
      'buy: aumenta posicao existente com custo medio ponderado',
      build: build,
      seed: () => const FinanceState(
        holdings: [
          PortfolioHolding(
            assetId: 'PETR4',
            quantity: 100,
            avgPriceCents: 3000,
          ),
        ],
        trades: [],
        favoriteIds: {},
      ),
      act: (bloc) => bloc.add(
        const FinanceTradeExecuted(
          assetId: 'PETR4',
          side: OrderSide.buy,
          quantity: 100,
          priceCents: 4000,
        ),
      ),
      verify: (bloc) {
        final h = bloc.state.holdingOf('PETR4');
        expect(h, isNotNull);
        expect(h!.quantity, 200);
        expect(h.avgPriceCents, 3500);
      },
    );

    blocTest<FinanceBloc, FinanceState>(
      'sell: reduz quantidade e mantem preco medio',
      build: build,
      seed: () => const FinanceState(
        holdings: [
          PortfolioHolding(
            assetId: 'PETR4',
            quantity: 100,
            avgPriceCents: 3500,
          ),
        ],
        trades: [],
        favoriteIds: {},
      ),
      act: (bloc) => bloc.add(
        const FinanceTradeExecuted(
          assetId: 'PETR4',
          side: OrderSide.sell,
          quantity: 30,
          priceCents: 4000,
        ),
      ),
      verify: (bloc) {
        final h = bloc.state.holdingOf('PETR4');
        expect(h, isNotNull);
        expect(h!.quantity, 70);
        expect(h.avgPriceCents, 3500);
      },
    );

    blocTest<FinanceBloc, FinanceState>(
      'sell ate zerar remove o holding completamente',
      build: build,
      seed: () => const FinanceState(
        holdings: [
          PortfolioHolding(
            assetId: 'PETR4',
            quantity: 100,
            avgPriceCents: 3500,
          ),
        ],
        trades: [],
        favoriteIds: {},
      ),
      act: (bloc) => bloc.add(
        const FinanceTradeExecuted(
          assetId: 'PETR4',
          side: OrderSide.sell,
          quantity: 100,
          priceCents: 4000,
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.holdingOf('PETR4'), isNull);
        expect(bloc.state.holdings, isEmpty);
        expect(bloc.state.trades.first.side, OrderSide.sell);
      },
    );

    blocTest<FinanceBloc, FinanceState>(
      'reset: volta aos holdings e trades iniciais',
      build: build,
      act: (bloc) => bloc
        ..add(
          const FinanceTradeExecuted(
            assetId: 'MGLU3',
            side: OrderSide.buy,
            quantity: 100,
            priceCents: 1000,
          ),
        )
        ..add(const FinanceReset()),
      skip: 1,
      verify: (bloc) {
        expect(bloc.state.holdings, MiraPortfolioCatalog.initial);
        expect(bloc.state.trades.length, MiraTradesCatalog.initial.length);
      },
    );
  });
}
