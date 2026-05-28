import 'package:feature_showcase/src/fitness/data/exercises_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/program.dart';
import 'package:feature_showcase/src/fitness/domain/program_week.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';

/// Catalogo do mesociclo Push/Pull/Legs 8 semanas. Templates fixos
/// (Push A, Pull A, Legs A, Push B, Pull B, Legs B) sao agendados
/// segunda-sabado; domingo descanso. As semanas aplicam progressao
/// linear por multiplicador de intensidade, com deload na semana 8.
abstract final class MesocycleCatalog {
  static const SessionTemplate pushA = SessionTemplate(
    id: 'push-a',
    label: 'Push A',
    weekday: 1,
    focusMuscles: [MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.triceps],
    estimatedMinutes: 65,
    exercises: [
      ExercisesCatalog.benchPress,
      ExercisesCatalog.inclineDbPress,
      ExercisesCatalog.lateralRaise,
      ExercisesCatalog.tricepPushdown,
      ExercisesCatalog.skullCrusher,
    ],
  );

  static const SessionTemplate pullA = SessionTemplate(
    id: 'pull-a',
    label: 'Pull A',
    weekday: 2,
    focusMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    estimatedMinutes: 60,
    exercises: [
      ExercisesCatalog.pullUp,
      ExercisesCatalog.barbellRow,
      ExercisesCatalog.facePull,
      ExercisesCatalog.barbellCurl,
      ExercisesCatalog.hammerCurl,
    ],
  );

  static const SessionTemplate legsA = SessionTemplate(
    id: 'legs-a',
    label: 'Legs A',
    weekday: 3,
    focusMuscles: [MuscleGroup.quads, MuscleGroup.glutes, MuscleGroup.hamstrings],
    estimatedMinutes: 75,
    exercises: [
      ExercisesCatalog.backSquat,
      ExercisesCatalog.romanianDeadlift,
      ExercisesCatalog.walkingLunge,
      ExercisesCatalog.legCurl,
      ExercisesCatalog.standingCalfRaise,
    ],
  );

  static const SessionTemplate pushB = SessionTemplate(
    id: 'push-b',
    label: 'Push B',
    weekday: 4,
    focusMuscles: [MuscleGroup.shoulders, MuscleGroup.chest, MuscleGroup.triceps],
    estimatedMinutes: 60,
    exercises: [
      ExercisesCatalog.overheadPress,
      ExercisesCatalog.cableFly,
      ExercisesCatalog.lateralRaise,
      ExercisesCatalog.overheadExtension,
      ExercisesCatalog.cableCrunch,
    ],
  );

  static const SessionTemplate pullB = SessionTemplate(
    id: 'pull-b',
    label: 'Pull B',
    weekday: 5,
    focusMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    estimatedMinutes: 55,
    exercises: [
      ExercisesCatalog.latPulldown,
      ExercisesCatalog.cableRow,
      ExercisesCatalog.facePull,
      ExercisesCatalog.preacherCurl,
      ExercisesCatalog.hangingLegRaise,
    ],
  );

  static const SessionTemplate legsB = SessionTemplate(
    id: 'legs-b',
    label: 'Legs B',
    weekday: 6,
    focusMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings, MuscleGroup.quads],
    estimatedMinutes: 70,
    exercises: [
      ExercisesCatalog.hipThrust,
      ExercisesCatalog.legPress,
      ExercisesCatalog.legExtension,
      ExercisesCatalog.legCurl,
      ExercisesCatalog.standingCalfRaise,
    ],
  );

  static const List<SessionTemplate> _allTemplates = [
    pushA,
    pullA,
    legsA,
    pushB,
    pullB,
    legsB,
  ];

  /// Multiplicador de intensidade por semana — progressao linear ate
  /// a semana 7, deload na 8.
  static const List<double> _intensityCurve = [
    1.00, // S1 acumulacao
    1.025, // S2 acumulacao
    1.05, // S3 acumulacao
    1.075, // S4 acumulacao
    1.10, // S5 intensificacao
    1.125, // S6 intensificacao
    1.15, // S7 peak
    0.85, // S8 deload
  ];

  /// Strain prescrito por semana (escala 0–21 logaritmica).
  static const List<double> _strainCurve = [
    12.0,
    13.0,
    14.0,
    14.5,
    15.5,
    16.5,
    17.5,
    9.5,
  ];

  static const List<String> _weekLabels = [
    'Acumulacao 1',
    'Acumulacao 2',
    'Acumulacao 3',
    'Acumulacao 4',
    'Intensificacao 1',
    'Intensificacao 2',
    'Peak',
    'Deload',
  ];

  /// Constroi o programa de 8 semanas com a semana ativa indicada.
  /// [currentWeekIndex] e 1-based; default 3 cai num meio realista
  /// pra demo (acumulacao avancada).
  static Program build({int currentWeekIndex = 3}) {
    final weeks = <ProgramWeek>[];
    for (var i = 0; i < 8; i++) {
      weeks.add(
        ProgramWeek(
          index: i + 1,
          label: _weekLabels[i],
          intensityMultiplier: _intensityCurve[i],
          targetStrain: _strainCurve[i],
          sessions: _allTemplates,
          isDeload: i == 7,
        ),
      );
    }
    return Program(
      id: 'hypertrophy-ppl-8w',
      name: 'Hipertrofia PPL · 8 semanas',
      tagline: 'Push / Pull / Legs · 6x na semana',
      weeks: weeks,
      currentWeekIndex: currentWeekIndex,
    );
  }
}
