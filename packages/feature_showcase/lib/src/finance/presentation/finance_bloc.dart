import 'package:feature_showcase/src/finance/domain/order_side.dart';
import 'package:feature_showcase/src/finance/domain/portfolio_holding.dart';
import 'package:feature_showcase/src/finance/domain/trade.dart';
import 'package:feature_showcase/src/finance/presentation/finance_event.dart';
import 'package:feature_showcase/src/finance/presentation/finance_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc do mock Mira. Sem ticker — diferente do delivery, o mercado
/// nao muda autonomamente no demo (a tela do candlestick ja anima
/// sozinha via painter). As tres mutacoes sao: toggle favorito,
/// executar trade e reset.
///
/// Geracao de id de trade: contador incremental por sessao do bloc,
/// formato `T-XXXX`. Usar contador estavel facilita testes e nao
/// depende de DateTime.now().
class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc({
    required List<PortfolioHolding> initialHoldings,
    required List<Trade> initialTrades,
    Set<String>? initialFavoriteIds,
  }) : _initialHoldings = List.unmodifiable(initialHoldings),
       _initialTrades = List.unmodifiable(
         <Trade>[...initialTrades]
           ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
       ),
       _tradeCounter = initialTrades.length,
       super(
         FinanceState(
           holdings: List.unmodifiable(initialHoldings),
           trades: List.unmodifiable(
             <Trade>[...initialTrades]
               ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
           ),
           favoriteIds: Set<String>.unmodifiable(
             initialFavoriteIds ?? _defaultFavorites(initialHoldings),
           ),
         ),
       ) {
    on<FinanceFavoriteToggled>(_onFavoriteToggled);
    on<FinanceTradeExecuted>(_onTradeExecuted);
    on<FinanceSearchQueryChanged>(_onSearchQueryChanged);
    on<FinanceReset>(_onReset);
  }

  final List<PortfolioHolding> _initialHoldings;
  final List<Trade> _initialTrades;
  int _tradeCounter;

  /// Watchlist default — todos os ativos do portfolio inicial + alguns
  /// extras pra demonstrar acoes nao-detidas.
  static Set<String> _defaultFavorites(List<PortfolioHolding> holdings) {
    final ids = <String>{
      ...holdings.map((h) => h.assetId),
      'MGLU3',
      'TOTS3',
      'ELET3',
    };
    return ids;
  }

  void _onFavoriteToggled(
    FinanceFavoriteToggled event,
    Emitter<FinanceState> emit,
  ) {
    final next = Set<String>.from(state.favoriteIds);
    if (next.contains(event.assetId)) {
      next.remove(event.assetId);
    } else {
      next.add(event.assetId);
    }
    emit(state.copyWith(favoriteIds: Set<String>.unmodifiable(next)));
  }

  void _onTradeExecuted(
    FinanceTradeExecuted event,
    Emitter<FinanceState> emit,
  ) {
    final existing = state.holdingOf(event.assetId);
    final updatedHoldings = [...state.holdings];

    if (event.side == OrderSide.buy) {
      if (existing == null) {
        updatedHoldings.add(
          PortfolioHolding(
            assetId: event.assetId,
            quantity: event.quantity,
            avgPriceCents: event.priceCents,
          ),
        );
      } else {
        final totalQty = existing.quantity + event.quantity;
        final totalCost =
            existing.costBasisCents + event.quantity * event.priceCents;
        updatedHoldings
          ..removeWhere((h) => h.assetId == event.assetId)
          ..add(
            PortfolioHolding(
              assetId: event.assetId,
              quantity: totalQty,
              avgPriceCents: (totalCost / totalQty).round(),
            ),
          );
      }
    } else {
      if (existing == null) return;
      final remaining = existing.quantity - event.quantity;
      updatedHoldings.removeWhere((h) => h.assetId == event.assetId);
      if (remaining > 0) {
        updatedHoldings.add(
          PortfolioHolding(
            assetId: event.assetId,
            quantity: remaining,
            avgPriceCents: existing.avgPriceCents,
          ),
        );
      }
    }

    _tradeCounter += 1;
    final newTrade = Trade(
      id: 'T-${_tradeCounter.toString().padLeft(4, '0')}',
      assetId: event.assetId,
      side: event.side,
      quantity: event.quantity,
      priceCents: event.priceCents,
      timestamp: DateTime.now(),
    );

    emit(
      state.copyWith(
        holdings: List.unmodifiable(updatedHoldings),
        trades: List.unmodifiable([newTrade, ...state.trades]),
      ),
    );
  }

  void _onSearchQueryChanged(
    FinanceSearchQueryChanged event,
    Emitter<FinanceState> emit,
  ) {
    if (event.query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onReset(FinanceReset event, Emitter<FinanceState> emit) {
    _tradeCounter = _initialTrades.length;
    emit(
      FinanceState(
        holdings: _initialHoldings,
        trades: _initialTrades,
        favoriteIds: Set<String>.unmodifiable(
          _defaultFavorites(_initialHoldings),
        ),
      ),
    );
  }
}
