import 'package:feature_showcase/src/domain/property.dart';
import 'package:feature_showcase/src/domain/property_type.dart';

/// Mock estatico de imoveis pra demo de imobiliaria. Bairros
/// genericos pra nao puxar nominal de cidade real. Distribuicao
/// equilibrada pra que cada filtro produza algum resultado.
abstract final class PropertiesCatalog {
  static const List<Property> all = [
    Property(
      id: 'p-1001',
      neighborhood: 'Centro',
      type: PropertyType.apartment,
      bedrooms: 1,
      areaM2: 38,
      parkingSpots: 0,
      priceCents: 24500000,
    ),
    Property(
      id: 'p-1002',
      neighborhood: 'Centro',
      type: PropertyType.apartment,
      bedrooms: 2,
      areaM2: 62,
      parkingSpots: 1,
      priceCents: 39800000,
    ),
    Property(
      id: 'p-1003',
      neighborhood: 'Jardins',
      type: PropertyType.apartment,
      bedrooms: 3,
      areaM2: 92,
      parkingSpots: 2,
      priceCents: 78000000,
    ),
    Property(
      id: 'p-1004',
      neighborhood: 'Jardins',
      type: PropertyType.apartment,
      bedrooms: 4,
      areaM2: 140,
      parkingSpots: 2,
      priceCents: 132000000,
    ),
    Property(
      id: 'p-1005',
      neighborhood: 'Vila Nova',
      type: PropertyType.house,
      bedrooms: 3,
      areaM2: 180,
      parkingSpots: 2,
      priceCents: 89000000,
    ),
    Property(
      id: 'p-1006',
      neighborhood: 'Vila Nova',
      type: PropertyType.house,
      bedrooms: 4,
      areaM2: 240,
      parkingSpots: 3,
      priceCents: 145000000,
    ),
    Property(
      id: 'p-1007',
      neighborhood: 'Pinheiros',
      type: PropertyType.apartment,
      bedrooms: 2,
      areaM2: 70,
      parkingSpots: 1,
      priceCents: 52000000,
    ),
    Property(
      id: 'p-1008',
      neighborhood: 'Pinheiros',
      type: PropertyType.apartment,
      bedrooms: 3,
      areaM2: 110,
      parkingSpots: 2,
      priceCents: 95500000,
    ),
    Property(
      id: 'p-1009',
      neighborhood: 'Mooca',
      type: PropertyType.apartment,
      bedrooms: 1,
      areaM2: 45,
      parkingSpots: 1,
      priceCents: 31500000,
    ),
    Property(
      id: 'p-1010',
      neighborhood: 'Mooca',
      type: PropertyType.house,
      bedrooms: 2,
      areaM2: 95,
      parkingSpots: 1,
      priceCents: 48000000,
    ),
    Property(
      id: 'p-1011',
      neighborhood: 'Tatuape',
      type: PropertyType.apartment,
      bedrooms: 2,
      areaM2: 68,
      parkingSpots: 1,
      priceCents: 42000000,
    ),
    Property(
      id: 'p-1012',
      neighborhood: 'Tatuape',
      type: PropertyType.apartment,
      bedrooms: 4,
      areaM2: 150,
      parkingSpots: 2,
      priceCents: 118000000,
    ),
  ];

  /// Lista de bairros distintos (sem repeticao), preservando ordem
  /// de aparicao no catalogo — usado pra montar o filtro.
  static List<String> get neighborhoods {
    final seen = <String>{};
    final result = <String>[];
    for (final p in all) {
      if (seen.add(p.neighborhood)) result.add(p.neighborhood);
    }
    return result;
  }
}
