import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';

/// Catalogo estatico de exercicios planejados. Cada entrada referencia
/// grupos musculares canonicos e fornece tempo, descanso e suggested
/// weight. IDs sao usados como chaves nos templates e nos sets logados.
abstract final class ExercisesCatalog {
  static const PlannedExercise benchPress = PlannedExercise(
    id: 'bench-press',
    name: 'Supino reto',
    muscleGroups: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
    ],
    targetSets: 4,
    targetReps: 8,
    suggestedWeightKg: 80,
    tempoSeconds: [2, 1, 2, 1],
    restSeconds: 120,
    alternateIds: ['incline-db-press', 'cable-fly'],
  );

  static const PlannedExercise inclineDbPress = PlannedExercise(
    id: 'incline-db-press',
    name: 'Supino inclinado halter',
    muscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
    targetSets: 3,
    targetReps: 10,
    suggestedWeightKg: 28,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 90,
    alternateIds: ['bench-press', 'cable-fly'],
  );

  static const PlannedExercise overheadPress = PlannedExercise(
    id: 'overhead-press',
    name: 'Desenvolvimento militar',
    muscleGroups: [MuscleGroup.shoulders, MuscleGroup.triceps],
    targetSets: 4,
    targetReps: 6,
    suggestedWeightKg: 50,
    tempoSeconds: [2, 0, 2, 0],
    restSeconds: 120,
    alternateIds: ['lateral-raise', 'incline-db-press'],
  );

  static const PlannedExercise lateralRaise = PlannedExercise(
    id: 'lateral-raise',
    name: 'Elevacao lateral',
    muscleGroups: [MuscleGroup.shoulders],
    targetSets: 3,
    targetReps: 15,
    suggestedWeightKg: 10,
    tempoSeconds: [1, 1, 1, 1],
    restSeconds: 60,
    alternateIds: ['overhead-press'],
  );

  static const PlannedExercise cableFly = PlannedExercise(
    id: 'cable-fly',
    name: 'Crucifixo no cabo',
    muscleGroups: [MuscleGroup.chest],
    targetSets: 3,
    targetReps: 12,
    suggestedWeightKg: 18,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 75,
    alternateIds: ['incline-db-press'],
  );

  static const PlannedExercise tricepPushdown = PlannedExercise(
    id: 'tricep-pushdown',
    name: 'Triceps pulley',
    muscleGroups: [MuscleGroup.triceps],
    targetSets: 3,
    targetReps: 12,
    suggestedWeightKg: 32,
    tempoSeconds: [1, 1, 1, 1],
    restSeconds: 60,
    alternateIds: ['skull-crusher', 'overhead-extension'],
  );

  static const PlannedExercise skullCrusher = PlannedExercise(
    id: 'skull-crusher',
    name: 'Triceps testa',
    muscleGroups: [MuscleGroup.triceps],
    targetSets: 3,
    targetReps: 10,
    suggestedWeightKg: 25,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 75,
    alternateIds: ['tricep-pushdown', 'overhead-extension'],
  );

  static const PlannedExercise overheadExtension = PlannedExercise(
    id: 'overhead-extension',
    name: 'Triceps frances',
    muscleGroups: [MuscleGroup.triceps],
    targetSets: 3,
    targetReps: 12,
    suggestedWeightKg: 22,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 75,
    alternateIds: ['skull-crusher', 'tricep-pushdown'],
  );

  static const PlannedExercise pullUp = PlannedExercise(
    id: 'pull-up',
    name: 'Barra fixa',
    muscleGroups: [MuscleGroup.back, MuscleGroup.biceps],
    targetSets: 4,
    targetReps: 8,
    suggestedWeightKg: 0,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 120,
    alternateIds: ['lat-pulldown', 'barbell-row'],
  );

  static const PlannedExercise latPulldown = PlannedExercise(
    id: 'lat-pulldown',
    name: 'Puxada alta',
    muscleGroups: [MuscleGroup.back, MuscleGroup.biceps],
    targetSets: 3,
    targetReps: 12,
    suggestedWeightKg: 60,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 90,
    alternateIds: ['pull-up', 'cable-row'],
  );

  static const PlannedExercise barbellRow = PlannedExercise(
    id: 'barbell-row',
    name: 'Remada curvada',
    muscleGroups: [MuscleGroup.back, MuscleGroup.biceps],
    targetSets: 4,
    targetReps: 8,
    suggestedWeightKg: 70,
    tempoSeconds: [2, 0, 2, 0],
    restSeconds: 120,
    alternateIds: ['cable-row', 'pull-up'],
  );

  static const PlannedExercise cableRow = PlannedExercise(
    id: 'cable-row',
    name: 'Remada baixa',
    muscleGroups: [MuscleGroup.back, MuscleGroup.biceps],
    targetSets: 3,
    targetReps: 12,
    suggestedWeightKg: 55,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 90,
    alternateIds: ['barbell-row', 'lat-pulldown'],
  );

  static const PlannedExercise facePull = PlannedExercise(
    id: 'face-pull',
    name: 'Face pull',
    muscleGroups: [MuscleGroup.shoulders, MuscleGroup.back],
    targetSets: 3,
    targetReps: 15,
    suggestedWeightKg: 22,
    tempoSeconds: [1, 1, 1, 1],
    restSeconds: 60,
    alternateIds: ['lateral-raise'],
  );

  static const PlannedExercise barbellCurl = PlannedExercise(
    id: 'barbell-curl',
    name: 'Rosca direta',
    muscleGroups: [MuscleGroup.biceps],
    targetSets: 3,
    targetReps: 10,
    suggestedWeightKg: 30,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 75,
    alternateIds: ['hammer-curl', 'preacher-curl'],
  );

  static const PlannedExercise hammerCurl = PlannedExercise(
    id: 'hammer-curl',
    name: 'Rosca martelo',
    muscleGroups: [MuscleGroup.biceps, MuscleGroup.forearms],
    targetSets: 3,
    targetReps: 12,
    suggestedWeightKg: 18,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 60,
    alternateIds: ['barbell-curl', 'preacher-curl'],
  );

  static const PlannedExercise preacherCurl = PlannedExercise(
    id: 'preacher-curl',
    name: 'Rosca scott',
    muscleGroups: [MuscleGroup.biceps],
    targetSets: 3,
    targetReps: 10,
    suggestedWeightKg: 22,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 75,
    alternateIds: ['barbell-curl', 'hammer-curl'],
  );

  static const PlannedExercise backSquat = PlannedExercise(
    id: 'back-squat',
    name: 'Agachamento livre',
    muscleGroups: [MuscleGroup.quads, MuscleGroup.glutes, MuscleGroup.core],
    targetSets: 5,
    targetReps: 5,
    suggestedWeightKg: 110,
    tempoSeconds: [3, 0, 2, 0],
    restSeconds: 180,
    alternateIds: ['leg-press', 'hip-thrust'],
  );

  static const PlannedExercise romanianDeadlift = PlannedExercise(
    id: 'romanian-deadlift',
    name: 'Stiff',
    muscleGroups: [
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.back,
    ],
    targetSets: 4,
    targetReps: 8,
    suggestedWeightKg: 90,
    tempoSeconds: [3, 1, 1, 0],
    restSeconds: 120,
    alternateIds: ['leg-curl', 'hip-thrust'],
  );

  static const PlannedExercise legPress = PlannedExercise(
    id: 'leg-press',
    name: 'Leg press 45',
    muscleGroups: [MuscleGroup.quads, MuscleGroup.glutes],
    targetSets: 4,
    targetReps: 10,
    suggestedWeightKg: 180,
    tempoSeconds: [2, 0, 2, 0],
    restSeconds: 120,
    alternateIds: ['back-squat', 'walking-lunge'],
  );

  static const PlannedExercise walkingLunge = PlannedExercise(
    id: 'walking-lunge',
    name: 'Afundo caminhando',
    muscleGroups: [MuscleGroup.quads, MuscleGroup.glutes],
    targetSets: 3,
    targetReps: 12,
    suggestedWeightKg: 20,
    tempoSeconds: [2, 0, 1, 0],
    restSeconds: 90,
    alternateIds: ['leg-press', 'back-squat'],
  );

  static const PlannedExercise legCurl = PlannedExercise(
    id: 'leg-curl',
    name: 'Flexora deitada',
    muscleGroups: [MuscleGroup.hamstrings],
    targetSets: 3,
    targetReps: 12,
    suggestedWeightKg: 40,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 75,
    alternateIds: ['romanian-deadlift'],
  );

  static const PlannedExercise legExtension = PlannedExercise(
    id: 'leg-extension',
    name: 'Extensora',
    muscleGroups: [MuscleGroup.quads],
    targetSets: 3,
    targetReps: 15,
    suggestedWeightKg: 50,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 60,
    alternateIds: ['leg-press', 'walking-lunge'],
  );

  static const PlannedExercise hipThrust = PlannedExercise(
    id: 'hip-thrust',
    name: 'Hip thrust',
    muscleGroups: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    targetSets: 4,
    targetReps: 10,
    suggestedWeightKg: 100,
    tempoSeconds: [2, 1, 1, 0],
    restSeconds: 120,
    alternateIds: ['romanian-deadlift', 'back-squat'],
  );

  static const PlannedExercise standingCalfRaise = PlannedExercise(
    id: 'standing-calf-raise',
    name: 'Panturrilha em pe',
    muscleGroups: [MuscleGroup.calves],
    targetSets: 4,
    targetReps: 15,
    suggestedWeightKg: 60,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 60,
    alternateIds: [],
  );

  static const PlannedExercise hangingLegRaise = PlannedExercise(
    id: 'hanging-leg-raise',
    name: 'Elevacao de pernas',
    muscleGroups: [MuscleGroup.core],
    targetSets: 3,
    targetReps: 12,
    suggestedWeightKg: 0,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 60,
    alternateIds: ['cable-crunch'],
  );

  static const PlannedExercise cableCrunch = PlannedExercise(
    id: 'cable-crunch',
    name: 'Abdominal no cabo',
    muscleGroups: [MuscleGroup.core],
    targetSets: 3,
    targetReps: 15,
    suggestedWeightKg: 35,
    tempoSeconds: [2, 1, 1, 1],
    restSeconds: 60,
    alternateIds: ['hanging-leg-raise'],
  );

  /// Lista mestra — usada por catalogos derivados e pelo swap sheet.
  static const List<PlannedExercise> all = [
    benchPress,
    inclineDbPress,
    overheadPress,
    lateralRaise,
    cableFly,
    tricepPushdown,
    skullCrusher,
    overheadExtension,
    pullUp,
    latPulldown,
    barbellRow,
    cableRow,
    facePull,
    barbellCurl,
    hammerCurl,
    preacherCurl,
    backSquat,
    romanianDeadlift,
    legPress,
    walkingLunge,
    legCurl,
    legExtension,
    hipThrust,
    standingCalfRaise,
    hangingLegRaise,
    cableCrunch,
  ];

  /// Lookup por ID. Retorna null se nao existir.
  static PlannedExercise? byId(String id) {
    for (final ex in all) {
      if (ex.id == id) return ex;
    }
    return null;
  }

  /// Alternativas validas pro swap sheet — retorna [PlannedExercise]
  /// resolvidos a partir dos ids em `alternateIds` do exercicio dado.
  static List<PlannedExercise> alternatesFor(String exerciseId) {
    final source = byId(exerciseId);
    if (source == null) return const [];
    final out = <PlannedExercise>[];
    for (final id in source.alternateIds) {
      final ex = byId(id);
      if (ex != null) out.add(ex);
    }
    return out;
  }
}
