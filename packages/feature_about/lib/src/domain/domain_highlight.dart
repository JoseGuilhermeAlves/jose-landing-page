import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Quanto da entrega o Jose teve sob sua responsabilidade direta.
/// Usado pra ser **honesto** com o visitante: o que foi feito sozinho
/// vs. o que foi como parte de um time de produto.
enum DomainScope {
  /// Construido ponta a ponta — produto, arquitetura, desenvolvimento
  /// e suporte direto a operacao.
  endToEnd,

  /// Atuou em time de produto — escopo de feature, arquitetura ou
  /// stewardship, conforme o contexto.
  team,
}

/// Item da grade "domínios em que ja atuei". Categorico, **nao**
/// time-based — e nao nomeia empresa nem produto. Detalhe nominal
/// fica no LinkedIn.
@immutable
class DomainHighlight extends Equatable {
  const DomainHighlight({
    required this.id,
    required this.label,
    required this.blurb,
    required this.icon,
    this.scope = DomainScope.team,
  });

  /// Identificador estavel pra testes e analytics futuros.
  final String id;

  /// Rotulo curto exibido no card (ex.: "Fintech", "Varejo B2B").
  final String label;

  /// 1-2 linhas descrevendo o tipo de produto/contexto, sem nomes.
  final String blurb;

  final IconData icon;

  /// Escopo do envolvimento do Jose nesse dominio.
  final DomainScope scope;

  bool get isEndToEnd => scope == DomainScope.endToEnd;

  @override
  List<Object?> get props => [id, label, blurb, icon, scope];

  @override
  String toString() => 'DomainHighlight(id: $id, label: $label, scope: $scope)';
}
