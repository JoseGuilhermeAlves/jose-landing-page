import 'package:feature_showcase/src/domain/workout_day.dart';
import 'package:feature_showcase/src/domain/workout_exercise.dart';
import 'package:feature_showcase/src/presentation/fitness/pulso_body_diagram.dart';

/// Heuristicas compartilhadas pra mapear um exercicio do plano em
/// grupos musculares ativados. Em produto real os grupos seriam
/// atributos do `WorkoutExercise`; aqui inferimos por palavras-chave
/// no nome — suficiente pro mock. Usado por `PulsoHomePage` (musculos
/// do dia) e `ExerciseDetailPage` (musculos do exercicio).
abstract final class MuscleTaxonomy {
  /// Conjunto de grupos ativados por um exercicio individual.
  static Set<MuscleGroup> forExercise(WorkoutExercise ex) {
    final n = ex.name.toLowerCase();
    final groups = <MuscleGroup>{};
    if (n.contains('supino') || n.contains('peit')) {
      groups.add(MuscleGroup.chest);
    }
    if (n.contains('triceps') ||
        n.contains('tríceps') ||
        n.contains('pulley') ||
        n.contains('frances')) {
      groups.add(MuscleGroup.triceps);
    }
    if (n.contains('biceps') || n.contains('bíceps') || n.contains('rosca')) {
      groups.add(MuscleGroup.biceps);
    }
    if (n.contains('puxada') || n.contains('remada') || n.contains('costa')) {
      groups.add(MuscleGroup.back);
    }
    if (n.contains('desenvolv') ||
        n.contains('lateral') ||
        n.contains('ombro')) {
      groups.add(MuscleGroup.shoulders);
    }
    if (n.contains('agachamento') ||
        n.contains('leg press') ||
        n.contains('cadeira ext')) {
      groups.add(MuscleGroup.quads);
    }
    if (n.contains('panturrilha')) {
      groups.add(MuscleGroup.calves);
    }
    if (n.contains('prancha') ||
        n.contains('abdominal') ||
        n.contains('core')) {
      groups.add(MuscleGroup.abs);
    }
    if (n.contains('burpee') ||
        n.contains('kettlebell') ||
        n.contains('remo')) {
      groups
        ..add(MuscleGroup.glutes)
        ..add(MuscleGroup.quads);
    }
    return groups;
  }

  /// Uniao de todos os grupos ativados num dia (varios exercicios).
  static Set<MuscleGroup> forDay(WorkoutDay day) {
    final result = <MuscleGroup>{};
    for (final ex in day.exercises) {
      result.addAll(forExercise(ex));
    }
    return result;
  }

  /// Rotulo curto em pt-br pra exibicao em chips.
  static String label(MuscleGroup m) {
    switch (m) {
      case MuscleGroup.chest:
        return 'peito';
      case MuscleGroup.shoulders:
        return 'ombros';
      case MuscleGroup.biceps:
        return 'bíceps';
      case MuscleGroup.triceps:
        return 'tríceps';
      case MuscleGroup.abs:
        return 'core';
      case MuscleGroup.quads:
        return 'quadríceps';
      case MuscleGroup.calves:
        return 'panturrilha';
      case MuscleGroup.glutes:
        return 'glúteos';
      case MuscleGroup.back:
        return 'costas';
    }
  }
}
