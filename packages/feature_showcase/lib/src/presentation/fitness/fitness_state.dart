import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/domain/workout_day.dart';
import 'package:flutter/foundation.dart';

/// Chave composta `weekday|exerciseId` -> sets ja concluidos. Mapa
/// achatado em vez de aninhado pra simplificar comparacao por valor
/// via [Equatable].
typedef CompletedSetsMap = Map<String, int>;

@immutable
class FitnessState extends Equatable {
  const FitnessState({
    required this.plan,
    required this.selectedWeekday,
    required this.completedSets,
  });

  /// Plano da semana. 7 entradas, indexadas pelo `WorkoutDay.weekday`.
  final List<WorkoutDay> plan;

  /// Dia atualmente em foco no strip.
  final int selectedWeekday;

  /// Mapa de progresso. Chave: `${weekday}|${exerciseId}`.
  final CompletedSetsMap completedSets;

  WorkoutDay get selectedDay =>
      plan.firstWhere((d) => d.weekday == selectedWeekday);

  /// Quantos sets ja foram concluidos no exercicio dado, no dia dado.
  int completedFor({required int weekday, required String exerciseId}) =>
      completedSets[_key(weekday, exerciseId)] ?? 0;

  /// Sets concluidos somados no dia [weekday].
  int totalCompletedOn(int weekday) {
    final day = plan.firstWhere(
      (d) => d.weekday == weekday,
      orElse: () => const WorkoutDay(weekday: 0, label: '', exercises: []),
    );
    var total = 0;
    for (final ex in day.exercises) {
      total += completedFor(weekday: weekday, exerciseId: ex.id);
    }
    return total;
  }

  /// Total de sets concluidos na semana inteira.
  int get weeklyCompletedSets {
    var total = 0;
    for (final day in plan) {
      total += totalCompletedOn(day.weekday);
    }
    return total;
  }

  /// Total de sets-alvo da semana (ignora dias de descanso).
  int get weeklyTargetSets =>
      plan.fold(0, (acc, d) => acc + d.totalTargetSets);

  /// Progresso semanal em [0, 1]. Retorna 0 se nao houver alvo.
  double get weeklyProgress {
    final target = weeklyTargetSets;
    if (target == 0) return 0;
    return weeklyCompletedSets / target;
  }

  FitnessState copyWith({
    int? selectedWeekday,
    CompletedSetsMap? completedSets,
  }) {
    return FitnessState(
      plan: plan,
      selectedWeekday: selectedWeekday ?? this.selectedWeekday,
      completedSets: completedSets ?? this.completedSets,
    );
  }

  static String _key(int weekday, String exerciseId) =>
      '$weekday|$exerciseId';

  /// Helper estatico — usado pelo bloc pra montar mapas novos.
  static String composeKey(int weekday, String exerciseId) =>
      _key(weekday, exerciseId);

  @override
  List<Object?> get props => [plan, selectedWeekday, completedSets];
}
