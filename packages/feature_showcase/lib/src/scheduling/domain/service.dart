import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/scheduling/domain/service_category.dart';
import 'package:flutter/foundation.dart';

/// Item do catalogo de servicos do estudio Vitral. Cada servico esta
/// associado a um `Specialist` (`specialistId`) e a uma
/// [ServiceCategory]. O preco e a duracao sao snapshots dela.
@immutable
class Service extends Equatable {
  const Service({
    required this.id,
    required this.name,
    required this.specialistId,
    required this.category,
    required this.durationMinutes,
    required this.priceCents,
    required this.description,
  });

  final String id;
  final String name;

  /// FK pro Specialist que atende esse servico.
  final String specialistId;

  final ServiceCategory category;

  /// Duracao em minutos — vai compor o "slot range" no calendario.
  final int durationMinutes;

  /// Preco fechado em centavos. Algumas categorias (consultoria,
  /// fotografia) variam por escopo; o demo opta por preco fixo pra
  /// nao virar configurador.
  final double priceCents;

  /// Texto editorial curto pra catalogo e tela de detalhe.
  final String description;

  /// Duracao formatada ("1h", "1h30", "30min").
  String get formattedDuration {
    if (durationMinutes < 60) return '${durationMinutes}min';
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h${mins.toString().padLeft(2, '0')}';
  }

  /// Preco formatado em BRL ("R\$ 280,00").
  String get formattedPrice {
    final reais = priceCents / 100;
    final integer = reais.truncate();
    final cents = ((reais - integer) * 100)
        .round()
        .toString()
        .padLeft(2, '0');
    return 'R\$ $integer,$cents';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        specialistId,
        category,
        durationMinutes,
        priceCents,
        description,
      ];
}
