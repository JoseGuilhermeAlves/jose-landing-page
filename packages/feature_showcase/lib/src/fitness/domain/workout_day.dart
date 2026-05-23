import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/fitness/domain/workout_exercise.dart';
import 'package:flutter/foundation.dart';

/// Dia do plano de treino. [weekday] segue a convencao do `DateTime`
/// (1 = segunda, 7 = domingo). Quando [exercises] e vazio, o dia e
/// tratado como descanso.
@immutable
class WorkoutDay extends Equatable {
  const WorkoutDay({
    required this.weekday,
    required this.label,
    required this.exercises,
  });

  final int weekday;
  final String label;
  final List<WorkoutExercise> exercises;

  bool get isRestDay => exercises.isEmpty;

  /// Soma dos sets-alvo do dia. Em dia de descanso retorna 0.
  int get totalTargetSets => exercises.fold(0, (acc, e) => acc + e.targetSets);

  @override
  List<Object?> get props => [weekday, label, exercises];

  @override
  String toString() =>
      'WorkoutDay($weekday, $label, exercises: ${exercises.length})';
}
