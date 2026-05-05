import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Exercicio de um dia do plano de treino. Imutavel — o "executado"
/// (sets completados) vive no state do bloc, nunca aqui.
@immutable
class WorkoutExercise extends Equatable {
  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.targetSets,
    required this.reps,
    required this.weightKg,
  });

  final String id;
  final String name;
  final int targetSets;
  final int reps;
  final double weightKg;

  @override
  List<Object?> get props => [id, name, targetSets, reps, weightKg];

  @override
  String toString() =>
      'WorkoutExercise(id: $id, name: $name, sets: $targetSets x $reps)';
}
