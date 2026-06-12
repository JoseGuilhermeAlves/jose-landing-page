import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_recovery.dart';
import 'package:feature_showcase/src/fitness/domain/sleep_window.dart';
import 'package:flutter/foundation.dart';

/// Snapshot diario de recovery — agrega as biometricas que o mock
/// expoe no dashboard (recovery hero + breakdown). Valores fakos
/// porem coerentes entre si (sleep ruim -> hrv baixo -> recovery
/// baixa).
@immutable
class RecoverySnapshot extends Equatable {
  const RecoverySnapshot({
    required this.date,
    required this.recoveryPercent,
    required this.hrvMs,
    required this.restingHeartRate,
    required this.respiratoryRate,
    required this.sleep,
    required this.muscleRecovery,
  });

  final DateTime date;

  /// 0..100 — a presentation mapeia em banda colorida via
  /// `FitnessBrand.recoveryColor` (domain nao conhece cor).
  final double recoveryPercent;

  /// HRV (Heart Rate Variability) RMSSD em ms.
  final double hrvMs;

  /// Frequencia cardiaca em repouso em bpm.
  final double restingHeartRate;

  /// Frequencia respiratoria em rpm.
  final double respiratoryRate;

  final SleepWindow sleep;
  final MuscleRecovery muscleRecovery;

  @override
  List<Object?> get props => [
    date,
    recoveryPercent,
    hrvMs,
    restingHeartRate,
    respiratoryRate,
    sleep,
    muscleRecovery,
  ];

  @override
  String toString() =>
      'RecoverySnapshot(${date.toIso8601String().substring(0, 10)}, '
      '${recoveryPercent.toStringAsFixed(0)}%)';
}
