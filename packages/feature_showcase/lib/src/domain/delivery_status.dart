/// Status do pedido no fluxo de delivery (PROJECT.md §4.3). Ordem
/// e enumeracao linear — o fluxo so vai pra frente.
enum DeliveryStatus {
  received('Recebido'),
  preparing('Em preparo'),
  outForDelivery('Saiu pra entrega'),
  delivered('Entregue');

  const DeliveryStatus(this.label);
  final String label;

  bool get isFinal => this == DeliveryStatus.delivered;

  /// Proximo status no fluxo. Em [DeliveryStatus.delivered] permanece.
  DeliveryStatus get next {
    final i = DeliveryStatus.values.indexOf(this);
    if (i >= DeliveryStatus.values.length - 1) return this;
    return DeliveryStatus.values[i + 1];
  }
}
