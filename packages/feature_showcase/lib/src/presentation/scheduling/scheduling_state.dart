import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/domain/appointment.dart';
import 'package:flutter/foundation.dart';

/// Status visual de um slot do calendario.
enum SlotStatus {
  /// Aberto pra agendamento.
  free,

  /// O usuario reservou nesta sessao.
  booked,

  /// Indisponivel (mock de outro cliente, manutencao, etc).
  unavailable,
}

/// Slot horario com status. Exposto pelo state via [SchedulingState.slotsFor].
@immutable
class AppointmentSlot extends Equatable {
  const AppointmentSlot({required this.start, required this.status});

  /// Inicio do slot — duracao implicita de 30 min.
  final DateTime start;
  final SlotStatus status;

  @override
  List<Object?> get props => [start, status];
}

@immutable
class SchedulingState extends Equatable {
  const SchedulingState({
    required this.today,
    required this.selectedDate,
    required this.preBookedSlots,
    required this.userBookedSlots,
    this.confirmedAppointments = const [],
  });

  /// "Hoje" injetado no bloc — ancora pro range de datas.
  final DateTime today;

  /// Data atualmente em foco no strip de dias.
  final DateTime selectedDate;

  /// Slots pre-bloqueados pelo mock (outras "reservas" ja existentes).
  final Set<DateTime> preBookedSlots;

  /// Slots reservados pelo usuario nesta sessao.
  final Set<DateTime> userBookedSlots;

  /// Agendamentos confirmados pelo fluxo Vitral (catalogo → calendario
  /// → confirmacao). Diferente de [userBookedSlots], carrega snapshot
  /// completo (servico + profissional + preco). A home da Vitral usa
  /// pra exibir o "proximo agendamento".
  final List<Appointment> confirmedAppointments;

  /// Janela de [today, today+1, ..., today+13] — 14 dias.
  List<DateTime> get availableDates =>
      [for (var i = 0; i < 14; i++) today.add(Duration(days: i))];

  /// Proximo agendamento confirmado (slot mais cedo no futuro). Null
  /// quando nao ha confirmacao na sessao.
  Appointment? get nextAppointment {
    if (confirmedAppointments.isEmpty) return null;
    final sorted = [...confirmedAppointments]
      ..sort((a, b) => a.slot.compareTo(b.slot));
    return sorted.first;
  }

  /// Gera os slots de [date]: 18 janelas de 30 min, das 9h as 17:30.
  List<AppointmentSlot> slotsFor(DateTime date) {
    final base = DateTime(date.year, date.month, date.day, 9);
    return [
      for (var i = 0; i < 18; i++) _buildSlot(base.add(Duration(minutes: 30 * i))),
    ];
  }

  AppointmentSlot _buildSlot(DateTime start) {
    // Pre-booked tem precedencia: se um slot aparece em ambos, prevalece
    // unavailable (caso degenerado, defende a invariante visual).
    final status = preBookedSlots.contains(start)
        ? SlotStatus.unavailable
        : userBookedSlots.contains(start)
            ? SlotStatus.booked
            : SlotStatus.free;
    return AppointmentSlot(start: start, status: status);
  }

  SchedulingState copyWith({
    DateTime? selectedDate,
    Set<DateTime>? preBookedSlots,
    Set<DateTime>? userBookedSlots,
    List<Appointment>? confirmedAppointments,
  }) {
    return SchedulingState(
      today: today,
      selectedDate: selectedDate ?? this.selectedDate,
      preBookedSlots: preBookedSlots ?? this.preBookedSlots,
      userBookedSlots: userBookedSlots ?? this.userBookedSlots,
      confirmedAppointments:
          confirmedAppointments ?? this.confirmedAppointments,
    );
  }

  @override
  List<Object?> get props => [
        today,
        selectedDate,
        preBookedSlots,
        userBookedSlots,
        confirmedAppointments,
      ];
}
