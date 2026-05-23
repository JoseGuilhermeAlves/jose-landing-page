import 'package:feature_showcase/src/finance/domain/portfolio_holding.dart';

/// Posicoes iniciais do investidor no mock Mira. Carteira pequena
/// e diversificada (5 ativos) pra que o donut da tela de portfolio
/// fique visualmente equilibrado. `avgPriceCents` ficticios.
abstract final class MiraPortfolioCatalog {
  static const List<PortfolioHolding> initial = [
    PortfolioHolding(assetId: 'PETR4', quantity: 200, avgPriceCents: 3614),
    PortfolioHolding(assetId: 'VALE3', quantity: 80, avgPriceCents: 7102),
    PortfolioHolding(assetId: 'ITUB4', quantity: 150, avgPriceCents: 3387),
    PortfolioHolding(assetId: 'WEGE3', quantity: 60, avgPriceCents: 4892),
    PortfolioHolding(assetId: 'BBAS3', quantity: 100, avgPriceCents: 2715),
  ];
}
