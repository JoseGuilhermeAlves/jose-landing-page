import 'package:equatable/equatable.dart';

sealed class SchedulingEvent extends Equatable {
  const SchedulingEvent();

  @override
  List<Object?> get props => const [];
}

class SchedulingDateSelected extends SchedulingEvent {
  const SchedulingDateSelected(this.date);
  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class SchedulingSlotBooked extends SchedulingEvent {
  const SchedulingSlotBooked(this.slot);
  final DateTime slot;

  @override
  List<Object?> get props => [slot];
}

class SchedulingSlotCancelled extends SchedulingEvent {
  const SchedulingSlotCancelled(this.slot);
  final DateTime slot;

  @override
  List<Object?> get props => [slot];
}
