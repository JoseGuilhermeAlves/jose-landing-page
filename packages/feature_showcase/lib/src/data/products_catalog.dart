// O catalogo declara categoria/variants explicitos em cada produto
// mesmo quando coincide com o default — leitura mais clara e diff
// mais estavel. Silenciamos a lint que sugere remover esses args.
// ignore_for_file: avoid_redundant_argument_values

import 'package:feature_showcase/src/domain/product.dart';
import 'package:feature_showcase/src/domain/product_category.dart';
import 'package:feature_showcase/src/domain/product_variant.dart';

/// Curadoria do mock Garoa — cafe-livraria com objetos de mesa e
/// papelaria. Substitui o catalogo eclectico original (que misturava
/// tenis, fones e mochila com cafe) por uma linha coerente com a
/// marca. Precos em centavos; variantes alteram o preco final.
abstract final class ProductsCatalog {
  static const List<Product> all = [
    Product(
      id: 'p-001',
      name: 'Cafe Especial Garoa 250g',
      priceCents: 4590,
      emoji: '🫘',
      category: ProductCategory.coffee,
      subtitle: 'Torra media · Cerrado Mineiro',
      origin: 'Cerrado Mineiro · MG',
      description:
          'Lote pequeno de grao SCA 86. Notas de chocolate ao leite, '
          'caramelo e final levemente citrico. Boa pra coado e prensa.',
      variants: [
        ProductVariant(
          id: 'torra-clara',
          label: 'Torra clara',
          sublabel: 'Acidez frutada, ideal pra V60',
        ),
        ProductVariant(
          id: 'torra-media',
          label: 'Torra media',
          sublabel: 'Equilibrio chocolate-caramelo',
        ),
        ProductVariant(
          id: 'torra-escura',
          label: 'Torra escura',
          sublabel: 'Corpo cheio, prensa francesa',
          deltaCents: 200,
        ),
      ],
    ),
    Product(
      id: 'p-002',
      name: 'Cafe Bourbon Amarelo 500g',
      priceCents: 7890,
      emoji: '☕',
      category: ProductCategory.coffee,
      subtitle: 'Torra media-clara · Sul de Minas',
      origin: 'Sul de Minas · Fazenda Sao Joao',
      description:
          'Bourbon amarelo SCA 84, processo natural. Doce, com notas '
          'de mel, frutas amarelas e tangerina. Perfeito pro coado da '
          'manha.',
      variants: [
        ProductVariant(
          id: 'gr',
          label: 'Em grao',
          sublabel: 'Frescor maximo, voce moe na hora',
        ),
        ProductVariant(
          id: 'moido-coado',
          label: 'Moido pra coado',
          sublabel: 'Granulometria media',
        ),
        ProductVariant(
          id: 'moido-prensa',
          label: 'Moido pra prensa',
          sublabel: 'Granulometria grossa',
        ),
      ],
    ),
    Product(
      id: 'p-003',
      name: 'Caderno Garoa A5',
      priceCents: 4990,
      emoji: '📓',
      category: ProductCategory.stationery,
      subtitle: 'Papel 90g · Costura aparente',
      description:
          'Caderno de 192 paginas, papel marfim 90g, costura japonesa '
          'aparente. Capa em cartonagem natural com debossing do logo.',
      variants: [
        ProductVariant(
          id: 'pautado',
          label: 'Pautado',
          sublabel: 'Linhas finas 7mm',
        ),
        ProductVariant(
          id: 'pontilhado',
          label: 'Pontilhado',
          sublabel: 'Pontos 5mm, sketches e bullet',
        ),
        ProductVariant(
          id: 'liso',
          label: 'Liso',
          sublabel: 'Sem marcacao, ilustracao',
        ),
      ],
    ),
    Product(
      id: 'p-004',
      name: 'Diario Garoa Bolso A6',
      priceCents: 3290,
      emoji: '📒',
      category: ProductCategory.stationery,
      subtitle: '96 paginas · Capa rigida',
      description:
          'Diario de bolso pra carregar pra qualquer lugar. Capa rigida '
          'com elastico, marcador em fita e bolso interno discreto.',
      variants: [
        ProductVariant(
          id: 'creme',
          label: 'Creme',
          sublabel: 'Capa neutra, classico',
        ),
        ProductVariant(
          id: 'cafe',
          label: 'Cafe',
          sublabel: 'Marrom escuro, sobrio',
        ),
        ProductVariant(
          id: 'musgo',
          label: 'Musgo',
          sublabel: 'Verde escuro, accent',
        ),
      ],
    ),
    Product(
      id: 'p-005',
      name: 'Caneca Garoa 280ml',
      priceCents: 5990,
      emoji: '🍵',
      category: ProductCategory.tabletop,
      subtitle: 'Porcelana fosca · Borda fina',
      description:
          'Caneca em porcelana fosca, parede fina e borda confortavel. '
          'Tamanho ideal pra cappuccino ou cafe coado duplo.',
      variants: [
        ProductVariant(
          id: 'cor-creme',
          label: 'Creme',
          sublabel: 'Acabamento neutro',
        ),
        ProductVariant(
          id: 'cor-cafe',
          label: 'Cafe',
          sublabel: 'Marrom esmaltado',
        ),
      ],
    ),
    Product(
      id: 'p-006',
      name: 'Prensa Francesa 500ml',
      priceCents: 18990,
      emoji: '🫖',
      category: ProductCategory.tabletop,
      subtitle: 'Vidro borossilicato · Inox escovado',
      description:
          'Prensa francesa em vidro temperado com aro de inox escovado '
          'e filtro duplo. Rendimento de 4 xicaras de cafe encorpado.',
      variants: [],
    ),
    Product(
      id: 'p-007',
      name: 'Bule de Coar Porcelana',
      priceCents: 13990,
      emoji: '☕',
      category: ProductCategory.tabletop,
      subtitle: 'Suporte + bule 600ml',
      description:
          'Conjunto pra coado V-60: suporte conico em porcelana e bule '
          'em vidro com bico de precisao. Aceita filtros 102 ou de pano.',
      variants: [],
    ),
    Product(
      id: 'p-008',
      name: 'Caneta Tecnica 0.5mm',
      priceCents: 2490,
      emoji: '✒️',
      category: ProductCategory.stationery,
      subtitle: 'Tinta gel · Ponta de aco',
      description:
          'Caneta tecnica de gel preto com ponta de aco e corpo em '
          'aluminio anodizado. Para escrita continua e desenho fino.',
      variants: [
        ProductVariant(
          id: 'p-03',
          label: '0.3mm',
          sublabel: 'Tracado extra fino',
        ),
        ProductVariant(
          id: 'p-05',
          label: '0.5mm',
          sublabel: 'Tracado padrao',
        ),
        ProductVariant(
          id: 'p-07',
          label: '0.7mm',
          sublabel: 'Tracado medio',
          deltaCents: 200,
        ),
      ],
    ),
    Product(
      id: 'p-009',
      name: 'Garoa, Cafe e Cidade',
      priceCents: 6990,
      emoji: '📕',
      category: ProductCategory.bookshop,
      subtitle: 'Ensaio · 192 paginas',
      description:
          'Ensaio sobre como o cafe foi entrando nos rituais da '
          'cidade — da rua pro escritorio, do encontro pro trabalho. '
          'Tiragem limitada, costurado.',
      variants: [],
    ),
    Product(
      id: 'p-010',
      name: 'Poemas de Garoa',
      priceCents: 5490,
      emoji: '📗',
      category: ProductCategory.bookshop,
      subtitle: 'Poesia · Capa cartonada',
      description:
          'Reuniao de poesia curta escrita em manhas longas. Capa '
          'cartonada com lombada quadrada e marcador de fita.',
      variants: [],
    ),
    Product(
      id: 'p-011',
      name: 'Bolacha de Mesa Cortica',
      priceCents: 3990,
      emoji: '⚫',
      category: ProductCategory.tabletop,
      subtitle: 'Cortica natural · Kit com 4',
      description:
          'Kit com quatro bolachas de cortica natural, prensadas a '
          'frio. Mantem a mesa seca e a marca do copo elegante.',
      variants: [],
    ),
    Product(
      id: 'p-012',
      name: 'Drip Stand de Madeira',
      priceCents: 22990,
      emoji: '🪵',
      category: ProductCategory.tabletop,
      subtitle: 'Madeira nobre · Bandeja inox',
      description:
          'Estacao pra cafe em madeira nobre com bandeja em inox '
          'escovado. Suporta V-60, Chemex ou prensa pequena.',
      variants: [],
    ),
  ];

  /// Subset destacado na home — 4 produtos representativos.
  static List<Product> get featured => [
        all[0], // Cafe Especial 250g
        all[2], // Caderno A5
        all[5], // Prensa francesa
        all[8], // Livro Garoa, Cafe e Cidade
      ];

  /// Filtra o catalogo por categoria.
  static List<Product> byCategory(ProductCategory cat) =>
      all.where((p) => p.category == cat).toList(growable: false);
}
