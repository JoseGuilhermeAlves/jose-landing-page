import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/realestate/domain/property.dart';
import 'package:flutter/foundation.dart';

@immutable
class RealEstateState extends Equatable {
  const RealEstateState({
    required this.allProperties,
    this.selectedNeighborhood,
    this.selectedBedrooms,
    this.maxPriceCents,
    this.favoriteIds = const {},
    this.sentContactIds = const {},
  });

  /// Catalogo completo — filtros nao mutam, derivam.
  final List<Property> allProperties;

  /// Filtro de bairro. Null = todos.
  final String? selectedNeighborhood;

  /// Filtro de quartos. Null = qualquer. Convencao: 4 abrange 4+.
  final int? selectedBedrooms;

  /// Filtro de preco maximo em centavos. Null = sem teto.
  final int? maxPriceCents;

  /// Ids dos imoveis favoritados nesta sessao. Mock — sem
  /// persistencia.
  final Set<String> favoriteIds;

  /// Ids dos imoveis com pedido de contato ja enviado nesta sessao.
  /// A tela de contato consulta pra mostrar success state em vez do
  /// formulario novamente.
  final Set<String> sentContactIds;

  /// Lista filtrada — derivada dos filtros atuais.
  List<Property> get filtered {
    return [
      for (final p in allProperties)
        if (_matches(p)) p,
    ];
  }

  bool get hasActiveFilters =>
      selectedNeighborhood != null ||
      selectedBedrooms != null ||
      maxPriceCents != null;

  bool isFavorite(String id) => favoriteIds.contains(id);

  bool hasSentContact(String id) => sentContactIds.contains(id);

  bool _matches(Property p) {
    if (selectedNeighborhood != null &&
        p.neighborhood != selectedNeighborhood) {
      return false;
    }
    if (selectedBedrooms != null) {
      // Bucket "4+" no filtro: bedrooms >= 4 quando filtro e 4.
      if (selectedBedrooms == 4) {
        if (p.bedrooms < 4) return false;
      } else if (p.bedrooms != selectedBedrooms) {
        return false;
      }
    }
    if (maxPriceCents != null && p.priceCents > maxPriceCents!) return false;
    return true;
  }

  RealEstateState copyWith({
    String? selectedNeighborhood,
    bool clearNeighborhood = false,
    int? selectedBedrooms,
    bool clearBedrooms = false,
    int? maxPriceCents,
    bool clearMaxPrice = false,
    Set<String>? favoriteIds,
    Set<String>? sentContactIds,
  }) {
    return RealEstateState(
      allProperties: allProperties,
      selectedNeighborhood: clearNeighborhood
          ? null
          : (selectedNeighborhood ?? this.selectedNeighborhood),
      selectedBedrooms: clearBedrooms
          ? null
          : (selectedBedrooms ?? this.selectedBedrooms),
      maxPriceCents: clearMaxPrice
          ? null
          : (maxPriceCents ?? this.maxPriceCents),
      favoriteIds: favoriteIds ?? this.favoriteIds,
      sentContactIds: sentContactIds ?? this.sentContactIds,
    );
  }

  @override
  List<Object?> get props => [
    allProperties,
    selectedNeighborhood,
    selectedBedrooms,
    maxPriceCents,
    favoriteIds,
    sentContactIds,
  ];
}
