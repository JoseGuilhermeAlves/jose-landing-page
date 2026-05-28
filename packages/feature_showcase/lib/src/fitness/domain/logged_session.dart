import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/fitness/domain/set_entry.dart';
import 'package:flutter/foundation.dart';

/// Sessao executada (ou em execucao). Substitui o conceito antigo
/// de "completedSets map" — agora cada set vive como [SetEntry] com
/// peso, reps e RPE registrados. Quando [finishedAt] e null, a
/// sessao esta em andamento.
@immutable
class LoggedSession extends Equatable {
  const LoggedSession({
    required this.id,
    required this.templateId,
    required this.startedAt,
    required this.programWeek,
    required this.sets,
    required this.peakStrain,
    this.finishedAt,
    this.swappedExercises = const {},
  });

  /// `session-2026-05-28-push-a`.
  final String id;

  /// ID do [SessionTemplate] que originou a sessao.
  final String templateId;

  /// Semana do mesociclo em que a sessao foi executada (1-based).
  final int programWeek;

  final DateTime startedAt;
  final DateTime? finishedAt;

  /// Sets logados — chave do mapa e o `exerciseId` do template.
  /// Lista vazia significa que o exercicio ainda nao foi iniciado.
  final Map<String, List<SetEntry>> sets;

  /// Trocas de exercicio aplicadas na sessao. Chave = id original,
  /// valor = id substituto. Mantido pra reproduzir o card na UI.
  final Map<String, String> swappedExercises;

  /// Pico de strain atingido durante a sessao (0–21).
  final double peakStrain;

  bool get isLive => finishedAt == null;

  Duration? get duration =>
      finishedAt == null ? null : finishedAt!.difference(startedAt);

  /// Total de sets concluidos na sessao (independente do exercicio).
  int get completedSetsCount {
    var total = 0;
    for (final list in sets.values) {
      for (final set in list) {
        if (set.completed) total++;
      }
    }
    return total;
  }

  /// Volume total movido (kg). Soma de [SetEntry.volumeKg] de todos
  /// os sets concluidos.
  double get totalVolumeKg {
    var total = 0.0;
    for (final list in sets.values) {
      for (final set in list) {
        total += set.volumeKg;
      }
    }
    return total;
  }

  /// Quantos sets do exercicio dado ja estao concluidos.
  int completedFor(String exerciseId) {
    final list = sets[exerciseId];
    if (list == null) return 0;
    var c = 0;
    for (final set in list) {
      if (set.completed) c++;
    }
    return c;
  }

  /// Sets registrados pro exercicio dado (concluidos ou nao).
  List<SetEntry> setsFor(String exerciseId) => sets[exerciseId] ?? const [];

  LoggedSession copyWith({
    DateTime? finishedAt,
    Map<String, List<SetEntry>>? sets,
    Map<String, String>? swappedExercises,
    double? peakStrain,
  }) {
    return LoggedSession(
      id: id,
      templateId: templateId,
      startedAt: startedAt,
      programWeek: programWeek,
      sets: sets ?? this.sets,
      swappedExercises: swappedExercises ?? this.swappedExercises,
      peakStrain: peakStrain ?? this.peakStrain,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    templateId,
    programWeek,
    startedAt,
    finishedAt,
    sets,
    swappedExercises,
    peakStrain,
  ];

  @override
  String toString() =>
      'LoggedSession($id, $completedSetsCount sets, '
      '${isLive ? "live" : "finished"})';
}
