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

/// Cria um novo pedido a partir de um vendor. Seleciona os itens do
/// catalogo vinculados ao vendor, monta line items com qty=1 e
/// insere o pedido no inicio da lista em status `received`.
class DeliveryOrderPlaced extends DeliveryEvent {
  const DeliveryOrderPlaced(this.vendorId);

  final String vendorId;

  @override
  List<Object?> get props => [vendorId];
}

/// Cancela o pedido com `orderId`. Marca status como `cancelled` (que
/// e terminal) — pedido sai do round-robin e migra pro historico.
class DeliveryOrderCancelled extends DeliveryEvent {
  const DeliveryOrderCancelled(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
