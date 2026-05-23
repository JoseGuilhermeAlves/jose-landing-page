import 'package:feature_showcase/src/scheduling/domain/appointment.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_event.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc do mock de agendamento. Aceita `today` injetavel —
/// produto usa `DateTime.now()`, testes passam data fixa.
///
/// Pre-booked slots padrao: regra deterministica baseada em
/// dia da semana + indice de slot, pra demo nunca parecer "vazia
/// demais" em viewport novo.
class SchedulingBloc extends Bloc<SchedulingEvent, SchedulingState> {
  SchedulingBloc({required DateTime today, Set<DateTime>? preBookedSlots})
    : super(
        SchedulingState(
          today: _stripTime(today),
          selectedDate: _stripTime(today),
          preBookedSlots: preBookedSlots ?? _defaultPreBookings(today),
          userBookedSlots: const {},
        ),
      ) {
    on<SchedulingDateSelected>(_onDateSelected);
    on<SchedulingSlotBooked>(_onSlotBooked);
    on<SchedulingSlotCancelled>(_onSlotCancelled);
    on<SchedulingAppointmentConfirmed>(_onAppointmentConfirmed);
    on<SchedulingAppointmentCancelled>(_onAppointmentCancelled);
  }

  void _onDateSelected(
    SchedulingDateSelected event,
    Emitter<SchedulingState> emit,
  ) {
    emit(state.copyWith(selectedDate: _stripTime(event.date)));
  }

  void _onSlotBooked(
    SchedulingSlotBooked event,
    Emitter<SchedulingState> emit,
  ) {
    if (state.preBookedSlots.contains(event.slot)) return;
    if (state.userBookedSlots.contains(event.slot)) return;
    emit(
      state.copyWith(userBookedSlots: {...state.userBookedSlots, event.slot}),
    );
  }

  void _onSlotCancelled(
    SchedulingSlotCancelled event,
    Emitter<SchedulingState> emit,
  ) {
    if (!state.userBookedSlots.contains(event.slot)) return;
    emit(
      state.copyWith(
        userBookedSlots: {
          for (final s in state.userBookedSlots)
            if (s != event.slot) s,
        },
      ),
    );
  }

  void _onAppointmentConfirmed(
    SchedulingAppointmentConfirmed event,
    Emitter<SchedulingState> emit,
  ) {
    final appt = event.appointment;
    // Idempotente: se ja existe agendamento com mesmo id, no-op.
    if (state.confirmedAppointments.any((a) => a.id == appt.id)) return;
    if (state.preBookedSlots.contains(appt.slot)) return;
    emit(
      state.copyWith(
        userBookedSlots: {...state.userBookedSlots, appt.slot},
        confirmedAppointments: [...state.confirmedAppointments, appt],
      ),
    );
  }

  void _onAppointmentCancelled(
    SchedulingAppointmentCancelled event,
    Emitter<SchedulingState> emit,
  ) {
    final appt = state.confirmedAppointments
        .where((a) => a.id == event.appointmentId)
        .cast<Appointment?>()
        .firstWhere((a) => true, orElse: () => null);
    if (appt == null) return;
    emit(
      state.copyWith(
        confirmedAppointments: [
          for (final a in state.confirmedAppointments)
            if (a.id != event.appointmentId) a,
        ],
        userBookedSlots: {
          for (final s in state.userBookedSlots)
            if (s != appt.slot) s,
        },
      ),
    );
  }

  static DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Pre-booked padrao — pra cada dia dos proximos 14, marca slots
  /// nos indices `(weekday + i) % 7 == 0` (entre 0 e 17). Resultado:
  /// 2-3 slots reservados por dia, distribuicao variando por dia da
  /// semana, totalmente deterministico.
  static Set<DateTime> _defaultPreBookings(DateTime today) {
    final base = _stripTime(today);
    final result = <DateTime>{};
    for (var dayOffset = 0; dayOffset < 14; dayOffset++) {
      final day = base.add(Duration(days: dayOffset));
      for (var slot = 0; slot < 18; slot++) {
        if ((day.weekday + slot * 3) % 7 == 0) {
          result.add(
            DateTime(
              day.year,
              day.month,
              day.day,
              9,
            ).add(Duration(minutes: 30 * slot)),
          );
        }
      }
    }
    return result;
  }
}
