import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/domain/appointment.dart';

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

/// Confirmacao final de um agendamento no fluxo Vitral — promove o
/// slot reservado para um `Appointment` completo (com servico +
/// profissional). Adicionado a `confirmedAppointments` da state e
/// tambem reservado em `userBookedSlots` (idempotente).
class SchedulingAppointmentConfirmed extends SchedulingEvent {
  const SchedulingAppointmentConfirmed(this.appointment);
  final Appointment appointment;

  @override
  List<Object?> get props => [appointment];
}
