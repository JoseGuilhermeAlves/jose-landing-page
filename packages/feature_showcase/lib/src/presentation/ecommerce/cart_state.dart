import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/domain/product.dart';
import 'package:flutter/foundation.dart';

@immutable
class CartLine extends Equatable {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotalCents => product.priceCents * quantity;

  CartLine copyWith({int? quantity}) =>
      CartLine(product: product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

@immutable
class CartState extends Equatable {
  const CartState({this.items = const []});

  final List<CartLine> items;

  double get totalCents =>
      items.fold(0, (acc, line) => acc + line.subtotalCents);

  int get totalQuantity =>
      items.fold(0, (acc, line) => acc + line.quantity);

  int quantityFor(String productId) {
    for (final l in items) {
      if (l.product.id == productId) return l.quantity;
    }
    return 0;
  }

  /// Formatado como BRL — reaproveita o formatador do Product passando
  /// um produto sintetico com priceCents = totalCents.
  String get formattedTotal {
    final synthetic = Product(
      id: '__total__',
      name: 'total',
      priceCents: totalCents,
      emoji: '',
    );
    return synthetic.formattedPrice;
  }

  CartState copyWith({List<CartLine>? items}) =>
      CartState(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}
