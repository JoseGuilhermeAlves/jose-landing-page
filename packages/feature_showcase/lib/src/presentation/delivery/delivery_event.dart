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
