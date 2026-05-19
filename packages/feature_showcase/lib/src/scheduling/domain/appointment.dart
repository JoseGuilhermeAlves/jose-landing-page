import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Agendamento confirmado pelo usuario na sessao Vitral. Snapshot de
/// servico + profissional + slot — desacoplado do catalogo pra
/// sobreviver a uma eventual mudanca dele.
@immutable
class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.specialistId,
    required this.specialistName,
    required this.slot,
    required this.durationMinutes,
    required this.priceCents,
  });

  /// Id sequencial gerado pelo bloc ao confirmar (ex.: "VIT-0001").
  final String id;

  final String serviceId;

  /// Snapshot do nome do servico no momento do agendamento.
  final String serviceName;

  final String specialistId;

  /// Snapshot do nome do profissional.
  final String specialistName;

  /// Horario de inicio do agendamento (30 min snap, igual ao bloc).
  final DateTime slot;

  final int durationMinutes;

  final double priceCents;

  /// Final do agendamento (slot + duracao).
  DateTime get endsAt => slot.add(Duration(minutes: durationMinutes));

  @override
  List<Object?> get props => [
        id,
        serviceId,
        serviceName,
        specialistId,
        specialistName,
        slot,
        durationMinutes,
        priceCents,
      ];
}
