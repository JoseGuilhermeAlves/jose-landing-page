import 'package:bloc_test/bloc_test.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FitnessBloc', () {
    final fixedNow = DateTime(2026, 5, 28, 9);

    test('estado inicial carrega programa e historico de recovery', () {
      final bloc = FitnessBloc();
      expect(bloc.state.program.weeks.length, 8);
      expect(bloc.state.recoveryHistory.length, 7);
      expect(bloc.state.activeSession, isNull);
      expect(bloc.state.strainToday.target, greaterThan(0));
      bloc.close();
    });

    blocTest<FitnessBloc, FitnessState>(
      'SessionStarted abre sessao ativa pro template do dia',
      build: FitnessBloc.new,
      act: (bloc) => bloc.add(SessionStarted(weekday: 1, now: fixedNow)),
      verify: (bloc) {
        final session = bloc.state.activeSession;
        expect(session, isNotNull);
        expect(session!.templateId, equals('push-a'));
        expect(session.isLive, isTrue);
      },
    );

    blocTest<FitnessBloc, FitnessState>(
      'SessionStarted segunda vez e no-op',
      build: FitnessBloc.new,
      seed: () {
        final bloc = FitnessBloc();
        bloc.add(SessionStarted(weekday: 1, now: fixedNow));
        return bloc.state.copyWith(
          activeSession: () => bloc.state.activeSession,
        );
      },
      act: (bloc) {
        bloc.add(SessionStarted(weekday: 1, now: fixedNow));
        bloc.add(
          SessionStarted(
            weekday: 1,
            now: fixedNow.add(const Duration(seconds: 5)),
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.activeSession, isNotNull);
      },
    );

    blocTest<FitnessBloc, FitnessState>(
      'SetLogged adiciona set concluido e move strain accumulator',
      build: FitnessBloc.new,
      act: (bloc) async {
        bloc.add(SessionStarted(weekday: 1, now: fixedNow));
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          const SetLogged(
            exerciseId: 'bench-press',
            setIndex: 1,
            weightKg: 80,
            reps: 8,
            rpe: 7.5,
            completed: true,
          ),
        );
      },
      verify: (bloc) {
        final session = bloc.state.activeSession!;
        final sets = session.setsFor('bench-press');
        expect(sets.length, 1);
        expect(sets.first.completed, isTrue);
        expect(sets.first.weightKg, 80);
        expect(sets.first.reps, 8);
        expect(session.completedSetsCount, 1);
        expect(bloc.state.strainToday.liftingContribution, greaterThan(5.4));
      },
    );

    blocTest<FitnessBloc, FitnessState>(
      'SetLogged desfazendo set decrementa strain accumulator',
      build: FitnessBloc.new,
      act: (bloc) async {
        bloc.add(SessionStarted(weekday: 1, now: fixedNow));
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          const SetLogged(
            exerciseId: 'bench-press',
            setIndex: 1,
            weightKg: 80,
            reps: 8,
            rpe: 7.5,
            completed: true,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          const SetLogged(
            exerciseId: 'bench-press',
            setIndex: 1,
            weightKg: 80,
            reps: 8,
            rpe: 7.5,
            completed: false,
          ),
        );
      },
      verify: (bloc) {
        final session = bloc.state.activeSession!;
        expect(session.completedSetsCount, 0);
      },
    );

    blocTest<FitnessBloc, FitnessState>(
      'ExerciseSwapped registra swap no state global',
      build: FitnessBloc.new,
      act: (bloc) => bloc.add(
        const ExerciseSwapped(
          originalExerciseId: 'bench-press',
          replacementExerciseId: 'incline-db-press',
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.lastSwaps['bench-press'], 'incline-db-press');
        expect(
          bloc.state.effectiveExerciseId('bench-press'),
          'incline-db-press',
        );
      },
    );

    blocTest<FitnessBloc, FitnessState>(
      'SessionFinished congela finishedAt',
      build: FitnessBloc.new,
      act: (bloc) async {
        bloc.add(SessionStarted(weekday: 1, now: fixedNow));
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          SessionFinished(now: fixedNow.add(const Duration(minutes: 60))),
        );
      },
      verify: (bloc) {
        final session = bloc.state.activeSession!;
        expect(session.finishedAt, isNotNull);
        expect(session.duration, const Duration(minutes: 60));
        expect(session.isLive, isFalse);
      },
    );

    blocTest<FitnessBloc, FitnessState>(
      'ProgramDaySelected atualiza foco',
      build: FitnessBloc.new,
      act: (bloc) => bloc.add(const ProgramDaySelected(3)),
      verify: (bloc) => expect(bloc.state.selectedProgramDay, 3),
    );

    blocTest<FitnessBloc, FitnessState>(
      'RecoveryHistorySelected atualiza offset',
      build: FitnessBloc.new,
      act: (bloc) => bloc.add(const RecoveryHistorySelected(-3)),
      verify: (bloc) => expect(bloc.state.recoveryHistoryOffset, -3),
    );

    test(
      'state.prescribedWeightFor aplica multiplicador da semana atual',
      () async {
        final bloc = FitnessBloc()..add(const ProgramDaySelected(1));
        await Future<void>.delayed(Duration.zero);
        final week = bloc.state.program.currentWeek!;
        final base =
            ExercisesCatalog.benchPress.suggestedWeightKg *
            week.intensityMultiplier;
        expect(
          bloc.state.prescribedWeightFor('bench-press'),
          base.roundToDouble(),
        );
        await bloc.close();
      },
    );

    test('FitnessReset volta ao estado inicial', () async {
      final bloc = FitnessBloc()
        ..add(SessionStarted(weekday: 1, now: fixedNow));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const FitnessReset());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.activeSession, isNull);
      bloc.close();
    });
  });

  group('MesocycleCatalog', () {
    test('build retorna programa com 8 semanas e deload na ultima', () {
      final program = MesocycleCatalog.build();
      expect(program.weeks.length, 8);
      expect(program.weeks.first.isDeload, isFalse);
      expect(program.weeks.last.isDeload, isTrue);
      expect(program.weeks.last.intensityMultiplier, lessThan(1));
    });

    test('templates cobrem segunda a sabado', () {
      final program = MesocycleCatalog.build();
      final firstWeek = program.weeks.first;
      for (var d = 1; d <= 6; d++) {
        expect(firstWeek.sessionFor(d), isNotNull, reason: 'dia $d');
      }
      expect(firstWeek.sessionFor(7), isNull, reason: 'domingo descanso');
    });
  });

  group('ExercisesCatalog', () {
    test('alternatesFor resolve ids validos', () {
      final alt = ExercisesCatalog.alternatesFor('bench-press');
      expect(alt, isNotEmpty);
      expect(alt.map((e) => e.id), contains('incline-db-press'));
    });

    test('alternatesFor exercicio inexistente retorna lista vazia', () {
      expect(ExercisesCatalog.alternatesFor('does-not-exist'), isEmpty);
    });
  });
}
