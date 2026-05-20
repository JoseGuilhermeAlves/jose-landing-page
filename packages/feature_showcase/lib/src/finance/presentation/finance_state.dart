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
  });

  /// Posicoes consolidadas do investidor. Chave implicita: `assetId`
  /// — nao ha duplicatas (a regra de fusao de compra/venda mantem
  /// um holding por ativo).
  final List<PortfolioHolding> holdings;

  /// Historico de trades em ordem cronologica (mais recente primeiro).
  final List<Trade> trades;

  /// Watchlist — ids dos ativos marcados como favoritos.
  final Set<String> favoriteIds;

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
  }) {
    return FinanceState(
      holdings: holdings ?? this.holdings,
      trades: trades ?? this.trades,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }

  @override
  List<Object?> get props => [holdings, trades, favoriteIds];
}
