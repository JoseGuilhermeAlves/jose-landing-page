import 'package:feature_showcase/src/domain/workout_day.dart';
import 'package:feature_showcase/src/domain/workout_exercise.dart';
import 'package:feature_showcase/src/presentation/fitness/fitness_event.dart';
import 'package:feature_showcase/src/presentation/fitness/fitness_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc do mock de fitness. Mantem progresso de sets por (dia,
/// exercicio) na semana inteira. Aceita `today` injetavel pro foco
/// inicial cair no dia atual; testes passam data fixa.
class FitnessBloc extends Bloc<FitnessEvent, FitnessState> {
  FitnessBloc({
    required List<WorkoutDay> plan,
    required int today,
  }) : super(
          FitnessState(
            plan: plan,
            selectedWeekday: _resolveInitialDay(plan, today),
            completedSets: const <String, int>{},
          ),
        ) {
    on<FitnessDaySelected>(_onDaySelected);
    on<FitnessSetCompleted>(_onSetCompleted);
    on<FitnessSetUndone>(_onSetUndone);
    on<FitnessReset>(_onReset);
  }

  /// Se [today] cai num dia de descanso, foca no proximo dia com
  /// treino — evita o demo abrir vazio.
  static int _resolveInitialDay(List<WorkoutDay> plan, int today) {
    for (var offset = 0; offset < 7; offset++) {
      final wd = ((today - 1 + offset) % 7) + 1;
      final day = plan.firstWhere(
        (d) => d.weekday == wd,
        orElse: () => const WorkoutDay(weekday: 0, label: '', exercises: []),
      );
      if (!day.isRestDay) return wd;
    }
    return today;
  }

  void _onDaySelected(FitnessDaySelected event, Emitter<FitnessState> emit) {
    if (event.weekday == state.selectedWeekday) return;
    emit(state.copyWith(selectedWeekday: event.weekday));
  }

  void _onSetCompleted(
    FitnessSetCompleted event,
    Emitter<FitnessState> emit,
  ) {
    final exercise = _findExercise(event.weekday, event.exerciseId);
    if (exercise == null) return;

    final key = FitnessState.composeKey(event.weekday, event.exerciseId);
    final current = state.completedSets[key] ?? 0;
    if (current >= exercise.targetSets) return;

    emit(
      state.copyWith(
        completedSets: {...state.completedSets, key: current + 1},
      ),
    );
  }

  void _onSetUndone(FitnessSetUndone event, Emitter<FitnessState> emit) {
    final key = FitnessState.composeKey(event.weekday, event.exerciseId);
    final current = state.completedSets[key] ?? 0;
    if (current <= 0) return;

    final next = {...state.completedSets};
    if (current - 1 == 0) {
      next.remove(key);
    } else {
      next[key] = current - 1;
    }
    emit(state.copyWith(completedSets: next));
  }

  void _onReset(FitnessReset event, Emitter<FitnessState> emit) {
    emit(state.copyWith(completedSets: const <String, int>{}));
  }

  WorkoutExercise? _findExercise(int weekday, String exerciseId) {
    final day = state.plan.firstWhere(
      (d) => d.weekday == weekday,
      orElse: () => const WorkoutDay(weekday: 0, label: '', exercises: []),
    );
    for (final ex in day.exercises) {
      if (ex.id == exerciseId) return ex;
    }
    return null;
  }
}
