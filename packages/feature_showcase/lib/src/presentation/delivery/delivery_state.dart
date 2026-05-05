import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/domain/delivery_order.dart';
import 'package:flutter/foundation.dart';

@immutable
class DeliveryState extends Equatable {
  const DeliveryState({required this.orders, this.cursor = 0});

  final List<DeliveryOrder> orders;

  /// Index do proximo pedido a ser avancado pelo round-robin.
  final int cursor;

  bool get allDelivered =>
      orders.isNotEmpty && orders.every((o) => o.status.isFinal);

  DeliveryState copyWith({List<DeliveryOrder>? orders, int? cursor}) {
    return DeliveryState(
      orders: orders ?? this.orders,
      cursor: cursor ?? this.cursor,
    );
  }

  @override
  List<Object?> get props => [orders, cursor];
}
