import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_order.dart';
import 'package:flutter/foundation.dart';

@immutable
class DeliveryState extends Equatable {
  const DeliveryState({required this.orders, this.cursor = 0});

  final List<DeliveryOrder> orders;

  /// Index do proximo pedido a ser avancado pelo round-robin.
  final int cursor;

  bool get allDelivered =>
      orders.isNotEmpty && orders.every((o) => o.status.isFinal);

  /// Primeiro pedido nao final — usado pela home Aurora como "pedido
  /// ativo" do cliente. Null quando todos foram entregues.
  DeliveryOrder? get activeOrder {
    for (final o in orders) {
      if (!o.status.isFinal) return o;
    }
    return null;
  }

  /// Pedidos ja entregues — alimentam a tela de Historico.
  List<DeliveryOrder> get historyOrders => [
    for (final o in orders)
      if (o.status.isFinal) o,
  ];

  /// Lookup por id — null quando o pedido foi removido (nao ocorre no
  /// mock atual, mas e necessario pra rotas que recebem o id como
  /// argumento).
  DeliveryOrder? findById(String id) {
    for (final o in orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  DeliveryState copyWith({List<DeliveryOrder>? orders, int? cursor}) {
    return DeliveryState(
      orders: orders ?? this.orders,
      cursor: cursor ?? this.cursor,
    );
  }

  @override
  List<Object?> get props => [orders, cursor];
}
