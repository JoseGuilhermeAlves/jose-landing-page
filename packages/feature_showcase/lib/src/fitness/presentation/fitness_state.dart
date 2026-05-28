import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/fitness/domain/logged_session.dart';
import 'package:feature_showcase/src/fitness/domain/program.dart';
import 'package:feature_showcase/src/fitness/domain/recovery_snapshot.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/domain/set_entry.dart';
import 'package:feature_showcase/src/fitness/domain/strain_score.dart';
import 'package:flutter/foundation.dart';

/// Estado raiz do mock Pulso dark Whoop. Substitui o estado antigo
/// (plan + completedSets map) por agregacao de program (mesociclo),
/// recovery history e session ativa.
@immutable
class FitnessState extends Equatable {
  const FitnessState({
    required this.program,
    required this.recoveryHistory,
    required this.strainToday,
    required this.selectedProgramDay,
    required this.recoveryHistoryOffset,
    this.activeSession,
    this.lastSwaps = const {},
  });

  /// Mesociclo carregado do catalogo.
  final Program program;

  /// 7 ultimos dias (incluindo hoje em `last`).
  final List<RecoverySnapshot> recoveryHistory;

  /// Strain corrente do dia (target + accumulated + breakdown).
  final StrainScore strainToday;

  /// Dia em foco no ProgramPage (1..7). Default = hoje.
  final int selectedProgramDay;

  /// Offset em dias selecionado no timeline do RecoveryPage. 0 = hoje,
  /// -1 = ontem... ate -6.
  final int recoveryHistoryOffset;

  /// Sessao em execucao ou recem-finalizada. Quando null, atleta
  /// nao iniciou o treino do dia.
  final LoggedSession? activeSession;

  /// Mapa de swaps mantido em nivel global pra que tela de detalhe
  /// e session logger compartilhem mesmo conjunto. Chave = id
  /// original, valor = id substituto.
  final Map<String, String> lastSwaps;

  /// Snapshot do dia mais recente — usado no hero do TodayPage.
  RecoverySnapshot get todaySnapshot => recoveryHistory.last;

  /// Snapshot selecionado pelo timeline do RecoveryPage. Cai em hoje
  /// se offset nao bater.
  RecoverySnapshot get selectedRecoverySnapshot {
    if (recoveryHistory.isEmpty) return todaySnapshot;
    final idx = recoveryHistory.length - 1 + recoveryHistoryOffset;
    if (idx < 0) return recoveryHistory.first;
    if (idx >= recoveryHistory.length) return todaySnapshot;
    return recoveryHistory[idx];
  }

  /// Sessao planejada pra hoje (segundo o dia do programa). Pode ser
  /// null em descanso.
  SessionTemplate? get todaysTemplate {
    final week = program.currentWeek;
    if (week == null) return null;
    return week.sessionFor(selectedProgramDay);
  }

  /// Aplica o multiplicador da semana atual sobre o
  /// `suggestedWeightKg` original, devolvendo carga prescrita.
  double prescribedWeightFor(String exerciseId) {
    final template = todaysTemplate;
    final week = program.currentWeek;
    if (template == null || week == null) return 0;
    for (final ex in template.exercises) {
      if (ex.id == exerciseId) {
        return (ex.suggestedWeightKg * week.intensityMultiplier)
            .roundToDouble();
      }
    }
    return 0;
  }

  /// ID efetivo do exercicio considerando swaps aplicados.
  String effectiveExerciseId(String originalId) =>
      lastSwaps[originalId] ?? originalId;

  /// Sets logados (concluidos ou nao) do exercicio no contexto da
  /// sessao ativa.
  List<SetEntry> setsFor(String exerciseId) {
    final session = activeSession;
    if (session == null) return const [];
    return session.setsFor(exerciseId);
  }

  int completedSetsFor(String exerciseId) {
    final session = activeSession;
    if (session == null) return 0;
    return session.completedFor(exerciseId);
  }

  /// Quantos exercicios da sessao ativa ja estao com todos os sets
  /// concluidos. Usado pra progressbar no header do SessionLogger.
  int get exercisesCompleted {
    final session = activeSession;
    final template = todaysTemplate;
    if (session == null || template == null) return 0;
    var done = 0;
    for (final ex in template.exercises) {
      final effective = effectiveExerciseId(ex.id);
      if (session.completedFor(effective) >= ex.targetSets) done++;
    }
    return done;
  }

  /// Volume total da sessao ativa.
  double get activeVolumeKg {
    final session = activeSession;
    if (session == null) return 0;
    return session.totalVolumeKg;
  }

  FitnessState copyWith({
    Program? program,
    List<RecoverySnapshot>? recoveryHistory,
    StrainScore? strainToday,
    int? selectedProgramDay,
    int? recoveryHistoryOffset,
    LoggedSession? Function()? activeSession,
    Map<String, String>? lastSwaps,
  }) {
    return FitnessState(
      program: program ?? this.program,
      recoveryHistory: recoveryHistory ?? this.recoveryHistory,
      strainToday: strainToday ?? this.strainToday,
      selectedProgramDay: selectedProgramDay ?? this.selectedProgramDay,
      recoveryHistoryOffset:
          recoveryHistoryOffset ?? this.recoveryHistoryOffset,
      activeSession: activeSession != null
          ? activeSession()
          : this.activeSession,
      lastSwaps: lastSwaps ?? this.lastSwaps,
    );
  }

  @override
  List<Object?> get props => [
    program,
    recoveryHistory,
    strainToday,
    selectedProgramDay,
    recoveryHistoryOffset,
    activeSession,
    lastSwaps,
  ];
}
