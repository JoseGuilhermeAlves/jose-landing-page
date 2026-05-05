import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/domain/property_type.dart';
import 'package:flutter/foundation.dart';

/// Imovel listado na demo. Preco em centavos pra evitar imprecisao
/// de double — formatador converte na hora de mostrar.
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
  });

  final String id;
  final String neighborhood;
  final PropertyType type;
  final int bedrooms;
  final int areaM2;
  final int parkingSpots;
  final int priceCents;

  @override
  List<Object?> get props =>
      [id, neighborhood, type, bedrooms, areaM2, parkingSpots, priceCents];

  @override
  String toString() =>
      'Property($id, $neighborhood, $bedrooms quartos, ${type.label})';
}
