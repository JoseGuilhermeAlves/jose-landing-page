import 'dart:async';

import 'package:feature_showcase/src/fitness/data/exercises_catalog.dart';
import 'package:feature_showcase/src/fitness/data/mesocycle_catalog.dart';
import 'package:feature_showcase/src/fitness/data/recovery_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/logged_session.dart';
import 'package:feature_showcase/src/fitness/domain/program.dart';
import 'package:feature_showcase/src/fitness/domain/recovery_snapshot.dart';
import 'package:feature_showcase/src/fitness/domain/rest_timer.dart';
import 'package:feature_showcase/src/fitness/domain/set_entry.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bloc Pulso v2 (dark Whoop). Gerencia mesociclo, snapshot de
/// recovery, strain do dia, sessao de treino logada (set-a-set com
/// RPE) **e o rest timer entre sets** — antes vivia em `setState`
/// local no widget, agora reside aqui como `state.restTimer`.
class FitnessBloc extends Bloc<FitnessEvent, FitnessState> {
  FitnessBloc({
    Program? program,
    List<RecoverySnapshot>? recoveryHistory,
    int? initialDay,
  }) : super(_buildInitial(program, recoveryHistory, initialDay)) {
    on<SessionStarted>(_onSessionStarted);
    on<SetLogged>(_onSetLogged);
    on<ExerciseSwapped>(_onExerciseSwapped);
    on<SessionFinished>(_onSessionFinished);
    on<ProgramDaySelected>(_onProgramDaySelected);
    on<RecoveryHistorySelected>(_onRecoveryHistorySelected);
    on<RecoveryRefreshed>(_onRecoveryRefreshed);
    on<RestStarted>(_onRestStarted);
    on<RestTicked>(_onRestTicked);
    on<RestExtended>(_onRestExtended);
    on<RestSkipped>(_onRestSkipped);
    on<FitnessReset>(_onReset);
  }

  /// Strain contribuido por cada set concluido — abstracao do mock.
  static const double _strainPerSetBaseline = 0.45;

  /// Timer interno do rest. Cancelado/reiniciado pelos handlers.
  /// Override do close pra garantir cleanup mesmo se o consumidor
  /// fechar o bloc com timer ativo.
  Timer? _restTicker;

  @override
  Future<void> close() {
    _restTicker?.cancel();
    _restTicker = null;
    return super.close();
  }

  static FitnessState _buildInitial(
    Program? program,
    List<RecoverySnapshot>? history,
    int? initialDay,
  ) {
    final p = program ?? MesocycleCatalog.build();
    final h = history ?? RecoveryCatalog.history();
    final today = initialDay ?? DateTime.now().weekday;
    return FitnessState(
      program: p,
      recoveryHistory: h,
      strainToday: RecoveryCatalog.strainToday(),
      selectedProgramDay: today,
      recoveryHistoryOffset: 0,
    );
  }

  void _onSessionStarted(SessionStarted event, Emitter<FitnessState> emit) {
    // So bloqueia se ja ha sessao *em andamento*. Uma sessao congelada
    // (finishedAt setado) ja foi arquivada — pode iniciar a proxima.
    if (state.activeSession?.isLive ?? false) return;
    final template = state.program.sessionForToday(event.weekday);
    if (template == null) return;
    final week = state.program.currentWeek;
    final session = LoggedSession(
      id: 'session-${event.now.millisecondsSinceEpoch}',
      templateId: template.id,
      startedAt: event.now,
      programWeek: week?.index ?? 1,
      sets: const {},
      peakStrain: 0,
    );
    emit(
      state.copyWith(
        activeSession: () => session,
        selectedProgramDay: event.weekday,
      ),
    );
  }

  void _onSetLogged(SetLogged event, Emitter<FitnessState> emit) {
    final session = state.activeSession;
    if (session == null) return;
    final existingSets = List<SetEntry>.from(session.setsFor(event.exerciseId));
    final wasCompleted = existingSets.any(
      (s) => s.index == event.setIndex && s.completed,
    );
    var found = false;
    for (var i = 0; i < existingSets.length; i++) {
      if (existingSets[i].index == event.setIndex) {
        existingSets[i] = existingSets[i].copyWith(
          weightKg: event.weightKg,
          reps: event.reps,
          rpe: event.rpe,
          completed: event.completed,
        );
        found = true;
        break;
      }
    }
    if (!found) {
      existingSets
        ..add(
          SetEntry(
            id: '${event.exerciseId}-${event.setIndex}',
            index: event.setIndex,
            weightKg: event.weightKg,
            reps: event.reps,
            rpe: event.rpe,
            completed: event.completed,
          ),
        )
        ..sort((a, b) => a.index.compareTo(b.index));
    }
    final nextSets = Map<String, List<SetEntry>>.from(session.sets);
    nextSets[event.exerciseId] = existingSets;

    final justCompleted = event.completed && !wasCompleted;
    final justUncompleted = !event.completed && wasCompleted;
    final strainDelta = justCompleted
        ? _strainPerSetBaseline * (event.rpe / 7).clamp(0.5, 1.6)
        : justUncompleted
        ? -_strainPerSetBaseline * (event.rpe / 7).clamp(0.5, 1.6)
        : 0.0;
    final nextLifting = (state.strainToday.liftingContribution + strainDelta)
        .clamp(0, 18)
        .toDouble();
    final nextAccumulated = nextLifting + state.strainToday.cardioContribution;
    final nextStrain = state.strainToday.copyWith(
      accumulated: nextAccumulated,
      liftingContribution: nextLifting,
    );
    final nextPeak = nextAccumulated > session.peakStrain
        ? nextAccumulated
        : session.peakStrain;
    emit(
      state.copyWith(
        activeSession: () =>
            session.copyWith(sets: nextSets, peakStrain: nextPeak),
        strainToday: nextStrain,
      ),
    );
  }

  void _onExerciseSwapped(ExerciseSwapped event, Emitter<FitnessState> emit) {
    final replacement = ExercisesCatalog.byId(event.replacementExerciseId);
    if (replacement == null) return;
    final swaps = Map<String, String>.from(state.lastSwaps);
    swaps[event.originalExerciseId] = event.replacementExerciseId;
    final session = state.activeSession;
    var activeFn = () => session;
    if (session != null) {
      final sessionSwaps = Map<String, String>.from(session.swappedExercises);
      sessionSwaps[event.originalExerciseId] = event.replacementExerciseId;
      activeFn = () => session.copyWith(swappedExercises: sessionSwaps);
    }
    emit(state.copyWith(lastSwaps: swaps, activeSession: activeFn));
  }

  void _onSessionFinished(SessionFinished event, Emitter<FitnessState> emit) {
    final session = state.activeSession;
    if (session == null) return;
    _cancelRestTimer();
    final finished = session.copyWith(finishedAt: event.now);
    // Arquiva no historico (mais recente primeiro), substituindo
    // qualquer entrada com o mesmo id pra que finalizar de novo nao
    // duplique. `activeSession` continua apontando pra sessao congelada
    // — o resumo pos-treino le dela e o Today renderiza o CTA de novo
    // so quando uma nova sessao e iniciada.
    final history = [
      finished,
      ...state.completedSessions.where((s) => s.id != finished.id),
    ];
    emit(
      state.copyWith(
        activeSession: () => finished,
        restTimer: () => null,
        completedSessions: history,
      ),
    );
  }

  void _onProgramDaySelected(
    ProgramDaySelected event,
    Emitter<FitnessState> emit,
  ) {
    if (event.weekday == state.selectedProgramDay) return;
    emit(state.copyWith(selectedProgramDay: event.weekday));
  }

  void _onRecoveryHistorySelected(
    RecoveryHistorySelected event,
    Emitter<FitnessState> emit,
  ) {
    if (event.offsetDays == state.recoveryHistoryOffset) return;
    emit(state.copyWith(recoveryHistoryOffset: event.offsetDays));
  }

  void _onRecoveryRefreshed(
    RecoveryRefreshed event,
    Emitter<FitnessState> emit,
  ) {
    emit(state.copyWith(strainToday: state.strainToday.copyWith()));
  }

  void _onRestStarted(RestStarted event, Emitter<FitnessState> emit) {
    // Resetar timer existente — usuario disparou novo descanso.
    _cancelRestTimer();
    final seconds = event.seconds.clamp(1, 999);
    emit(
      state.copyWith(
        restTimer: () => RestTimer(total: seconds, remaining: seconds),
      ),
    );
    _restTicker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const RestTicked()),
    );
  }

  void _onRestTicked(RestTicked event, Emitter<FitnessState> emit) {
    final timer = state.restTimer;
    if (timer == null) return;
    final next = timer.remaining - 1;
    if (next <= 0) {
      _cancelRestTimer();
      emit(state.copyWith(restTimer: () => null));
      return;
    }
    emit(state.copyWith(restTimer: () => timer.copyWith(remaining: next)));
  }

  void _onRestExtended(RestExtended event, Emitter<FitnessState> emit) {
    final timer = state.restTimer;
    if (timer == null) return;
    final nextRemaining = (timer.remaining + event.seconds).clamp(0, 999);
    if (nextRemaining == 0) {
      _cancelRestTimer();
      emit(state.copyWith(restTimer: () => null));
      return;
    }
    final nextTotal = event.seconds > 0
        ? timer.total + event.seconds
        : timer.total;
    emit(
      state.copyWith(
        restTimer: () =>
            timer.copyWith(total: nextTotal, remaining: nextRemaining),
      ),
    );
  }

  void _onRestSkipped(RestSkipped event, Emitter<FitnessState> emit) {
    if (state.restTimer == null) return;
    _cancelRestTimer();
    emit(state.copyWith(restTimer: () => null));
  }

  void _onReset(FitnessReset event, Emitter<FitnessState> emit) {
    _cancelRestTimer();
    emit(
      _buildInitial(
        state.program,
        state.recoveryHistory,
        state.selectedProgramDay,
      ),
    );
  }

  void _cancelRestTimer() {
    _restTicker?.cancel();
    _restTicker = null;
  }
}
