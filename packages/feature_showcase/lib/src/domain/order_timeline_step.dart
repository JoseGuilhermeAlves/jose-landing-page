import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Passo da timeline visual do pedido na tela de detalhe Aurora.
/// Comunica o que esta acontecendo (e o que ja aconteceu) sem
/// depender so do `DeliveryStatus`. Cada passo carrega uma
/// descricao curta + horario aproximado (mock).
@immutable
class OrderTimelineStep extends Equatable {
  const OrderTimelineStep({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.isComplete,
    required this.isCurrent,
  });

  final String title;
  final String subtitle;

  /// Horario formatado mock ("09:42") ou "—" quando ainda nao
  /// aconteceu.
  final String timeLabel;

  /// True quando o passo ja foi cumprido (ou e o atual).
  final bool isComplete;

  /// True so para o passo atualmente em execucao.
  final bool isCurrent;

  @override
  List<Object?> get props => [
        title,
        subtitle,
        timeLabel,
        isComplete,
        isCurrent,
      ];
}
