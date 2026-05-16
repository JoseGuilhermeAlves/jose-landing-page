import 'package:feature_showcase/src/domain/property.dart';
import 'package:feature_showcase/src/presentation/realestate/realestate_event.dart';
import 'package:feature_showcase/src/presentation/realestate/realestate_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc do mock de imobiliaria. Filtros sao toggles — re-emitir o
/// mesmo valor limpa o filtro. Favoritos e contato sao eventos
/// aditivos do mock Solar.
class RealEstateBloc extends Bloc<RealEstateEvent, RealEstateState> {
  RealEstateBloc({required List<Property> initialProperties})
      : super(RealEstateState(allProperties: initialProperties)) {
    on<RealEstateNeighborhoodSelected>(_onNeighborhood);
    on<RealEstateBedroomsSelected>(_onBedrooms);
    on<RealEstateMaxPriceChanged>(_onMaxPrice);
    on<RealEstateFiltersCleared>(_onCleared);
    on<RealEstateFavoriteToggled>(_onFavoriteToggled);
    on<RealEstateContactSent>(_onContactSent);
  }

  void _onNeighborhood(
    RealEstateNeighborhoodSelected event,
    Emitter<RealEstateState> emit,
  ) {
    final next = event.neighborhood;
    if (next == null) {
      emit(state.copyWith(clearNeighborhood: true));
      return;
    }
    if (next == state.selectedNeighborhood) {
      emit(state.copyWith(clearNeighborhood: true));
      return;
    }
    emit(state.copyWith(selectedNeighborhood: next));
  }

  void _onBedrooms(
    RealEstateBedroomsSelected event,
    Emitter<RealEstateState> emit,
  ) {
    final next = event.bedrooms;
    if (next == null) {
      emit(state.copyWith(clearBedrooms: true));
      return;
    }
    if (next == state.selectedBedrooms) {
      emit(state.copyWith(clearBedrooms: true));
      return;
    }
    emit(state.copyWith(selectedBedrooms: next));
  }

  void _onMaxPrice(
    RealEstateMaxPriceChanged event,
    Emitter<RealEstateState> emit,
  ) {
    if (event.maxPriceCents == null) {
      emit(state.copyWith(clearMaxPrice: true));
      return;
    }
    emit(state.copyWith(maxPriceCents: event.maxPriceCents));
  }

  void _onCleared(
    RealEstateFiltersCleared event,
    Emitter<RealEstateState> emit,
  ) {
    emit(
      state.copyWith(
        clearNeighborhood: true,
        clearBedrooms: true,
        clearMaxPrice: true,
      ),
    );
  }

  void _onFavoriteToggled(
    RealEstateFavoriteToggled event,
    Emitter<RealEstateState> emit,
  ) {
    final id = event.propertyId;
    if (state.favoriteIds.contains(id)) {
      emit(
        state.copyWith(
          favoriteIds: {
            for (final f in state.favoriteIds)
              if (f != id) f,
          },
        ),
      );
    } else {
      emit(state.copyWith(favoriteIds: {...state.favoriteIds, id}));
    }
  }

  void _onContactSent(
    RealEstateContactSent event,
    Emitter<RealEstateState> emit,
  ) {
    if (state.sentContactIds.contains(event.propertyId)) return;
    emit(
      state.copyWith(
        sentContactIds: {...state.sentContactIds, event.propertyId},
      ),
    );
  }
}
