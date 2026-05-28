import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:flutter/foundation.dart';

/// Snapshot de recovery por grupo muscular. Valor [0..100] onde 100 =
/// recuperado, 0 = trashed. Usado pra desenhar heatmap no body diagram
/// e sugerir treino do dia.
@immutable
class MuscleRecovery extends Equatable {
  const MuscleRecovery({required this.scores});

  /// Mapa muscleGroup -> percentual recuperado.
  final Map<MuscleGroup, double> scores;

  double scoreFor(MuscleGroup group) => scores[group] ?? 100;

  /// Media simples dos grupos rastreados — uso em headlines.
  double get average {
    if (scores.isEmpty) return 100;
    var sum = 0.0;
    for (final v in scores.values) {
      sum += v;
    }
    return sum / scores.length;
  }

  /// Lista grupos abaixo do limiar — UI sugere evitar.
  List<MuscleGroup> belowThreshold([double threshold = 50]) {
    final out = <MuscleGroup>[];
    scores.forEach((g, v) {
      if (v < threshold) out.add(g);
    });
    return out;
  }

  @override
  List<Object?> get props => [scores];

  @override
  String toString() => 'MuscleRecovery(avg ${average.toStringAsFixed(0)}%)';
}
