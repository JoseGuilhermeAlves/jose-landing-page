import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/finance/domain/asset_sector.dart';
import 'package:flutter/foundation.dart';

/// Ativo da bolsa no mock Mira — uma acao da B3 (PETR4, VALE3, etc).
/// Precos em centavos pra evitar imprecisao de double; conversao pra
/// reais so na camada de apresentacao.
@immutable
class Asset extends Equatable {
  const Asset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.sector,
    required this.currentPriceCents,
    required this.dailyChangeBps,
  });

  /// Identificador interno (geralmente igual ao symbol).
  final String id;

  /// Ticker da B3 — "PETR4", "VALE3", "ITUB4".
  final String symbol;

  /// Razao social abreviada ("Petrobras PN", "Vale ON").
  final String name;

  final AssetSector sector;

  /// Preco atual em centavos. R$ 38,42 = 3842.
  final int currentPriceCents;

  /// Variacao do dia em pontos-base (basis points). 1 bp = 0,01%.
  /// 250 = +2,50% ; -180 = -1,80%.
  final int dailyChangeBps;

  /// True quando o ativo subiu no dia.
  bool get isUp => dailyChangeBps >= 0;

  /// Preco em reais (double) — usar apenas pra exibicao.
  double get currentPriceBrl => currentPriceCents / 100;

  /// Mudanca diaria em porcentagem (double). Para `dailyChangeBps`
  /// 250, retorna 2.5.
  double get dailyChangePct => dailyChangeBps / 100;

  @override
  List<Object?> get props => [
    id,
    symbol,
    name,
    sector,
    currentPriceCents,
    dailyChangeBps,
  ];
}
