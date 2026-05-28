import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Janela de sono registrada — usada pelo dashboard de recovery.
/// Fases percentuais devem somar ~100; mock data nao precisa ser
/// matematicamente exato.
@immutable
class SleepWindow extends Equatable {
  const SleepWindow({
    required this.bedAt,
    required this.wakeAt,
    required this.efficiencyPercent,
    required this.deepPercent,
    required this.remPercent,
    required this.lightPercent,
    required this.awakePercent,
  });

  final DateTime bedAt;
  final DateTime wakeAt;

  /// Eficiencia [0..100]: tempo dormindo / tempo na cama.
  final double efficiencyPercent;

  /// Distribuicao em percent das fases.
  final double deepPercent;
  final double remPercent;
  final double lightPercent;
  final double awakePercent;

  Duration get totalInBed => wakeAt.difference(bedAt);

  Duration get asleep => Duration(
    minutes: (totalInBed.inMinutes * (efficiencyPercent / 100)).round(),
  );

  /// String compacta tipo "7h32" pro display.
  String get asleepLabel {
    final h = asleep.inHours;
    final m = asleep.inMinutes.remainder(60);
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    bedAt,
    wakeAt,
    efficiencyPercent,
    deepPercent,
    remPercent,
    lightPercent,
    awakePercent,
  ];

  @override
  String toString() =>
      'SleepWindow($asleepLabel, ${efficiencyPercent.toStringAsFixed(0)}%)';
}
