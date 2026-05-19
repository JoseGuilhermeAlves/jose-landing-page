import 'package:feature_showcase/src/delivery/domain/market_category.dart';
import 'package:feature_showcase/src/delivery/domain/market_item.dart';

/// Catalogo estatico de itens do marketplace Aurora. Cada item esta
/// vinculado a uma banca (`vendorId`) e a uma categoria.
abstract final class AuroraItemsCatalog {
  static const List<MarketItem> all = [
    // Banca do Seu Mario — frutas e verduras
    MarketItem(
      id: 'i-banana',
      name: 'Banana prata',
      vendorId: 'v-mario',
      priceCents: 890,
      unit: MarketUnit.kg,
      category: MarketCategory.fruits,
      subtitle: 'Madura, doce',
    ),
    MarketItem(
      id: 'i-maca',
      name: 'Maca fuji',
      vendorId: 'v-mario',
      priceCents: 1290,
      unit: MarketUnit.kg,
      category: MarketCategory.fruits,
      subtitle: 'Crocante',
    ),
    MarketItem(
      id: 'i-laranja',
      name: 'Laranja pera',
      vendorId: 'v-mario',
      priceCents: 690,
      unit: MarketUnit.kg,
      category: MarketCategory.fruits,
      subtitle: 'Suco fresco',
    ),
    MarketItem(
      id: 'i-alface',
      name: 'Alface crespa',
      vendorId: 'v-mario',
      priceCents: 490,
      unit: MarketUnit.unit,
      category: MarketCategory.greens,
      subtitle: 'Folhas firmes',
    ),
    MarketItem(
      id: 'i-tomate',
      name: 'Tomate italiano',
      vendorId: 'v-mario',
      priceCents: 1190,
      unit: MarketUnit.kg,
      category: MarketCategory.greens,
      subtitle: 'Pra molho',
    ),
    MarketItem(
      id: 'i-cenoura',
      name: 'Cenoura',
      vendorId: 'v-mario',
      priceCents: 690,
      unit: MarketUnit.kg,
      category: MarketCategory.greens,
      subtitle: 'Boa pra refogar',
    ),

    // Padaria do Centro
    MarketItem(
      id: 'i-pao-frances',
      name: 'Pao frances',
      vendorId: 'v-padaria-centro',
      priceCents: 1890,
      unit: MarketUnit.kg,
      category: MarketCategory.bakery,
      subtitle: 'Saido do forno',
    ),
    MarketItem(
      id: 'i-baguete',
      name: 'Baguete rustica',
      vendorId: 'v-padaria-centro',
      priceCents: 1490,
      unit: MarketUnit.unit,
      category: MarketCategory.bakery,
      subtitle: 'Fermentacao natural',
    ),

    // Queijaria da Serra
    MarketItem(
      id: 'i-queijo-minas',
      name: 'Queijo minas frescal',
      vendorId: 'v-queijaria',
      priceCents: 4890,
      unit: MarketUnit.kg,
      category: MarketCategory.dairy,
      subtitle: 'Da serra de Minas',
    ),
    MarketItem(
      id: 'i-manteiga',
      name: 'Manteiga artesanal',
      vendorId: 'v-queijaria',
      priceCents: 2790,
      unit: MarketUnit.pack,
      category: MarketCategory.dairy,
      subtitle: 'Pote de 250g',
    ),

    // Emporio Aurora
    MarketItem(
      id: 'i-feijao',
      name: 'Feijao carioca',
      vendorId: 'v-empório-aurora',
      priceCents: 1890,
      unit: MarketUnit.kg,
      category: MarketCategory.pantry,
      subtitle: 'A granel',
    ),
    MarketItem(
      id: 'i-azeite',
      name: 'Azeite extra virgem',
      vendorId: 'v-empório-aurora',
      priceCents: 4990,
      unit: MarketUnit.pack,
      category: MarketCategory.pantry,
      subtitle: 'Garrafa 500ml',
    ),

    // Feira Itinerante — caixote da semana
    MarketItem(
      id: 'i-caixote',
      name: 'Caixote da semana',
      vendorId: 'v-feira-itinerante',
      priceCents: 7990,
      unit: MarketUnit.pack,
      category: MarketCategory.fruits,
      subtitle: 'Sortimento sazonal',
    ),

    // Padoca do Bairro
    MarketItem(
      id: 'i-pao-doce',
      name: 'Pao doce',
      vendorId: 'v-padoca-bairro',
      priceCents: 590,
      unit: MarketUnit.unit,
      category: MarketCategory.bakery,
      subtitle: 'Recheado',
    ),
  ];

  /// Filtra por vendor.
  static List<MarketItem> byVendor(String vendorId) =>
      all.where((i) => i.vendorId == vendorId).toList(growable: false);

  /// Filtra por categoria.
  static List<MarketItem> byCategory(MarketCategory cat) =>
      all.where((i) => i.category == cat).toList(growable: false);
}
