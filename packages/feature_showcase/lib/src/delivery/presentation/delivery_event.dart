import 'package:equatable/equatable.dart';

sealed class DeliveryEvent extends Equatable {
  const DeliveryEvent();

  @override
  List<Object?> get props => const [];
}

/// Avanca um pedido pelo proximo status (round-robin).
class DeliveryTickRequested extends DeliveryEvent {
  const DeliveryTickRequested();
}

/// Volta todos os pedidos pra status `received`.
class DeliveryReset extends DeliveryEvent {
  const DeliveryReset();
}

/// Cancela o pedido com `orderId`. Marca status como `cancelled` (que
/// e terminal) — pedido sai do round-robin e migra pro historico.
class DeliveryOrderCancelled extends DeliveryEvent {
  const DeliveryOrderCancelled(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
