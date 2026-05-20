/// Status do pedido no fluxo de delivery (PROJECT.md §4.3). Ordem
/// linear: received -> preparing -> outForDelivery -> delivered. O
/// estado `cancelled` e terminal e pode ser atingido a partir de
/// qualquer estado nao-final via `DeliveryOrderCancelled`.
enum DeliveryStatus {
  received('Recebido'),
  preparing('Em preparo'),
  outForDelivery('Saiu pra entrega'),
  delivered('Entregue'),
  cancelled('Cancelado');

  const DeliveryStatus(this.label);
  final String label;

  /// Estados terminais — round-robin do bloc pula esses; UI mostra
  /// como pedido encerrado.
  bool get isFinal =>
      this == DeliveryStatus.delivered || this == DeliveryStatus.cancelled;

  /// Proximo status no fluxo "para a frente". Cancelled fica fixo
  /// (nao avanca). Delivered permanece como ultimo estagio.
  DeliveryStatus get next {
    if (isFinal) return this;
    final linear = [
      DeliveryStatus.received,
      DeliveryStatus.preparing,
      DeliveryStatus.outForDelivery,
      DeliveryStatus.delivered,
    ];
    final i = linear.indexOf(this);
    if (i < 0 || i >= linear.length - 1) return this;
    return linear[i + 1];
  }
}
