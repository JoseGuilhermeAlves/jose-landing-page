import 'package:feature_showcase/src/fitness/domain/workout_day.dart';
import 'package:feature_showcase/src/fitness/domain/workout_exercise.dart';

/// Plano de treino mock pro demo de fitness. 5 dias com treinos +
/// 2 dias de descanso. Cargas e reps escolhidos pra parecer com um
/// plano de academia regular sem prescrever nada — e mock.
abstract final class WorkoutPlanCatalog {
  /// Plano da semana — segunda a domingo. Indexado em ordem do
  /// `DateTime.weekday` (1..7).
  static const List<WorkoutDay> week = [
    WorkoutDay(
      weekday: 1,
      label: 'Peito e triceps',
      exercises: [
        WorkoutExercise(
          id: 'mon-bench',
          name: 'Supino reto',
          targetSets: 4,
          reps: 8,
          weightKg: 60,
        ),
        WorkoutExercise(
          id: 'mon-incline',
          name: 'Supino inclinado',
          targetSets: 3,
          reps: 10,
          weightKg: 50,
        ),
        WorkoutExercise(
          id: 'mon-pushdown',
          name: 'Triceps pulley',
          targetSets: 3,
          reps: 12,
          weightKg: 30,
        ),
        WorkoutExercise(
          id: 'mon-french',
          name: 'Triceps frances',
          targetSets: 3,
          reps: 12,
          weightKg: 18,
        ),
      ],
    ),
    WorkoutDay(
      weekday: 2,
      label: 'Costas e biceps',
      exercises: [
        WorkoutExercise(
          id: 'tue-pulldown',
          name: 'Puxada alta',
          targetSets: 4,
          reps: 10,
          weightKg: 55,
        ),
        WorkoutExercise(
          id: 'tue-row',
          name: 'Remada baixa',
          targetSets: 3,
          reps: 10,
          weightKg: 50,
        ),
        WorkoutExercise(
          id: 'tue-curl',
          name: 'Rosca direta',
          targetSets: 3,
          reps: 12,
          weightKg: 16,
        ),
        WorkoutExercise(
          id: 'tue-hammer',
          name: 'Rosca martelo',
          targetSets: 3,
          reps: 12,
          weightKg: 14,
        ),
      ],
    ),
    WorkoutDay(
      weekday: 3,
      label: 'Pernas',
      exercises: [
        WorkoutExercise(
          id: 'wed-squat',
          name: 'Agachamento livre',
          targetSets: 4,
          reps: 8,
          weightKg: 80,
        ),
        WorkoutExercise(
          id: 'wed-leg-press',
          name: 'Leg press 45',
          targetSets: 3,
          reps: 12,
          weightKg: 140,
        ),
        WorkoutExercise(
          id: 'wed-extension',
          name: 'Cadeira extensora',
          targetSets: 3,
          reps: 15,
          weightKg: 40,
        ),
        WorkoutExercise(
          id: 'wed-calf',
          name: 'Panturrilha em pe',
          targetSets: 4,
          reps: 15,
          weightKg: 60,
        ),
      ],
    ),
    WorkoutDay(
      weekday: 4,
      label: 'Descanso',
      exercises: [],
    ),
    WorkoutDay(
      weekday: 5,
      label: 'Ombros e core',
      exercises: [
        WorkoutExercise(
          id: 'fri-press',
          name: 'Desenvolvimento halteres',
          targetSets: 4,
          reps: 10,
          weightKg: 18,
        ),
        WorkoutExercise(
          id: 'fri-lateral',
          name: 'Elevacao lateral',
          targetSets: 3,
          reps: 12,
          weightKg: 8,
        ),
        WorkoutExercise(
          id: 'fri-plank',
          name: 'Prancha (45s)',
          targetSets: 3,
          reps: 1,
          weightKg: 0,
        ),
        WorkoutExercise(
          id: 'fri-ab',
          name: 'Abdominal infra',
          targetSets: 3,
          reps: 15,
          weightKg: 0,
        ),
      ],
    ),
    WorkoutDay(
      weekday: 6,
      label: 'Funcional / cardio',
      exercises: [
        WorkoutExercise(
          id: 'sat-burpee',
          name: 'Burpees',
          targetSets: 4,
          reps: 12,
          weightKg: 0,
        ),
        WorkoutExercise(
          id: 'sat-kb',
          name: 'Kettlebell swing',
          targetSets: 4,
          reps: 15,
          weightKg: 16,
        ),
        WorkoutExercise(
          id: 'sat-row',
          name: 'Remo ergometro (1km)',
          targetSets: 2,
          reps: 1,
          weightKg: 0,
        ),
      ],
    ),
    WorkoutDay(
      weekday: 7,
      label: 'Descanso',
      exercises: [],
    ),
  ];
}
