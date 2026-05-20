import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/finance/domain/order_side.dart';
import 'package:flutter/foundation.dart';

/// Trade executado — entrada no historico ("Comprou 100 PETR4 a
/// 38,42 em 14/05"). `priceCents` e o preco efetivamente executado;
/// `quantity` a quantidade de papeis. Sem campo `fee` pra manter o
/// dataset enxuto.
@immutable
class Trade extends Equatable {
  const Trade({
    required this.id,
    required this.assetId,
    required this.side,
    required this.quantity,
    required this.priceCents,
    required this.timestamp,
  });

  final String id;
  final String assetId;
  final OrderSide side;
  final int quantity;
  final int priceCents;
  final DateTime timestamp;

  /// Volume financeiro do trade em centavos.
  int get notionalCents => quantity * priceCents;

  @override
  List<Object?> get props => [
        id,
        assetId,
        side,
        quantity,
        priceCents,
        timestamp,
      ];
}
