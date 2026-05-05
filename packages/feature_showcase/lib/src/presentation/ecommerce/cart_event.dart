import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/domain/product.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => const [];
}

class CartAddProduct extends CartEvent {
  const CartAddProduct(this.product);
  final Product product;

  @override
  List<Object?> get props => [product];
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
