import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/fitness/domain/logged_session.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/domain/set_entry.dart';
import 'package:flutter/foundation.dart';

/// Recorde estimado de um exercicio dentro da sessao — o set concluido
/// de maior carga. Usado pelo resumo pos-treino pra destacar PRs.
@immutable
class ExercisePr extends Equatable {
  const ExercisePr({
    required this.exerciseId,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
  });

  final String exerciseId;
  final String exerciseName;
  final double weightKg;
  final int reps;

  @override
  List<Object?> get props => [exerciseId, exerciseName, weightKg, reps];
}

/// Agregados pos-treino derivados de uma [LoggedSession] finalizada e do
/// [SessionTemplate] que a originou. Toda a aritmetica do resumo (volume,
/// sets, PRs, strain delta, carga por musculo) vive aqui — fora da UI,
/// testavel isoladamente. O nome dos exercicios e resolvido por uma
/// funcao injetada (`nameOf`) pra que o dominio nao dependa do catalogo
/// nem da camada de dados.
@immutable
class SessionSummary extends Equatable {
  factory SessionSummary.fromSession({
    required LoggedSession session,
    required SessionTemplate template,
    required String Function(String exerciseId) nameOf,
  }) {
    var completedSets = 0;
    var totalReps = 0;
    final volumePerMuscle = <MuscleGroup, double>{};
    final prs = <ExercisePr>[];

    for (final entry in session.sets.entries) {
      final exerciseId = entry.key;
      // Set mais pesado concluido do exercicio — candidato a PR.
      SetEntry? heaviest;
      for (final set in entry.value) {
        if (!set.completed) continue;
        completedSets++;
        totalReps += set.reps;
        if (heaviest == null || set.weightKg > heaviest.weightKg) {
          heaviest = set;
        }
      }
      if (heaviest != null) {
        prs.add(
          ExercisePr(
            exerciseId: exerciseId,
            exerciseName: nameOf(exerciseId),
            weightKg: heaviest.weightKg,
            reps: heaviest.reps,
          ),
        );
      }
    }

    // Distribui o volume de cada exercicio pelos grupos musculares
    // planejados — peso integral no primario, fracao nos acessorios,
    // pra que o body diagram leia "o que doi amanha".
    for (final exercise in template.exercises) {
      final logged = session.setsFor(exercise.id);
      if (logged.isEmpty) continue;
      var exerciseVolume = 0.0;
      for (final set in logged) {
        exerciseVolume += set.volumeKg;
      }
      if (exerciseVolume <= 0) continue;
      for (var i = 0; i < exercise.muscleGroups.length; i++) {
        final group = exercise.muscleGroups[i];
        // Primario leva 100%, cada acessorio metade do anterior.
        final share = exerciseVolume * (i == 0 ? 1.0 : 0.5 / i);
        volumePerMuscle[group] = (volumePerMuscle[group] ?? 0) + share;
      }
    }

    // PRs ordenados por carga desc — os mais pesados primeiro no card.
    prs.sort((a, b) => b.weightKg.compareTo(a.weightKg));

    return SessionSummary._(
      session: session,
      templateLabel: template.label,
      focusMuscles: template.focusMuscles,
      completedSets: completedSets,
      totalReps: totalReps,
      totalVolumeKg: session.totalVolumeKg,
      peakStrain: session.peakStrain,
      duration: session.duration ?? Duration.zero,
      programWeek: session.programWeek,
      volumePerMuscle: volumePerMuscle,
      prs: prs,
    );
  }

  const SessionSummary._({
    required this.session,
    required this.templateLabel,
    required this.focusMuscles,
    required this.completedSets,
    required this.totalReps,
    required this.totalVolumeKg,
    required this.peakStrain,
    required this.duration,
    required this.programWeek,
    required this.volumePerMuscle,
    required this.prs,
  });

  final LoggedSession session;
  final String templateLabel;
  final List<MuscleGroup> focusMuscles;
  final int completedSets;
  final int totalReps;
  final double totalVolumeKg;
  final double peakStrain;
  final Duration duration;
  final int programWeek;

  /// Volume estimado (kg) absorvido por grupo muscular — alimenta o
  /// heatmap do body diagram no resumo.
  final Map<MuscleGroup, double> volumePerMuscle;

  /// Recordes da sessao, do mais pesado pro mais leve.
  final List<ExercisePr> prs;

  /// Volume total em toneladas — leitura humana no card hero.
  double get totalVolumeTons => totalVolumeKg / 1000;

  /// Carga estimada que o treino somou ao strain do dia — usa o pico
  /// como proxy, capado em 21 (escala Whoop).
  double get strainDelta => peakStrain.clamp(0, 21).toDouble();

  /// Impacto estimado no recovery do dia seguinte: quanto mais strain,
  /// mais o corpo precisa repor. Mapeado pra uma queda percentual
  /// [0..40] — leitura qualitativa do mock, nao formula clinica.
  double get recoveryImpactPercent => (strainDelta / 21 * 40).clamp(0, 40);

  /// Grupo muscular mais castigado — usado em copy do resumo.
  MuscleGroup? get mostWorkedMuscle {
    MuscleGroup? top;
    var topVolume = 0.0;
    volumePerMuscle.forEach((group, volume) {
      if (volume > topVolume) {
        topVolume = volume;
        top = group;
      }
    });
    return top;
  }

  @override
  List<Object?> get props => [
    session,
    templateLabel,
    focusMuscles,
    completedSets,
    totalReps,
    totalVolumeKg,
    peakStrain,
    duration,
    programWeek,
    volumePerMuscle,
    prs,
  ];
}
