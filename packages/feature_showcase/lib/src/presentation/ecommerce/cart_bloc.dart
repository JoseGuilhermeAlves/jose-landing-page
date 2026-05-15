import 'package:feature_showcase/src/domain/order_summary.dart';
import 'package:feature_showcase/src/domain/product.dart';
import 'package:feature_showcase/src/presentation/ecommerce/cart_event.dart';
import 'package:feature_showcase/src/presentation/ecommerce/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartAddProduct>(_onAdd);
    on<CartRemoveProduct>(_onRemove);
    on<CartSetQuantity>(_onSetQuantity);
    on<CartCleared>(_onCleared);
    on<CartCheckoutRequested>(_onCheckout);
  }

  /// Contador sequencial pro numero de pedido — incrementa por sessao.
  /// Estatico pra resetar entre testes via [CartBloc.resetOrderCounter].
  static int _orderCounter = 0;

  /// Utilidade pra testes — zera o contador entre cenarios.
  static void resetOrderCounter() => _orderCounter = 0;

  void _onAdd(CartAddProduct event, Emitter<CartState> emit) {
    final delta = event.quantity <= 0 ? 1 : event.quantity;
    final updated = _applyDelta(state.items, event.product, delta);
    emit(state.copyWith(items: updated));
  }

  void _onRemove(CartRemoveProduct event, Emitter<CartState> emit) {
    final existing = _findById(state.items, event.productId);
    if (existing == null) return;
    final updated = _applyDelta(state.items, existing.product, -1);
    emit(state.copyWith(items: updated));
  }

  void _onSetQuantity(CartSetQuantity event, Emitter<CartState> emit) {
    final existing = _findById(state.items, event.productId);
    if (existing == null) return;
    final updated = _setQuantity(state.items, existing.product, event.quantity);
    emit(state.copyWith(items: updated));
  }

  void _onCleared(CartCleared event, Emitter<CartState> emit) {
    emit(state.copyWith(items: const [], clearLastOrder: true));
  }

  void _onCheckout(CartCheckoutRequested event, Emitter<CartState> emit) {
    if (state.items.isEmpty) return;
    final subtotal = state.totalCents;
    // Frete gratis acima de R\$ 150 (15000 cents); abaixo, R\$ 15.
    final shipping = subtotal >= 15000 ? 0.0 : 1500.0;
    _orderCounter += 1;
    final order = OrderSummary(
      orderNumber: 'GAR-${_orderCounter.toString().padLeft(4, '0')}',
      itemsCount: state.totalQuantity,
      subtotalCents: subtotal,
      shippingCents: shipping,
      address: MockAddress.garoaDefault,
      etaLabel: '3 a 5 dias uteis',
    );
    emit(state.copyWith(items: const [], lastOrder: order));
  }

  static CartLine? _findById(List<CartLine> lines, String id) {
    for (final l in lines) {
      if (l.product.id == id) return l;
    }
    return null;
  }

  static List<CartLine> _applyDelta(
    List<CartLine> lines,
    Product product,
    int delta,
  ) {
    final existing = _findById(lines, product.id);
    final nextQty = (existing?.quantity ?? 0) + delta;
    return _setQuantity(lines, product, nextQty);
  }

  static List<CartLine> _setQuantity(
    List<CartLine> lines,
    Product product,
    int qty,
  ) {
    final filtered = [
      for (final l in lines)
        if (l.product.id != product.id) l,
    ];
    if (qty <= 0) return filtered;
    return [...filtered, CartLine(product: product, quantity: qty)];
  }
}
