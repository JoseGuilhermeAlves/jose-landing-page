import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_recovery.dart';
import 'package:feature_showcase/src/fitness/domain/recovery_snapshot.dart';
import 'package:feature_showcase/src/fitness/domain/sleep_window.dart';
import 'package:feature_showcase/src/fitness/domain/strain_score.dart';

/// Catalogo de recovery — 7 dias passados + hoje. Valores fabricados
/// porem coerentes (sleep ruim leva a HRV baixo e recovery menor).
/// Usado pra preencher dashboard, grafico de strain history e heatmap
/// muscular.
abstract final class RecoveryCatalog {
  /// Snapshots ordenados do mais antigo (dia -6) ao mais recente (hoje).
  /// [referenceDate] permite testes deterministicos; default = `DateTime.now()`.
  static List<RecoverySnapshot> history({DateTime? referenceDate}) {
    final today = referenceDate ?? DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final samples = <_Sample>[
      const _Sample(
        offsetDays: -6,
        recovery: 72,
        hrv: 58,
        rhr: 52,
        respiratory: 14.5,
        bedHour: 23,
        bedMin: 15,
        wakeHour: 6,
        wakeMin: 45,
        sleepEff: 89,
        muscles: {
          MuscleGroup.chest: 78,
          MuscleGroup.back: 65,
          MuscleGroup.quads: 70,
          MuscleGroup.hamstrings: 75,
          MuscleGroup.glutes: 72,
          MuscleGroup.shoulders: 82,
          MuscleGroup.biceps: 80,
          MuscleGroup.triceps: 78,
          MuscleGroup.core: 85,
        },
      ),
      const _Sample(
        offsetDays: -5,
        recovery: 65,
        hrv: 52,
        rhr: 54,
        respiratory: 14.8,
        bedHour: 23,
        bedMin: 50,
        wakeHour: 6,
        wakeMin: 30,
        sleepEff: 84,
        muscles: {
          MuscleGroup.chest: 55,
          MuscleGroup.back: 72,
          MuscleGroup.quads: 60,
          MuscleGroup.hamstrings: 68,
          MuscleGroup.glutes: 62,
          MuscleGroup.shoulders: 50,
          MuscleGroup.biceps: 65,
          MuscleGroup.triceps: 48,
          MuscleGroup.core: 80,
        },
      ),
      const _Sample(
        offsetDays: -4,
        recovery: 58,
        hrv: 47,
        rhr: 56,
        respiratory: 15.2,
        bedHour: 0,
        bedMin: 35,
        wakeHour: 6,
        wakeMin: 50,
        sleepEff: 79,
        muscles: {
          MuscleGroup.chest: 48,
          MuscleGroup.back: 42,
          MuscleGroup.quads: 38,
          MuscleGroup.hamstrings: 45,
          MuscleGroup.glutes: 40,
          MuscleGroup.shoulders: 55,
          MuscleGroup.biceps: 50,
          MuscleGroup.triceps: 45,
          MuscleGroup.core: 68,
        },
      ),
      const _Sample(
        offsetDays: -3,
        recovery: 81,
        hrv: 64,
        rhr: 51,
        respiratory: 14.2,
        bedHour: 22,
        bedMin: 45,
        wakeHour: 7,
        wakeMin: 10,
        sleepEff: 93,
        muscles: {
          MuscleGroup.chest: 88,
          MuscleGroup.back: 78,
          MuscleGroup.quads: 72,
          MuscleGroup.hamstrings: 80,
          MuscleGroup.glutes: 75,
          MuscleGroup.shoulders: 90,
          MuscleGroup.biceps: 85,
          MuscleGroup.triceps: 88,
          MuscleGroup.core: 92,
        },
      ),
      const _Sample(
        offsetDays: -2,
        recovery: 75,
        hrv: 60,
        rhr: 52,
        respiratory: 14.4,
        bedHour: 23,
        bedMin: 20,
        wakeHour: 6,
        wakeMin: 55,
        sleepEff: 90,
        muscles: {
          MuscleGroup.chest: 70,
          MuscleGroup.back: 82,
          MuscleGroup.quads: 50,
          MuscleGroup.hamstrings: 55,
          MuscleGroup.glutes: 52,
          MuscleGroup.shoulders: 75,
          MuscleGroup.biceps: 78,
          MuscleGroup.triceps: 72,
          MuscleGroup.core: 85,
        },
      ),
      const _Sample(
        offsetDays: -1,
        recovery: 68,
        hrv: 55,
        rhr: 53,
        respiratory: 14.6,
        bedHour: 23,
        bedMin: 35,
        wakeHour: 6,
        wakeMin: 50,
        sleepEff: 86,
        muscles: {
          MuscleGroup.chest: 62,
          MuscleGroup.back: 58,
          MuscleGroup.quads: 42,
          MuscleGroup.hamstrings: 48,
          MuscleGroup.glutes: 45,
          MuscleGroup.shoulders: 68,
          MuscleGroup.biceps: 70,
          MuscleGroup.triceps: 65,
          MuscleGroup.core: 78,
        },
      ),
      const _Sample(
        offsetDays: 0,
        recovery: 79,
        hrv: 62,
        rhr: 51,
        respiratory: 14.3,
        bedHour: 23,
        bedMin: 5,
        wakeHour: 6,
        wakeMin: 55,
        sleepEff: 92,
        muscles: {
          MuscleGroup.chest: 75,
          MuscleGroup.back: 70,
          MuscleGroup.quads: 82,
          MuscleGroup.hamstrings: 78,
          MuscleGroup.glutes: 80,
          MuscleGroup.shoulders: 72,
          MuscleGroup.biceps: 76,
          MuscleGroup.triceps: 74,
          MuscleGroup.core: 88,
        },
      ),
    ];
    return samples.map((s) => s.toSnapshot(base)).toList(growable: false);
  }

  /// Snapshot do dia atual.
  static RecoverySnapshot today({DateTime? referenceDate}) =>
      history(referenceDate: referenceDate).last;

  /// Strain de hoje — accumulated parcial, fica perto do target.
  static StrainScore strainToday() {
    return const StrainScore(
      target: 14.2,
      accumulated: 6.8,
      cardioContribution: 1.4,
      liftingContribution: 5.4,
    );
  }

  /// Strain dos ultimos 7 dias (incluindo hoje) — usado pelo grafico
  /// historico no RecoveryPage.
  static List<double> strainHistory() {
    return const [10.5, 13.8, 16.2, 9.8, 14.6, 15.4, 6.8];
  }
}

class _Sample {
  const _Sample({
    required this.offsetDays,
    required this.recovery,
    required this.hrv,
    required this.rhr,
    required this.respiratory,
    required this.bedHour,
    required this.bedMin,
    required this.wakeHour,
    required this.wakeMin,
    required this.sleepEff,
    required this.muscles,
  });

  final int offsetDays;
  final double recovery;
  final double hrv;
  final double rhr;
  final double respiratory;
  final int bedHour;
  final int bedMin;
  final int wakeHour;
  final int wakeMin;
  final double sleepEff;
  final Map<MuscleGroup, double> muscles;

  RecoverySnapshot toSnapshot(DateTime today) {
    final date = today.add(Duration(days: offsetDays));
    // bedAt na noite anterior se a hora de deitar e <12.
    final bedAt = bedHour < 12
        ? DateTime(date.year, date.month, date.day, bedHour, bedMin)
        : DateTime(date.year, date.month, date.day - 1, bedHour, bedMin);
    final wakeAt = DateTime(date.year, date.month, date.day, wakeHour, wakeMin);
    // Distribuicao tipica de fases de sono — soma ~100.
    final sleep = SleepWindow(
      bedAt: bedAt,
      wakeAt: wakeAt,
      efficiencyPercent: sleepEff,
      deepPercent: 18 + (recovery / 10),
      remPercent: 22 + (hrv / 25),
      lightPercent: 50,
      awakePercent: 8 - (sleepEff / 25),
    );
    return RecoverySnapshot(
      date: date,
      recoveryPercent: recovery,
      hrvMs: hrv,
      restingHeartRate: rhr,
      respiratoryRate: respiratory,
      sleep: sleep,
      muscleRecovery: MuscleRecovery(scores: muscles),
    );
  }
}
