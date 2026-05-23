import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/realestate/domain/property_feature.dart';
import 'package:feature_showcase/src/realestate/domain/property_type.dart';
import 'package:flutter/foundation.dart';

/// Imovel listado na demo. Preco em centavos pra evitar imprecisao
/// de double — formatador converte na hora de mostrar.
///
/// Campos novos do mock Solar (suites, areaLandM2, headline,
/// description, features, brokerId, city, photosCount) sao opcionais
/// com default vazio/zero pra preservar compat com testes legados
/// que construiam Property so com os 7 campos originais.
@immutable
class Property extends Equatable {
  const Property({
    required this.id,
    required this.neighborhood,
    required this.type,
    required this.bedrooms,
    required this.areaM2,
    required this.parkingSpots,
    required this.priceCents,
    this.suites = 0,
    this.areaLandM2 = 0,
    this.headline = '',
    this.description = '',
    this.features = const [],
    this.brokerId = '',
    this.city = '',
    this.photosCount = 0,
  });

  final String id;
  final String neighborhood;
  final PropertyType type;
  final int bedrooms;
  final int areaM2;
  final int parkingSpots;
  final int priceCents;

  /// Quantidade de suites (subset de bedrooms). 0 quando nao se
  /// aplica (terreno, apto simples).
  final int suites;

  /// Area do terreno em m2 — relevante pra casa/chacara/terreno. 0
  /// quando nao se aplica (apto).
  final int areaLandM2;

  /// Manchete editorial pra cards e detalhe (ex.: "Casa com jardim
  /// no centro historico"). Vazio em propriedades legadas.
  final String headline;

  /// Texto editorial pra tela de detalhe (1-2 paragrafos). Vazio em
  /// propriedades legadas.
  final String description;

  /// Lista de [PropertyFeature]s — vira grid de chips no detalhe.
  final List<PropertyFeature> features;

  /// FK pro `Broker` que atende a propriedade. Vazio quando nao
  /// ha corretor associado.
  final String brokerId;

  /// Cidade/UF mock — exibido junto com bairro nos cards.
  final String city;

  /// Numero declarado de fotos "no anuncio". Usado pra exibir
  /// "+12 fotos" no card; nao implica em assets reais.
  final int photosCount;

  /// Preco formatado em BRL ("R\$ 1.250.000,00").
  String get formattedPrice {
    final reais = priceCents / 100;
    final intPart = reais.truncate();
    final centPart = ((reais - intPart) * 100).round().toString().padLeft(
      2,
      '0',
    );
    final intStr = _withThousands(intPart);
    return 'R\$ $intStr,$centPart';
  }

  static String _withThousands(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  List<Object?> get props => [
    id,
    neighborhood,
    type,
    bedrooms,
    areaM2,
    parkingSpots,
    priceCents,
    suites,
    areaLandM2,
    headline,
    description,
    features,
    brokerId,
    city,
    photosCount,
  ];

  @override
  String toString() =>
      'Property($id, $neighborhood, $bedrooms quartos, ${type.label})';
}
