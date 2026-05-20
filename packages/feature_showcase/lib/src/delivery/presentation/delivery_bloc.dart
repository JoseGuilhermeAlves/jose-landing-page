import 'dart:async';

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
  })  : _initial = List.unmodifiable(initialOrders),
        super(DeliveryState(orders: initialOrders)) {
    on<DeliveryTickRequested>(_onTick);
    on<DeliveryReset>(_onReset);
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
