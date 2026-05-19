import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/delivery/domain/market_category.dart';
import 'package:flutter/foundation.dart';

/// "Banca" do marketplace Aurora — uma loja/produtor especifico. Cada
/// banca atende 1 ou 2 categorias e tem seu proprio ETA medio e
/// frete. Sem nome de empresa real — narrativa de bairro.
@immutable
class Vendor extends Equatable {
  const Vendor({
    required this.id,
    required this.name,
    required this.tagline,
    required this.categories,
    required this.etaMinutes,
    required this.deliveryFeeCents,
    required this.rating,
  });

  final String id;

  /// Nome da banca/loja ("Banca do Seu Mario", "Padaria do Centro").
  final String name;

  /// Linha curta abaixo do nome ("hortifruti organico" etc.).
  final String tagline;

  /// Categorias que essa banca atende. A primeira e a principal.
  final List<MarketCategory> categories;

  /// ETA medio em minutos pra entrega.
  final int etaMinutes;

  /// Frete fixo em centavos.
  final double deliveryFeeCents;

  /// Nota de 0 a 5 (mock, sem reviews reais).
  final double rating;

  /// Categoria principal (primeira da lista).
  MarketCategory get primaryCategory => categories.first;

  /// Frete formatado ("R$ 6,90" ou "Gratis" quando 0).
  String get formattedDeliveryFee {
    if (deliveryFeeCents == 0) return 'Gratis';
    final reais = deliveryFeeCents / 100;
    final integer = reais.truncate();
    final cents = ((reais - integer) * 100)
        .round()
        .toString()
        .padLeft(2, '0');
    return 'R\$ $integer,$cents';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        tagline,
        categories,
        etaMinutes,
        deliveryFeeCents,
        rating,
      ];
}
