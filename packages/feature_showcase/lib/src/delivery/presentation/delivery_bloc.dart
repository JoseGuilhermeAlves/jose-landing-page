import 'dart:async';

import 'package:feature_showcase/src/delivery/data/aurora_checkout_catalog.dart';
import 'package:feature_showcase/src/delivery/data/aurora_items_catalog.dart';
import 'package:feature_showcase/src/delivery/data/aurora_vendors_catalog.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_order.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_status.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_event.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc do mock de delivery. Avanca pedidos pelo proximo status em
/// round-robin a cada [DeliveryTickRequested]. Em produto real,
/// substituiria o ticker por um stream do backend; aqui o widget
/// host injeta um `Stream.periodic` e os testes injetam um
/// `StreamController` pra controle deterministico.
class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  DeliveryBloc({
    required List<DeliveryOrder> initialOrders,
    Stream<void>? ticker,
  }) : _initial = List.unmodifiable(initialOrders),
       super(DeliveryState(orders: initialOrders)) {
    on<DeliveryTickRequested>(_onTick);
    on<DeliveryReset>(_onReset);
    on<DeliveryOrderPlaced>(_onOrderPlaced);
    on<DeliveryOrderPlacedWithCart>(_onOrderPlacedWithCart);
    on<DeliveryOrderCancelled>(_onOrderCancelled);

    if (ticker != null) {
      _tickSub = ticker.listen((_) => add(const DeliveryTickRequested()));
    }
  }

  final List<DeliveryOrder> _initial;
  StreamSubscription<void>? _tickSub;

  void _onTick(DeliveryTickRequested event, Emitter<DeliveryState> emit) {
    if (state.allDelivered) return;

    // Decrementa ETA de todos os pedidos ainda em andamento — mesmo os
    // que nao avancam de status nesta rodada. Da sensacao de relogio
    // andando em todos os pedidos visiveis.
    final orders = [
      for (final o in state.orders)
        o.status.isFinal || o.etaMinutes <= 0
            ? o
            : o.copyWith(etaMinutes: o.etaMinutes - 1),
    ];
    final n = orders.length;
    if (n == 0) return;

    // Procura o proximo pedido nao-final a partir do cursor (round-robin).
    var i = state.cursor;
    var attempts = 0;
    while (orders[i].status.isFinal && attempts < n) {
      i = (i + 1) % n;
      attempts++;
    }

    if (orders[i].status.isFinal) {
      emit(state.copyWith(orders: orders));
      return;
    }

    orders[i] = orders[i].copyWith(status: orders[i].status.next);

    emit(state.copyWith(orders: orders, cursor: (i + 1) % n));
  }

  void _onReset(DeliveryReset event, Emitter<DeliveryState> emit) {
    emit(DeliveryState(orders: _initial));
  }

  static int _orderCounter = 1050;

  /// Retorna o id do proximo pedido sem incrementar.
  static String peekNextOrderId() => '#A-$_orderCounter';

  /// Reseta o contador de pedidos — util pra isolar testes.
  static void resetOrderCounter() => _orderCounter = 1050;

  void _onOrderPlaced(DeliveryOrderPlaced event, Emitter<DeliveryState> emit) {
    final vendor = AuroraVendorsCatalog.byId(event.vendorId);
    if (vendor == null) return;

    final catalogItems = AuroraItemsCatalog.byVendor(vendor.id);
    final lineItems = [
      for (final item in catalogItems)
        OrderLineItem(
          itemId: item.id,
          name: item.name,
          quantity: 1,
          unitShort: item.unit.shortLabel,
          unitPriceCents: item.priceCents,
        ),
    ];

    final subtotalCents = lineItems.fold<double>(
      0,
      (sum, li) => sum + li.subtotalCents,
    );

    final orderId = '#A-${_orderCounter++}';
    final order = DeliveryOrder(
      id: orderId,
      customerName: 'Voce',
      items: lineItems.length,
      status: DeliveryStatus.received,
      etaMinutes: vendor.etaMinutes,
      vendorId: vendor.id,
      lineItems: lineItems,
      totalCents: subtotalCents + vendor.deliveryFeeCents,
      addressLine: 'Rua das Palmeiras, 240 · Pinheiros · SP',
      placedAtLabel: 'Agora',
    );

    emit(state.copyWith(orders: [order, ...state.orders]));
  }

  void _onOrderPlacedWithCart(
    DeliveryOrderPlacedWithCart event,
    Emitter<DeliveryState> emit,
  ) {
    final vendor = AuroraVendorsCatalog.byId(event.vendorId);
    if (vendor == null) return;

    final catalogItems = AuroraItemsCatalog.byVendor(vendor.id);
    final lineItems = <OrderLineItem>[
      for (final item in catalogItems)
        if (event.quantities.containsKey(item.id))
          OrderLineItem(
            itemId: item.id,
            name: item.name,
            quantity: event.quantities[item.id]!.toDouble(),
            unitShort: item.unit.shortLabel,
            unitPriceCents: item.priceCents,
          ),
    ];

    if (lineItems.isEmpty) return;

    final subtotalCents = lineItems.fold<double>(
      0,
      (sum, li) => sum + li.subtotalCents,
    );

    // Sem checkout: usa o endereco/pagamento default do catalogo pra o
    // pedido nunca sair sem essas linhas. Com checkout: usa o que o
    // cliente escolheu.
    final addressLine = event.addressLine.isNotEmpty
        ? event.addressLine
        : AuroraCheckoutCatalog.addresses.first.oneLine;
    final paymentLabel = event.paymentLabel.isNotEmpty
        ? event.paymentLabel
        : AuroraCheckoutCatalog.paymentMethods.first.oneLine;

    final orderId = '#A-${_orderCounter++}';
    final order = DeliveryOrder(
      id: orderId,
      customerName: 'Voce',
      items: lineItems.length,
      status: DeliveryStatus.received,
      etaMinutes: vendor.etaMinutes,
      vendorId: vendor.id,
      lineItems: lineItems,
      totalCents: subtotalCents + vendor.deliveryFeeCents,
      addressLine: addressLine,
      placedAtLabel: 'Agora',
      paymentLabel: paymentLabel,
      notes: event.notes,
    );

    emit(state.copyWith(orders: [order, ...state.orders]));
  }

  void _onOrderCancelled(
    DeliveryOrderCancelled event,
    Emitter<DeliveryState> emit,
  ) {
    final orders = [...state.orders];
    final idx = orders.indexWhere((o) => o.id == event.orderId);
    if (idx < 0) return;
    if (orders[idx].status.isFinal) return;
    orders[idx] = orders[idx].copyWith(
      status: DeliveryStatus.cancelled,
      etaMinutes: 0,
    );
    emit(state.copyWith(orders: orders));
  }

  @override
  Future<void> close() {
    _tickSub?.cancel();
    return super.close();
  }
}
