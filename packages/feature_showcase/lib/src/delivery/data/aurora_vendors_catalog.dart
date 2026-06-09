import 'package:feature_showcase/src/delivery/domain/market_category.dart';
import 'package:feature_showcase/src/delivery/domain/vendor.dart';

/// Catalogo estatico de bancas/lojas do marketplace Aurora. Cada banca
/// atende 1 ou 2 categorias e tem ETA + frete proprios.
abstract final class AuroraVendorsCatalog {
  static const List<Vendor> all = [
    Vendor(
      id: 'v-mario',
      name: 'Banca do Seu Mario',
      tagline: 'Hortifruti organico · Atibaia',
      categories: [MarketCategory.fruits, MarketCategory.greens],
      etaMinutes: 35,
      deliveryFeeCents: 690,
      rating: 4.8,
      photoAsset: 'assets/delivery/banca_hortifruti.webp',
    ),
    Vendor(
      id: 'v-padaria-centro',
      name: 'Padaria do Centro',
      tagline: 'Fermentacao natural · paes do dia',
      categories: [MarketCategory.bakery],
      etaMinutes: 25,
      deliveryFeeCents: 590,
      rating: 4.9,
      photoAsset: 'assets/delivery/padaria.webp',
    ),
    Vendor(
      id: 'v-queijaria',
      name: 'Queijaria da Serra',
      tagline: 'Queijo minas, manteiga, iogurte',
      categories: [MarketCategory.dairy],
      etaMinutes: 50,
      deliveryFeeCents: 990,
      rating: 4.7,
      photoAsset: 'assets/delivery/queijaria.webp',
    ),
    Vendor(
      id: 'v-empório-aurora',
      name: 'Emporio Aurora',
      tagline: 'Graos a granel · azeite · conserva',
      categories: [MarketCategory.pantry],
      etaMinutes: 40,
      deliveryFeeCents: 0,
      rating: 4.6,
      photoAsset: 'assets/delivery/emporio.webp',
    ),
    Vendor(
      id: 'v-feira-itinerante',
      name: 'Feira Itinerante',
      tagline: 'Caixote da semana · sazonal',
      categories: [MarketCategory.fruits, MarketCategory.greens],
      etaMinutes: 60,
      deliveryFeeCents: 0,
      rating: 4.5,
      photoAsset: 'assets/delivery/feira.webp',
    ),
    Vendor(
      id: 'v-padoca-bairro',
      name: 'Padoca do Bairro',
      tagline: 'Pao frances quentinho · doces',
      categories: [MarketCategory.bakery, MarketCategory.dairy],
      etaMinutes: 20,
      deliveryFeeCents: 490,
      rating: 4.8,
      photoAsset: 'assets/delivery/padoca.webp',
    ),
  ];

  /// Lookup por id — null se nao existir.
  static Vendor? byId(String id) {
    for (final v in all) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// Filtra por categoria.
  static List<Vendor> byCategory(MarketCategory cat) =>
      all.where((v) => v.categories.contains(cat)).toList(growable: false);
}
