import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/finance/data/mira_assets_catalog.dart';
import 'package:feature_showcase/src/finance/domain/asset.dart';
import 'package:feature_showcase/src/finance/domain/portfolio_holding.dart';
import 'package:feature_showcase/src/finance/domain/trade.dart';
import 'package:flutter/foundation.dart';

@immutable
class FinanceState extends Equatable {
  const FinanceState({
    required this.holdings,
    required this.trades,
    required this.favoriteIds,
    this.searchQuery = '',
  });

  /// Posicoes consolidadas do investidor. Chave implicita: `assetId`
  /// — nao ha duplicatas (a regra de fusao de compra/venda mantem
  /// um holding por ativo).
  final List<PortfolioHolding> holdings;

  /// Historico de trades em ordem cronologica (mais recente primeiro).
  final List<Trade> trades;

  /// Watchlist — ids dos ativos marcados como favoritos.
  final Set<String> favoriteIds;

  /// Termo de busca corrente da home (watchlist/catalogo). Vazio quando
  /// nenhum filtro esta ativo.
  final String searchQuery;

  /// True quando ha um termo de busca ativo (apos trim).
  bool get hasSearchQuery => searchQuery.trim().isNotEmpty;

  /// Valor de mercado total do portfolio em centavos, dado o catalogo
  /// de precos correntes.
  int get marketValueCents {
    var total = 0;
    for (final h in holdings) {
      final asset = MiraAssetsCatalog.findById(h.assetId);
      if (asset == null) continue;
      total += h.marketValueCents(asset.currentPriceCents);
    }
    return total;
  }

  /// Custo total (cost basis) do portfolio em centavos.
  int get costBasisCents {
    var total = 0;
    for (final h in holdings) {
      total += h.costBasisCents;
    }
    return total;
  }

  /// PnL nao realizado total em centavos.
  int get unrealizedPnlCents => marketValueCents - costBasisCents;

  /// PnL em pontos-base (1 bp = 0,01%) — semantica igual a
  /// `dailyChangeBps` do Asset.
  int get unrealizedPnlBps {
    if (costBasisCents == 0) return 0;
    return ((unrealizedPnlCents * 10000) / costBasisCents).round();
  }

  /// Ativos da watchlist resolvidos via catalogo.
  List<Asset> get watchlist {
    return [
      for (final id in favoriteIds)
        if (MiraAssetsCatalog.findById(id) != null) MiraAssetsCatalog.byId(id),
    ];
  }

  /// Ativos do catalogo que casam com `searchQuery` — match por simbolo,
  /// nome ou rotulo do setor, case-insensitive. Quando nao ha termo,
  /// retorna o catalogo inteiro (a home so usa isto com busca ativa).
  List<Asset> get searchResults {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return MiraAssetsCatalog.all;
    return [
      for (final a in MiraAssetsCatalog.all)
        if (a.symbol.toLowerCase().contains(q) ||
            a.name.toLowerCase().contains(q) ||
            a.sector.label.toLowerCase().contains(q))
          a,
    ];
  }

  /// Lookup do holding por assetId — null quando nao ha posicao.
  PortfolioHolding? holdingOf(String assetId) {
    for (final h in holdings) {
      if (h.assetId == assetId) return h;
    }
    return null;
  }

  FinanceState copyWith({
    List<PortfolioHolding>? holdings,
    List<Trade>? trades,
    Set<String>? favoriteIds,
    String? searchQuery,
  }) {
    return FinanceState(
      holdings: holdings ?? this.holdings,
      trades: trades ?? this.trades,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [holdings, trades, favoriteIds, searchQuery];
}
