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

/// Cria pedido a partir de selecao manual de itens (carrinho).
/// [quantities] mapeia `itemId` → quantidade selecionada. Os campos de
/// checkout ([addressLine], [paymentLabel], [notes]) sao opcionais —
/// quando vazios o bloc usa o endereco/pagamento default do mock,
/// preservando compat com chamadas que pulam o checkout.
class DeliveryOrderPlacedWithCart extends DeliveryEvent {
  const DeliveryOrderPlacedWithCart({
    required this.vendorId,
    required this.quantities,
    this.addressLine = '',
    this.paymentLabel = '',
    this.notes = '',
  });

  final String vendorId;
  final Map<String, int> quantities;

  /// Endereco de entrega escolhido no checkout. Vazio = default do mock.
  final String addressLine;

  /// Forma de pagamento escolhida no checkout. Vazio = default do mock.
  final String paymentLabel;

  /// Observacao do pedido. Vazio = sem nota.
  final String notes;

  @override
  List<Object?> get props => [
    vendorId,
    quantities,
    addressLine,
    paymentLabel,
    notes,
  ];
}

/// Cancela o pedido com `orderId`. Marca status como `cancelled` (que
/// e terminal) — pedido sai do round-robin e migra pro historico.
class DeliveryOrderCancelled extends DeliveryEvent {
  const DeliveryOrderCancelled(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
