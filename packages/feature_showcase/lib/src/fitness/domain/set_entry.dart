import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Set registrado durante uma sessao. Imutavel — mutacoes geram nova
/// instancia via [copyWith]. RPE (Rate of Perceived Exertion) e a
/// escala 1–10 de esforco percebido (Hevy/Caliber/Train Heroic).
@immutable
class SetEntry extends Equatable {
  const SetEntry({
    required this.id,
    required this.index,
    required this.weightKg,
    required this.reps,
    required this.rpe,
    required this.completed,
    this.notes,
    this.failurePartials = false,
  });

  /// Identificador estavel dentro da sessao (ex.: `bench-1`, `bench-2`).
  final String id;

  /// Ordem do set dentro do exercicio (1-based).
  final int index;

  /// Carga em kg. Aceita decimal pra anilhas fracionarias.
  final double weightKg;

  /// Reps efetivamente concluidas. Pode diferir do alvo se o atleta
  /// falhou antes ou estourou alem.
  final int reps;

  /// Esforco percebido na escala 1–10. Zero = nao informado.
  final double rpe;

  /// `true` quando o atleta marcou o set como concluido. Set falhado
  /// pode ficar [completed] = false ate ser editado.
  final bool completed;

  /// Observacoes opcionais (sensacoes, dor, tecnica).
  final String? notes;

  /// Flag pra registrar que reps parciais foram extraidas (forced
  /// reps / partials). Usado em historico avancado.
  final bool failurePartials;

  /// Volume desse set em kg (peso x reps). 0 se nao concluido.
  double get volumeKg => completed ? weightKg * reps : 0;

  SetEntry copyWith({
    double? weightKg,
    int? reps,
    double? rpe,
    bool? completed,
    String? notes,
    bool? failurePartials,
  }) {
    return SetEntry(
      id: id,
      index: index,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      failurePartials: failurePartials ?? this.failurePartials,
    );
  }

  @override
  List<Object?> get props => [
    id,
    index,
    weightKg,
    reps,
    rpe,
    completed,
    notes,
    failurePartials,
  ];

  @override
  String toString() =>
      'SetEntry(#$index ${weightKg}kg x $reps reps @ RPE $rpe '
      '${completed ? "✓" : "·"})';
}
