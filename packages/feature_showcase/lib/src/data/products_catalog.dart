import 'package:feature_showcase/src/domain/product.dart';

/// Mock estatico de produtos pro demo do e-commerce.
abstract final class ProductsCatalog {
  static const List<Product> all = [
    Product(
      id: 'p-001',
      name: 'Cafeteira Italiana',
      priceCents: 12990,
      emoji: '☕',
    ),
    Product(
      id: 'p-002',
      name: 'Caderno A5',
      priceCents: 3490,
      emoji: '📒',
    ),
    Product(
      id: 'p-003',
      name: 'Mochila urbana',
      priceCents: 24990,
      emoji: '🎒',
    ),
    Product(
      id: 'p-004',
      name: 'Camiseta',
      priceCents: 8990,
      emoji: '👕',
    ),
    Product(
      id: 'p-005',
      name: 'Cafe especial 250g',
      priceCents: 4590,
      emoji: '🫘',
    ),
    Product(
      id: 'p-006',
      name: 'Tenis casual',
      priceCents: 39990,
      emoji: '👟',
    ),
    Product(
      id: 'p-007',
      name: 'Caneca minimalista',
      priceCents: 5990,
      emoji: '☕',
    ),
    Product(
      id: 'p-008',
      name: 'Fones de ouvido',
      priceCents: 19990,
      emoji: '🎧',
    ),
  ];
}
