import 'package:feature_showcase/src/realestate/domain/property.dart';
import 'package:feature_showcase/src/realestate/domain/property_feature.dart';
import 'package:feature_showcase/src/realestate/domain/property_type.dart';

/// Catalogo Solar — imoveis no interior do estado de SP, com cura-
/// doria editorial. Mistura casas, chacaras, terrenos e alguns
/// apartamentos centricos pra dar variedade aos filtros do bloc.
abstract final class PropertiesCatalog {
  static const List<Property> all = [
    Property(
      id: 'p-1001',
      neighborhood: 'Centro Historico',
      type: PropertyType.house,
      bedrooms: 3,
      areaM2: 220,
      parkingSpots: 2,
      priceCents: 89000000,
      suites: 1,
      areaLandM2: 320,
      city: 'Sao Roque · SP',
      headline: 'Casa antiga restaurada de pe-direito alto',
      description:
          'Construcao dos anos 50 restaurada com cuidado — janelas de '
          'madeira originais, piso taco em ipe e jardim interno com '
          'pe de pitanga. A poucas quadras da praca central.',
      features: [
        PropertyFeature.garden,
        PropertyFeature.suite,
        PropertyFeature.garage,
        PropertyFeature.solar,
      ],
      brokerId: 'b-maria',
      photosCount: 14,
    ),
    Property(
      id: 'p-1002',
      neighborhood: 'Beco do Lavrador',
      type: PropertyType.chacara,
      bedrooms: 4,
      areaM2: 280,
      parkingSpots: 4,
      priceCents: 145000000,
      suites: 2,
      areaLandM2: 2400,
      city: 'Itu · SP',
      headline: 'Chacara com piscina e pomar maduro',
      description:
          'Terreno de 2.400 m2 com casa principal de 280 m2, suite '
          'master, piscina aquecida e pomar com mais de 30 frutiferas '
          'plantadas. Pertinho da rodovia.',
      features: [
        PropertyFeature.pool,
        PropertyFeature.suite,
        PropertyFeature.garden,
        PropertyFeature.barbecue,
        PropertyFeature.borehole,
        PropertyFeature.garage,
      ],
      brokerId: 'b-carlos',
      photosCount: 22,
    ),
    Property(
      id: 'p-1003',
      neighborhood: 'Vila Nova',
      type: PropertyType.house,
      bedrooms: 4,
      areaM2: 240,
      parkingSpots: 3,
      priceCents: 132000000,
      suites: 2,
      areaLandM2: 360,
      city: 'Atibaia · SP',
      headline: 'Casa contemporanea com vista pra Pedra Grande',
      description:
          'Arquitetura ampla com sala em dois niveis, varanda com '
          'vista pra Pedra Grande e cozinha integrada. Suite master '
          'com closet e banheira.',
      features: [
        PropertyFeature.suite,
        PropertyFeature.balcony,
        PropertyFeature.garage,
        PropertyFeature.barbecue,
        PropertyFeature.garden,
      ],
      brokerId: 'b-renata',
      photosCount: 18,
    ),
    Property(
      id: 'p-1004',
      neighborhood: 'Mata Velha',
      type: PropertyType.land,
      bedrooms: 0,
      areaM2: 0,
      parkingSpots: 0,
      priceCents: 58000000,
      areaLandM2: 5200,
      city: 'Sao Roque · SP',
      headline: 'Terreno de 5.200 m2 em area rural',
      description:
          'Lote plano com nascente registrada e mata nativa em parte '
          'do fundo. Topografia favoravel pra construir — sem '
          'restricao de uso residencial.',
      features: [PropertyFeature.borehole, PropertyFeature.garden],
      brokerId: 'b-maria',
      photosCount: 8,
    ),
    Property(
      id: 'p-1005',
      neighborhood: 'Vila Nova',
      type: PropertyType.house,
      bedrooms: 3,
      areaM2: 195,
      parkingSpots: 2,
      priceCents: 75000000,
      suites: 1,
      areaLandM2: 250,
      city: 'Atibaia · SP',
      headline: 'Sobrado de tijolinho em condominio fechado',
      description:
          'Sobrado em condominio fechado de 12 casas, com area '
          'comum + piscina coletiva. Tres quartos sendo uma suite, '
          'gourmet integrada.',
      features: [
        PropertyFeature.pool,
        PropertyFeature.suite,
        PropertyFeature.barbecue,
        PropertyFeature.garage,
      ],
      brokerId: 'b-renata',
      photosCount: 16,
    ),
    Property(
      id: 'p-1006',
      neighborhood: 'Recanto da Mata',
      type: PropertyType.chacara,
      bedrooms: 3,
      areaM2: 220,
      parkingSpots: 6,
      priceCents: 198000000,
      suites: 2,
      areaLandM2: 5800,
      city: 'Joanopolis · SP',
      headline: 'Chacara de 5.800 m2 com lago particular',
      description:
          'Casa principal + casa de hospedes, lago com peixes, deck '
          'de madeira e pomar grande. Pra quem vai pro interior de '
          'vez ou monta uma operacao de hospedagem.',
      features: [
        PropertyFeature.pool,
        PropertyFeature.suite,
        PropertyFeature.garden,
        PropertyFeature.barbecue,
        PropertyFeature.borehole,
        PropertyFeature.solar,
        PropertyFeature.garage,
      ],
      brokerId: 'b-carlos',
      photosCount: 28,
    ),
    Property(
      id: 'p-1007',
      neighborhood: 'Centro Historico',
      type: PropertyType.apartment,
      bedrooms: 2,
      areaM2: 78,
      parkingSpots: 1,
      priceCents: 42000000,
      suites: 1,
      city: 'Sao Roque · SP',
      headline: 'Apartamento reformado no predio da Praca',
      description:
          'Reforma feita em 2024 com cozinha americana, piso vinilico '
          'e janelas anti-ruido. Predio dos anos 70 com sindico '
          'morador e vizinhanca tranquila.',
      features: [
        PropertyFeature.suite,
        PropertyFeature.garage,
        PropertyFeature.balcony,
      ],
      brokerId: 'b-maria',
      photosCount: 12,
    ),
    Property(
      id: 'p-1008',
      neighborhood: 'Vila Nova',
      type: PropertyType.house,
      bedrooms: 5,
      areaM2: 340,
      parkingSpots: 4,
      priceCents: 215000000,
      suites: 3,
      areaLandM2: 600,
      city: 'Atibaia · SP',
      headline: 'Casa familiar grande com home office',
      description:
          'Cinco quartos sendo tres suites, salao integrado, home '
          'office com entrada independente e varanda gourmet. Pra '
          'familia grande ou modelo home-and-work.',
      features: [
        PropertyFeature.suite,
        PropertyFeature.balcony,
        PropertyFeature.barbecue,
        PropertyFeature.garage,
        PropertyFeature.garden,
        PropertyFeature.solar,
      ],
      brokerId: 'b-renata',
      photosCount: 24,
    ),
    Property(
      id: 'p-1009',
      neighborhood: 'Vista Alegre',
      type: PropertyType.land,
      bedrooms: 0,
      areaM2: 0,
      parkingSpots: 0,
      priceCents: 32000000,
      areaLandM2: 1200,
      city: 'Joanopolis · SP',
      headline: 'Terreno em condominio com vista pra serra',
      description:
          'Lote de 1.200 m2 em condominio fechado com infra completa '
          '(rua asfaltada, agua, luz). Topografia leve, vista pra '
          'serra da Mantiqueira.',
      features: [PropertyFeature.garden],
      brokerId: 'b-carlos',
      photosCount: 6,
    ),
    Property(
      id: 'p-1010',
      neighborhood: 'Centro',
      type: PropertyType.apartment,
      bedrooms: 1,
      areaM2: 42,
      parkingSpots: 0,
      priceCents: 28500000,
      city: 'Sao Roque · SP',
      headline: 'Studio aconchegante no centro',
      description:
          'Studio integrado de 42 m2 num predio antigo com elevador, '
          'janela panoramica pra rua arborizada. Sem garagem, mas '
          'com bicicletario coletivo no terreo.',
      features: [PropertyFeature.balcony],
      brokerId: 'b-maria',
      photosCount: 9,
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

  /// Imoveis em destaque na home — selecao manual dos mais
  /// "fotogenicos" pra abrir o demo.
  static List<Property> get featured => [all[0], all[1], all[5], all[7]];

  /// Lookup por id — null quando nao existe.
  static Property? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
