import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Posicao consolidada do investidor num ativo. `quantity` em
/// quantidade de papeis; `avgPriceCents` em centavos por papel
/// (custo medio ponderado pelas compras passadas).
@immutable
class PortfolioHolding extends Equatable {
  const PortfolioHolding({
    required this.assetId,
    required this.quantity,
    required this.avgPriceCents,
  });

  final String assetId;
  final int quantity;
  final int avgPriceCents;

  /// Custo total da posicao em centavos.
  int get costBasisCents => quantity * avgPriceCents;

  /// Valor de mercado em centavos dado o `currentPriceCents` atual
  /// do ativo. Calculado fora da entidade pra desacoplar do catalogo
  /// de precos.
  int marketValueCents(int currentPriceCents) => quantity * currentPriceCents;

  /// Resultado financeiro (PnL) em centavos.
  int unrealizedPnlCents(int currentPriceCents) =>
      marketValueCents(currentPriceCents) - costBasisCents;

  PortfolioHolding copyWith({int? quantity, int? avgPriceCents}) {
    return PortfolioHolding(
      assetId: assetId,
      quantity: quantity ?? this.quantity,
      avgPriceCents: avgPriceCents ?? this.avgPriceCents,
    );
  }

  @override
  List<Object?> get props => [assetId, quantity, avgPriceCents];
}
