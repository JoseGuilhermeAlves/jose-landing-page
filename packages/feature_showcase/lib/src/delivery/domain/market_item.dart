import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/delivery/domain/market_category.dart';
import 'package:flutter/foundation.dart';

/// Unidade de medida do produto vendido pela Aurora — hortifruti
/// diferencia entre venda por peso (kg), unidade (un) e pacote (pct).
enum MarketUnit {
  kg('kg'),
  unit('un'),
  pack('pct'),
  bunch('mac');

  const MarketUnit(this.shortLabel);
  final String shortLabel;
}

/// Item do catalogo Aurora. Sem imagem real — ilustracao via Custom
/// Painter usando [MarketCategory] como discriminador.
@immutable
class MarketItem extends Equatable {
  const MarketItem({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.priceCents,
    required this.unit,
    required this.category,
    this.subtitle = '',
  });

  final String id;
  final String name;

  /// FK pro vendor que vende esse item.
  final String vendorId;

  /// Preco em centavos por unidade (definida em [unit]).
  final double priceCents;

  final MarketUnit unit;
  final MarketCategory category;

  /// Linha curta de catalogo (ex.: "Organico", "Da quinta de Atibaia").
  final String subtitle;

  /// Formatado como "R$ 12,90/kg" quando ha unidade especificada.
  String get formattedPrice {
    final reais = priceCents / 100;
    final integer = reais.truncate();
    final cents = ((reais - integer) * 100)
        .round()
        .toString()
        .padLeft(2, '0');
    return 'R\$ $integer,$cents/${unit.shortLabel}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        vendorId,
        priceCents,
        unit,
        category,
        subtitle,
      ];
}
