import 'package:bloc_test/bloc_test.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Plano fixo enxuto pra testar o bloc sem depender do catalogo de
  // producao. Inclui um dia com 2 exercicios e um dia de descanso.
  const plan = [
    WorkoutDay(
      weekday: 1,
      label: 'Push',
      exercises: [
        WorkoutExercise(
          id: 'mon-bench',
          name: 'Supino',
          targetSets: 3,
          reps: 10,
          weightKg: 40,
        ),
        WorkoutExercise(
          id: 'mon-tri',
          name: 'Triceps',
          targetSets: 2,
          reps: 12,
          weightKg: 20,
        ),
      ],
    ),
    WorkoutDay(weekday: 2, label: 'Pull', exercises: []),
  ];

  FitnessBloc makeBloc({int today = 1}) =>
      FitnessBloc(plan: plan, today: today);

  group('FitnessBloc', () {
    test('estado inicial: foco em today, completedSets vazio', () {
      final bloc = makeBloc();
      expect(bloc.state.selectedWeekday, 1);
      expect(bloc.state.completedSets, isEmpty);
      expect(bloc.state.weeklyProgress, 0);
      bloc.close();
    });

    test('inicial em dia de descanso pula pro proximo dia com treino', () {
      final bloc = makeBloc(today: 2);
      // Dia 2 do plan e descanso, dia 1 (proximo no rollover) tem treino.
      expect(bloc.state.selectedWeekday, 1);
      bloc.close();
    });

    blocTest<FitnessBloc, FitnessState>(
      'FitnessDaySelected troca o foco',
      build: makeBloc,
      act: (bloc) => bloc.add(const FitnessDaySelected(2)),
      verify: (bloc) => expect(bloc.state.selectedWeekday, 2),
    );

    blocTest<FitnessBloc, FitnessState>(
      'selecionar dia ja em foco eh no-op',
      build: makeBloc,
      act: (bloc) => bloc.add(const FitnessDaySelected(1)),
      expect: () => <FitnessState>[],
    );

    blocTest<FitnessBloc, FitnessState>(
      'FitnessSetCompleted incrementa e bate no targetSets',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-bench'))
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-bench'))
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-bench'))
        // Quarta tentativa deve ser ignorada — alvo e 3.
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-bench')),
      verify: (bloc) {
        expect(bloc.state.completedFor(weekday: 1, exerciseId: 'mon-bench'), 3);
      },
    );

    blocTest<FitnessBloc, FitnessState>(
      'FitnessSetCompleted em exerciseId desconhecido eh no-op',
      build: makeBloc,
      act: (bloc) => bloc.add(
        const FitnessSetCompleted(weekday: 1, exerciseId: 'inexistente'),
      ),
      expect: () => <FitnessState>[],
    );

    blocTest<FitnessBloc, FitnessState>(
      'FitnessSetUndone decrementa e remove a chave em zero',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-bench'))
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-bench'))
        ..add(const FitnessSetUndone(weekday: 1, exerciseId: 'mon-bench'))
        ..add(const FitnessSetUndone(weekday: 1, exerciseId: 'mon-bench')),
      verify: (bloc) {
        expect(bloc.state.completedFor(weekday: 1, exerciseId: 'mon-bench'), 0);
        // Chave nao deve sobrar com valor zero — Equatable confiar em
        // mapas iguais depende disso.
        expect(bloc.state.completedSets, isEmpty);
      },
    );

    blocTest<FitnessBloc, FitnessState>(
      'FitnessSetUndone em zero eh no-op',
      build: makeBloc,
      act: (bloc) =>
          bloc.add(const FitnessSetUndone(weekday: 1, exerciseId: 'mon-bench')),
      expect: () => <FitnessState>[],
    );

    blocTest<FitnessBloc, FitnessState>(
      'FitnessReset zera completedSets',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-bench'))
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-tri'))
        ..add(const FitnessReset()),
      verify: (bloc) => expect(bloc.state.completedSets, isEmpty),
    );

    test('weeklyProgress reflete a razao completed / target', () {
      final bloc = makeBloc()
        // 3 + 2 = 5 sets-alvo na semana inteira (so o dia 1 tem treino).
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-bench'))
        ..add(const FitnessSetCompleted(weekday: 1, exerciseId: 'mon-bench'));

      Future<void>.delayed(Duration.zero).then((_) {
        expect(bloc.state.weeklyTargetSets, 5);
        expect(bloc.state.weeklyCompletedSets, 2);
        expect(bloc.state.weeklyProgress, closeTo(2 / 5, 0.0001));
        bloc.close();
      });
    });
  });
}
