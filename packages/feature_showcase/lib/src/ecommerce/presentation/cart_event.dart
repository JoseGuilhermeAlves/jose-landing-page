import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/ecommerce/domain/product.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => const [];
}

class CartAddProduct extends CartEvent {
  const CartAddProduct(this.product, {this.quantity = 1});
  final Product product;

  /// Quantidade a adicionar (default 1 mantem o comportamento do
  /// botao "Adicionar" do card; o detalhe usa quantity > 1 quando o
  /// usuario regula com o stepper).
  final int quantity;

  @override
  List<Object?> get props => [product, quantity];
}

class CartRemoveProduct extends CartEvent {
  const CartRemoveProduct(this.productId);
  final String productId;

  @override
  List<Object?> get props => [productId];
}

class CartSetQuantity extends CartEvent {
  const CartSetQuantity(this.productId, this.quantity);
  final String productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

/// Disparado quando o usuario clica em "Finalizar pedido" no carrinho.
/// O bloc snapshota o estado atual em um `OrderSummary`, esvazia os
/// items e emite com `lastOrder` preenchido — a UI navega pra
/// `GaroaOrderSummaryPage`.
class CartCheckoutRequested extends CartEvent {
  const CartCheckoutRequested();
}
