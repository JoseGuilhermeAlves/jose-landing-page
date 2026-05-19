import 'dart:async';

import 'package:feature_showcase/src/delivery/domain/delivery_order.dart';
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

    if (ticker != null) {
      _tickSub = ticker.listen((_) => add(const DeliveryTickRequested()));
    }
  }

  final List<DeliveryOrder> _initial;
  StreamSubscription<void>? _tickSub;

  void _onTick(DeliveryTickRequested event, Emitter<DeliveryState> emit) {
    if (state.allDelivered) return;

    final orders = [...state.orders];
    final n = orders.length;
    if (n == 0) return;

    // Procura o proximo pedido nao-final a partir do cursor (round-robin).
    var i = state.cursor;
    var attempts = 0;
    while (orders[i].status.isFinal && attempts < n) {
      i = (i + 1) % n;
      attempts++;
    }

    if (orders[i].status.isFinal) return;

    orders[i] = orders[i].copyWith(status: orders[i].status.next);

    emit(state.copyWith(orders: orders, cursor: (i + 1) % n));
  }

  void _onReset(DeliveryReset event, Emitter<DeliveryState> emit) {
    emit(DeliveryState(orders: _initial));
  }

  @override
  Future<void> close() {
    _tickSub?.cancel();
    return super.close();
  }
}
