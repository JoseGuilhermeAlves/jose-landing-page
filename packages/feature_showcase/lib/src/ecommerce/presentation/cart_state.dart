import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/ecommerce/domain/order_summary.dart';
import 'package:feature_showcase/src/ecommerce/domain/product.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
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
  const CartState({this.items = const [], this.lastOrder});

  final List<CartLine> items;

  /// Pedido mais recente concluido (preenchido por
  /// `CartCheckoutRequested`). Quando null, ainda nao houve checkout
  /// na sessao. A UI usa esse campo pra navegar pra tela de Resumo.
  final OrderSummary? lastOrder;

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

  /// Formatado como BRL.
  String get formattedTotal => formatBrl(totalCents);

  CartState copyWith({
    List<CartLine>? items,
    OrderSummary? lastOrder,
    bool clearLastOrder = false,
  }) {
    return CartState(
      items: items ?? this.items,
      lastOrder: clearLastOrder ? null : (lastOrder ?? this.lastOrder),
    );
  }

  @override
  List<Object?> get props => [items, lastOrder];
}
