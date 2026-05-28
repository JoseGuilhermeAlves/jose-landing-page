import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:flutter/foundation.dart';

/// Uma semana dentro do mesociclo. Carrega a lista de sessoes
/// planejadas pra cada dia + multiplicador de carga aplicado sobre
/// os exercicios. Periodizacao classica: deload na ultima semana.
@immutable
class ProgramWeek extends Equatable {
  const ProgramWeek({
    required this.index,
    required this.label,
    required this.intensityMultiplier,
    required this.targetStrain,
    required this.sessions,
    this.isDeload = false,
  });

  /// 1-based dentro do mesociclo (1..8).
  final int index;

  /// "Semana 1", "Acumulacao 2", "Intensificacao", "Deload".
  final String label;

  /// Multiplicador aplicado a [PlannedExercise.suggestedWeightKg]
  /// pra obter carga prescrita da semana. Default 1.0 = sem
  /// progressao; semanas posteriores rampam ate ~1.15.
  final double intensityMultiplier;

  /// Strain medio prescrito pra semana (0–21 Whoop-like).
  final double targetStrain;

  /// Mapeia dia da semana (1..7) -> template da sessao. Dias sem
  /// entrada sao descanso.
  final List<SessionTemplate> sessions;

  /// `true` pra semana de descarga (deload). Sinaliza pra UI mudar
  /// copy e cor.
  final bool isDeload;

  SessionTemplate? sessionFor(int weekday) {
    for (final s in sessions) {
      if (s.weekday == weekday) return s;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    index,
    label,
    intensityMultiplier,
    targetStrain,
    sessions,
    isDeload,
  ];

  @override
  String toString() =>
      'ProgramWeek($index, $label, x$intensityMultiplier, '
      '${sessions.length} sessions${isDeload ? ", deload" : ""})';
}
