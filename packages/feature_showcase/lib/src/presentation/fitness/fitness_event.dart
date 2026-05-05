import 'package:equatable/equatable.dart';

sealed class FitnessEvent extends Equatable {
  const FitnessEvent();

  @override
  List<Object?> get props => const [];
}

/// Troca o dia da semana em foco. [weekday] segue `DateTime.weekday`
/// (1 = segunda, 7 = domingo).
class FitnessDaySelected extends FitnessEvent {
  const FitnessDaySelected(this.weekday);
  final int weekday;

  @override
  List<Object?> get props => [weekday];
}

/// Marca um set a mais como concluido pro exercicio dado, no dia
/// dado. Limita ao [WorkoutExercise.targetSets].
class FitnessSetCompleted extends FitnessEvent {
  const FitnessSetCompleted({required this.weekday, required this.exerciseId});
  final int weekday;
  final String exerciseId;

  @override
  List<Object?> get props => [weekday, exerciseId];
}

/// Desfaz um set concluido (decrementa). No-op se ja esta em zero.
class FitnessSetUndone extends FitnessEvent {
  const FitnessSetUndone({required this.weekday, required this.exerciseId});
  final int weekday;
  final String exerciseId;

  @override
  List<Object?> get props => [weekday, exerciseId];
}

/// Zera o progresso da semana inteira.
class FitnessReset extends FitnessEvent {
  const FitnessReset();
}
