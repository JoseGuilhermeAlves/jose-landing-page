import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/domain/delivery_status.dart';
import 'package:flutter/foundation.dart';

/// Pedido do mock de delivery. Apenas o necessario pra demo:
/// cliente, qtd de itens, status e ETA.
@immutable
class DeliveryOrder extends Equatable {
  const DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.items,
    required this.status,
    required this.etaMinutes,
  });

  final String id;
  final String customerName;
  final int items;
  final DeliveryStatus status;
  final int etaMinutes;

  DeliveryOrder copyWith({
    String? id,
    String? customerName,
    int? items,
    DeliveryStatus? status,
    int? etaMinutes,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      status: status ?? this.status,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }

  @override
  List<Object?> get props => [id, customerName, items, status, etaMinutes];

  @override
  String toString() =>
      'DeliveryOrder(id: $id, customer: $customerName, status: $status)';
}
