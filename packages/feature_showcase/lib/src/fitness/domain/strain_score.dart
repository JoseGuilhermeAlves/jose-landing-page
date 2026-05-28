import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Strain do dia, escala 0–21 inspirada no Whoop (logaritmica).
/// Target = strain prescrito pra sessao do dia. Accumulated =
/// strain efetivamente atingido (pro mock, somatorio de contribuicoes
/// da sessao + cardio mock). Cardio e lifting decompostos pra exibir
/// breakdown na UI.
@immutable
class StrainScore extends Equatable {
  const StrainScore({
    required this.target,
    required this.accumulated,
    required this.cardioContribution,
    required this.liftingContribution,
  });

  final double target;
  final double accumulated;

  /// Quanto do strain veio de zona cardio/aerobia.
  final double cardioContribution;

  /// Quanto veio de treino de forca/lifting.
  final double liftingContribution;

  /// Razao [0..>1] entre realizado e prescrito — UI exibe como ring.
  double get fulfillment => target == 0 ? 0 : accumulated / target;

  /// Strain restante ate bater o alvo (>= 0).
  double get remaining =>
      (target - accumulated).clamp(0, double.infinity).toDouble();

  bool get overshot => accumulated > target;

  StrainScore copyWith({
    double? accumulated,
    double? cardioContribution,
    double? liftingContribution,
  }) {
    return StrainScore(
      target: target,
      accumulated: accumulated ?? this.accumulated,
      cardioContribution: cardioContribution ?? this.cardioContribution,
      liftingContribution: liftingContribution ?? this.liftingContribution,
    );
  }

  @override
  List<Object?> get props => [
    target,
    accumulated,
    cardioContribution,
    liftingContribution,
  ];

  @override
  String toString() =>
      'StrainScore(${accumulated.toStringAsFixed(1)}/${target.toStringAsFixed(1)})';
}
