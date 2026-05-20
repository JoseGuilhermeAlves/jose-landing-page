import 'package:feature_showcase/src/finance/domain/order_side.dart';
import 'package:feature_showcase/src/finance/domain/trade.dart';

/// Historico inicial de trades exibido na MiraTradeHistoryPage. Datas
/// fixas no passado proximo pro snapshot ser determinista. Sao os
/// trades que originaram as posicoes do `MiraPortfolioCatalog` mais
/// alguns trades antigos pra dar densidade ao historico.
abstract final class MiraTradesCatalog {
  static final List<Trade> initial = [
    Trade(
      id: 'T-0001',
      assetId: 'PETR4',
      side: OrderSide.buy,
      quantity: 200,
      priceCents: 3614,
      timestamp: DateTime(2026, 4, 18, 10, 32),
    ),
    Trade(
      id: 'T-0002',
      assetId: 'VALE3',
      side: OrderSide.buy,
      quantity: 80,
      priceCents: 7102,
      timestamp: DateTime(2026, 4, 22, 14, 15),
    ),
    Trade(
      id: 'T-0003',
      assetId: 'ITUB4',
      side: OrderSide.buy,
      quantity: 150,
      priceCents: 3387,
      timestamp: DateTime(2026, 4, 29, 9, 48),
    ),
    Trade(
      id: 'T-0004',
      assetId: 'WEGE3',
      side: OrderSide.buy,
      quantity: 60,
      priceCents: 4892,
      timestamp: DateTime(2026, 5, 5, 11, 7),
    ),
    Trade(
      id: 'T-0005',
      assetId: 'BBAS3',
      side: OrderSide.buy,
      quantity: 100,
      priceCents: 2715,
      timestamp: DateTime(2026, 5, 12, 16, 41),
    ),
    Trade(
      id: 'T-0006',
      assetId: 'MGLU3',
      side: OrderSide.sell,
      quantity: 200,
      priceCents: 1042,
      timestamp: DateTime(2026, 5, 14, 13, 22),
    ),
  ];
}
