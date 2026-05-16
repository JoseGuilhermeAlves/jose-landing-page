import 'package:equatable/equatable.dart';

sealed class RealEstateEvent extends Equatable {
  const RealEstateEvent();

  @override
  List<Object?> get props => const [];
}

/// Toggle de filtro por bairro. Passa null pra limpar.
class RealEstateNeighborhoodSelected extends RealEstateEvent {
  const RealEstateNeighborhoodSelected(this.neighborhood);
  final String? neighborhood;

  @override
  List<Object?> get props => [neighborhood];
}

/// Toggle de filtro por quartos. Convencao: [bedrooms] = 4 abrange
/// "4+" no bucket — imoveis com 4 ou mais.
class RealEstateBedroomsSelected extends RealEstateEvent {
  const RealEstateBedroomsSelected(this.bedrooms);
  final int? bedrooms;

  @override
  List<Object?> get props => [bedrooms];
}

/// Define preco maximo (em centavos). Null = sem teto.
class RealEstateMaxPriceChanged extends RealEstateEvent {
  const RealEstateMaxPriceChanged(this.maxPriceCents);
  final int? maxPriceCents;

  @override
  List<Object?> get props => [maxPriceCents];
}

/// Limpa todos os filtros.
class RealEstateFiltersCleared extends RealEstateEvent {
  const RealEstateFiltersCleared();
}

/// Toggle de favorito no card/detalhe — adiciona ou remove de
/// `favoriteIds`. Mock sem persistencia.
class RealEstateFavoriteToggled extends RealEstateEvent {
  const RealEstateFavoriteToggled(this.propertyId);
  final String propertyId;

  @override
  List<Object?> get props => [propertyId];
}

/// Marca um imovel como "contato ja enviado" — disparado no submit
/// do formulario da `SolarContactPage`. A tela troca pra estado de
/// sucesso depois desse evento.
class RealEstateContactSent extends RealEstateEvent {
  const RealEstateContactSent(this.propertyId);
  final String propertyId;

  @override
  List<Object?> get props => [propertyId];
}
