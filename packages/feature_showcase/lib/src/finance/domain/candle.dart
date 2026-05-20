import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Vela OHLC (Open/High/Low/Close) do candlestick chart. Todos os
/// precos em centavos. `volume` em quantidade de papeis negociados.
/// Sem timezone — os mocks usam dias consecutivos partindo de uma
/// data ancora.
@immutable
class Candle extends Equatable {
  const Candle({
    required this.timestamp,
    required this.openCents,
    required this.highCents,
    required this.lowCents,
    required this.closeCents,
    required this.volume,
  });

  final DateTime timestamp;
  final int openCents;
  final int highCents;
  final int lowCents;
  final int closeCents;
  final int volume;

  /// True quando o fechamento ficou acima da abertura (vela "verde").
  bool get isBullish => closeCents >= openCents;

  @override
  List<Object?> get props => [
        timestamp,
        openCents,
        highCents,
        lowCents,
        closeCents,
        volume,
      ];
}
