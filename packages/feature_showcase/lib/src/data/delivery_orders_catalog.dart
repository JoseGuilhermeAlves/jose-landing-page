import 'package:feature_showcase/src/domain/delivery_order.dart';
import 'package:feature_showcase/src/domain/delivery_status.dart';

/// Mock estatico de pedidos pro demo de delivery. Todos comecam em
/// `received` — os ticks do bloc avancam progressivamente.
abstract final class DeliveryOrdersCatalog {
  static const List<DeliveryOrder> all = [
    DeliveryOrder(
      id: '#1042',
      customerName: 'Ana S.',
      items: 3,
      status: DeliveryStatus.received,
      etaMinutes: 25,
    ),
    DeliveryOrder(
      id: '#1043',
      customerName: 'Bruno T.',
      items: 1,
      status: DeliveryStatus.received,
      etaMinutes: 30,
    ),
    DeliveryOrder(
      id: '#1044',
      customerName: 'Carla M.',
      items: 5,
      status: DeliveryStatus.received,
      etaMinutes: 40,
    ),
    DeliveryOrder(
      id: '#1045',
      customerName: 'Diego L.',
      items: 2,
      status: DeliveryStatus.received,
      etaMinutes: 20,
    ),
    DeliveryOrder(
      id: '#1046',
      customerName: 'Elisa R.',
      items: 4,
      status: DeliveryStatus.received,
      etaMinutes: 35,
    ),
    DeliveryOrder(
      id: '#1047',
      customerName: 'Felipe O.',
      items: 2,
      status: DeliveryStatus.received,
      etaMinutes: 22,
    ),
  ];
}
