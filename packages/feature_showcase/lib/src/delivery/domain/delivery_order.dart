import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_status.dart';
import 'package:flutter/foundation.dart';

/// Linha de item dentro de um [DeliveryOrder]. Campos derivados do
/// `MarketItem` que originou a compra — duplicados aqui para o pedido
/// ficar imutavel mesmo se o catalogo mudar depois.
@immutable
class OrderLineItem extends Equatable {
  const OrderLineItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unitShort,
    required this.unitPriceCents,
  });

  final String itemId;
  final String name;

  /// Quantidade comprada na unidade do item (kg, un, pct).
  final double quantity;

  /// Sigla da unidade ("kg" / "un" / "pct" / "mac").
  final String unitShort;

  /// Preco unitario em centavos (snapshot).
  final double unitPriceCents;

  double get subtotalCents => unitPriceCents * quantity;

  @override
  List<Object?> get props => [
    itemId,
    name,
    quantity,
    unitShort,
    unitPriceCents,
  ];
}

/// Pedido do mock de delivery. Campos basicos (cliente, status, ETA)
/// foram mantidos por compatibilidade com os testes existentes. Os
/// campos novos (vendorId, items, totalCents, addressLine) sao
/// opcionais — populados pelo mock Aurora pra dar mais carne ao
/// pedido na tela de detalhe.
@immutable
class DeliveryOrder extends Equatable {
  const DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.items,
    required this.status,
    required this.etaMinutes,
    this.vendorId = '',
    this.lineItems = const [],
    this.totalCents = 0,
    this.addressLine = '',
    this.placedAtLabel = '',
  });

  final String id;
  final String customerName;

  /// Total de itens (mantido int por compatibilidade — historicamente
  /// representava so a contagem). A composicao real fica em
  /// [lineItems] quando disponivel.
  final int items;
  final DeliveryStatus status;
  final int etaMinutes;

  /// FK pro `Vendor` (opcional). Vazio quando o pedido nao tem
  /// vendor associado — caso do delivery generico legado.
  final String vendorId;

  /// Itens do pedido (snapshot). Vazia no delivery generico legado.
  final List<OrderLineItem> lineItems;

  /// Total em centavos (subtotal + frete). Quando 0, a UI pode somar
  /// dos [lineItems] sob demanda.
  final double totalCents;

  /// Endereco de entrega formatado em uma linha (mock).
  final String addressLine;

  /// Horario do pedido formatado mock ("hoje as 09:42").
  final String placedAtLabel;

  DeliveryOrder copyWith({
    String? id,
    String? customerName,
    int? items,
    DeliveryStatus? status,
    int? etaMinutes,
    String? vendorId,
    List<OrderLineItem>? lineItems,
    double? totalCents,
    String? addressLine,
    String? placedAtLabel,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      status: status ?? this.status,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      vendorId: vendorId ?? this.vendorId,
      lineItems: lineItems ?? this.lineItems,
      totalCents: totalCents ?? this.totalCents,
      addressLine: addressLine ?? this.addressLine,
      placedAtLabel: placedAtLabel ?? this.placedAtLabel,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerName,
    items,
    status,
    etaMinutes,
    vendorId,
    lineItems,
    totalCents,
    addressLine,
    placedAtLabel,
  ];

  @override
  String toString() =>
      'DeliveryOrder(id: $id, customer: $customerName, status: $status)';
}
