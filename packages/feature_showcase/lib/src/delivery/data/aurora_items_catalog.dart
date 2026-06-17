import 'package:feature_showcase/src/delivery/domain/market_category.dart';
import 'package:feature_showcase/src/delivery/domain/market_item.dart';

/// Catalogo estatico de itens do marketplace Aurora. Cada item esta
/// vinculado a uma banca (`vendorId`) e a uma categoria.
abstract final class AuroraItemsCatalog {
  static const List<MarketItem> all = [
    MarketItem(
      id: 'i-banana',
      name: 'Banana prata',
      vendorId: 'v-mario',
      priceCents: 890,
      unit: MarketUnit.kg,
      category: MarketCategory.fruits,
      subtitle: 'Madura, doce',
      description:
          'Banana prata colhida no ponto na quinta de Atibaia. Casca '
          'firme, polpa doce — boa pra comer in natura ou amassar na '
          'vitamina da manhã.',
      photoAsset: 'assets/delivery/banana.webp',
    ),
    MarketItem(
      id: 'i-maca',
      name: 'Maca fuji',
      vendorId: 'v-mario',
      priceCents: 1290,
      unit: MarketUnit.kg,
      category: MarketCategory.fruits,
      subtitle: 'Crocante',
      description:
          'Maçã fuji crocante e suculenta, com aquele equilíbrio entre '
          'doce e levemente ácido. Selecionada uma a uma na banca.',
      photoAsset: 'assets/delivery/maca.webp',
    ),
    MarketItem(
      id: 'i-laranja',
      name: 'Laranja pera',
      vendorId: 'v-mario',
      priceCents: 690,
      unit: MarketUnit.kg,
      category: MarketCategory.fruits,
      subtitle: 'Suco fresco',
      description:
          'Laranja pera de mesa, casca fina e bem suculenta. Rende um '
          'suco fresco generoso — e o açúcar vem da própria fruta.',
      photoAsset: 'assets/delivery/laranja.webp',
    ),
    MarketItem(
      id: 'i-alface',
      name: 'Alface crespa',
      vendorId: 'v-mario',
      priceCents: 490,
      unit: MarketUnit.unit,
      category: MarketCategory.greens,
      subtitle: 'Folhas firmes',
      description:
          'Pé de alface crespa colhido pela manhã, folhas firmes e sem '
          'murchar. Lavada e pronta pra montar a salada do almoço.',
      photoAsset: 'assets/delivery/alface.webp',
    ),
    MarketItem(
      id: 'i-tomate',
      name: 'Tomate italiano',
      vendorId: 'v-mario',
      priceCents: 1190,
      unit: MarketUnit.kg,
      category: MarketCategory.greens,
      subtitle: 'Pra molho',
      description:
          'Tomate italiano maduro, polpa carnuda e poucas sementes — o '
          'preferido pra molho lento de domingo.',
      photoAsset: 'assets/delivery/tomate.webp',
    ),
    MarketItem(
      id: 'i-cenoura',
      name: 'Cenoura',
      vendorId: 'v-mario',
      priceCents: 690,
      unit: MarketUnit.kg,
      category: MarketCategory.greens,
      subtitle: 'Boa pra refogar',
      description:
          'Cenoura fresca de raiz lisa, doce no ponto certo. Ótima '
          'refogada, no bolo ou ralada na salada.',
      photoAsset: 'assets/delivery/cenoura.webp',
    ),

    MarketItem(
      id: 'i-pao-frances',
      name: 'Pao frances',
      vendorId: 'v-padaria-centro',
      priceCents: 1890,
      unit: MarketUnit.kg,
      category: MarketCategory.bakery,
      subtitle: 'Saido do forno',
      description:
          'Pão francês de casca dourada e miolo macio, assado em fornadas '
          'ao longo do dia. Vai quentinho na sacola.',
      photoAsset: 'assets/delivery/pao_frances.webp',
    ),
    MarketItem(
      id: 'i-baguete',
      name: 'Baguete rustica',
      vendorId: 'v-padaria-centro',
      priceCents: 1490,
      unit: MarketUnit.unit,
      category: MarketCategory.bakery,
      subtitle: 'Fermentacao natural',
      description:
          'Baguete de fermentação natural, crosta crocante e alvéolos '
          'abertos. Levou mais de 18 horas de descanso da massa.',
      photoAsset: 'assets/delivery/baguete.webp',
    ),

    MarketItem(
      id: 'i-queijo-minas',
      name: 'Queijo minas frescal',
      vendorId: 'v-queijaria',
      priceCents: 4890,
      unit: MarketUnit.kg,
      category: MarketCategory.dairy,
      subtitle: 'Da serra de Minas',
      description:
          'Queijo minas frescal artesanal, leve e levemente salgado. '
          'Produzido em pequenos lotes na serra mineira.',
      photoAsset: 'assets/delivery/queijo_minas.webp',
    ),
    MarketItem(
      id: 'i-manteiga',
      name: 'Manteiga artesanal',
      vendorId: 'v-queijaria',
      priceCents: 2790,
      unit: MarketUnit.pack,
      category: MarketCategory.dairy,
      subtitle: 'Pote de 250g',
      description:
          'Manteiga artesanal batida em pequenas porções, sabor encorpado '
          'e textura cremosa. Pote de 250g.',
      photoAsset: 'assets/delivery/manteiga.webp',
    ),

    MarketItem(
      id: 'i-feijao',
      name: 'Feijao carioca',
      vendorId: 'v-empório-aurora',
      priceCents: 1890,
      unit: MarketUnit.kg,
      category: MarketCategory.pantry,
      subtitle: 'A granel',
      description:
          'Feijão carioca a granel, safra nova e grão graúdo. Cozinha '
          'rápido e fica no caldo cremoso de sempre.',
      photoAsset: 'assets/delivery/feijao.webp',
    ),
    MarketItem(
      id: 'i-azeite',
      name: 'Azeite extra virgem',
      vendorId: 'v-empório-aurora',
      priceCents: 4990,
      unit: MarketUnit.pack,
      category: MarketCategory.pantry,
      subtitle: 'Garrafa 500ml',
      description:
          'Azeite extra virgem de acidez baixa, frutado e marcante. '
          'Garrafa escura de 500ml pra preservar o aroma.',
      photoAsset: 'assets/delivery/azeite.webp',
    ),

    MarketItem(
      id: 'i-caixote',
      name: 'Caixote da semana',
      vendorId: 'v-feira-itinerante',
      priceCents: 7990,
      unit: MarketUnit.pack,
      category: MarketCategory.fruits,
      subtitle: 'Sortimento sazonal',
      description:
          'Caixote sortido com o melhor da semana — frutas e verduras da '
          'estação, escolhidas pela feira. A composição muda conforme a '
          'colheita.',
      photoAsset: 'assets/delivery/caixote.webp',
    ),

    MarketItem(
      id: 'i-pao-doce',
      name: 'Pao doce',
      vendorId: 'v-padoca-bairro',
      priceCents: 590,
      unit: MarketUnit.unit,
      category: MarketCategory.bakery,
      subtitle: 'Recheado',
      description:
          'Pão doce fofinho com recheio cremoso, daqueles que somem antes '
          'do café esfriar. Saído do forno da padoca.',
      photoAsset: 'assets/delivery/pao_doce.webp',
    ),
  ];

  /// Filtra por vendor.
  static List<MarketItem> byVendor(String vendorId) =>
      all.where((i) => i.vendorId == vendorId).toList(growable: false);

  /// Filtra por categoria.
  static List<MarketItem> byCategory(MarketCategory cat) =>
      all.where((i) => i.category == cat).toList(growable: false);
}
