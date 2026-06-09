import 'package:equatable/equatable.dart';
import 'package:feature_showcase/feature_showcase.dart' show RestExtended;
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart' show RestExtended;
import 'package:flutter/foundation.dart';

/// Estado do rest timer entre sets. Vive como sub-state do
/// `FitnessState` enquanto o atleta descansa. `total` e o valor
/// originalmente disparado (referencia pra progresso); `remaining`
/// e o saldo atual decrementado pelo bloc a cada `RestTicked`.
@immutable
class RestTimer extends Equatable {
  const RestTimer({required this.total, required this.remaining});

  /// Tempo total prescrito no inicio (segundos). Pode ser estendido
  /// via [RestExtended] — total sobe junto pra manter ratio do
  /// progresso coerente.
  final int total;

  /// Segundos restantes. Quando bate 0, o bloc remove o `restTimer`
  /// do state (vira null).
  final int remaining;

  /// Progresso 0..1 — UI usa pra linear progress bar.
  double get progress => total == 0 ? 0 : 1 - (remaining / total);

  RestTimer copyWith({int? total, int? remaining}) =>
      RestTimer(total: total ?? this.total, remaining: remaining ?? this.remaining);

  @override
  List<Object?> get props => [total, remaining];

  @override
  String toString() => 'RestTimer($remaining/$total)';
}
