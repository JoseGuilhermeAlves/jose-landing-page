import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/fitness/domain/logged_session.dart' show LoggedSession;
import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/set_entry.dart' show SetEntry;
import 'package:flutter/foundation.dart';

/// Exercicio planejado dentro de um template de sessao. Imutavel —
/// representa o "plano" (sets alvo, reps alvo, carga sugerida), nao
/// o executado. O executado vive em [SetEntry] dentro da
/// [LoggedSession].
@immutable
class PlannedExercise extends Equatable {
  const PlannedExercise({
    required this.id,
    required this.name,
    required this.muscleGroups,
    required this.targetSets,
    required this.targetReps,
    required this.suggestedWeightKg,
    this.tempoSeconds = const [2, 1, 2, 1],
    this.restSeconds = 90,
    this.alternateIds = const [],
  });

  /// Identificador estavel do exercicio (`bench-press`, `barbell-row`).
  final String id;

  final String name;

  /// Musculos trabalhados — ordenados do primario pro acessorio.
  final List<MuscleGroup> muscleGroups;

  final int targetSets;
  final int targetReps;

  /// Carga sugerida pra primeira semana do mesociclo. Progressao
  /// semanal e calculada no catalogo.
  final double suggestedWeightKg;

  /// Tempo em segundos [eccentric, pausa baixo, concentric, pausa alto].
  /// Default 2-1-2-1 = tempo classico hipertrofia.
  final List<int> tempoSeconds;

  /// Descanso sugerido entre sets em segundos.
  final int restSeconds;

  /// IDs de exercicios alternativos validos (mesma cadeia muscular).
  /// Usado pelo swap sheet.
  final List<String> alternateIds;

  /// Grupo muscular primario — primeiro da lista.
  MuscleGroup get primaryMuscle => muscleGroups.first;

  @override
  List<Object?> get props => [
    id,
    name,
    muscleGroups,
    targetSets,
    targetReps,
    suggestedWeightKg,
    tempoSeconds,
    restSeconds,
    alternateIds,
  ];

  @override
  String toString() => 'PlannedExercise($id, $targetSets x $targetReps)';
}

/// Template de sessao (Push A, Pull B, Legs A...). Define o que foi
/// planejado pra um dia especifico do mesociclo. Independente da
/// semana — a progressao de carga e aplicada por cima quando a
/// sessao e instanciada.
@immutable
class SessionTemplate extends Equatable {
  const SessionTemplate({
    required this.id,
    required this.label,
    required this.weekday,
    required this.focusMuscles,
    required this.exercises,
    required this.estimatedMinutes,
  });

  /// `push-a`, `pull-a`, `legs-a`, `push-b`, `pull-b`, etc.
  final String id;

  /// Nome curto exibido em chips e cards: "Push A", "Pull A".
  final String label;

  /// Dia da semana sugerido (1 = segunda, 7 = domingo, 0 = livre).
  final int weekday;

  /// Musculos primarios da sessao — usado em copy e icones.
  final List<MuscleGroup> focusMuscles;

  final List<PlannedExercise> exercises;

  /// Duracao estimada da sessao em minutos — calculada offline,
  /// considera sets, reps e descanso.
  final int estimatedMinutes;

  bool get isRest => exercises.isEmpty;

  int get totalTargetSets => exercises.fold(0, (acc, e) => acc + e.targetSets);

  @override
  List<Object?> get props => [
    id,
    label,
    weekday,
    focusMuscles,
    exercises,
    estimatedMinutes,
  ];

  @override
  String toString() => 'SessionTemplate($id, $label, ${exercises.length} ex)';
}
