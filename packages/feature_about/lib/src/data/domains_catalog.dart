import 'package:feature_about/src/domain/domain_highlight.dart';
import 'package:flutter/material.dart';

/// Dominios em que o Jose ja atuou — landing publica.
/// **Nao nomeia empresa nem produto** (regra hard, ver MEMORY:
/// `copy_no_named_clients`). Quem quiser detalhe nominal abre o
/// LinkedIn.
///
/// Ordem: do tipo de trabalho mais recente/atual pro mais antigo, com
/// o varejo (end-to-end) ao final por ser onde a carreira comecou e
/// por ser o unico contexto onde o Jose construiu sozinho.
abstract final class DomainsCatalog {
  static const List<DomainHighlight> all = [
    DomainHighlight(
      id: 'fintech',
      label: 'Fintech',
      blurb:
          'Apps de credito mobile em escala — base ativa de milhoes '
          'de usuários.',
      icon: Icons.credit_card_outlined,
    ),
    DomainHighlight(
      id: 'public_services',
      label: 'Setor público',
      blurb:
          'Servicos digitais ao cidadao com integracao a identidade '
          'governamental.',
      icon: Icons.account_balance_outlined,
    ),
    DomainHighlight(
      id: 'sanitation',
      label: 'Operacao em campo',
      blurb:
          'Apps de coleta e inspecao em devices industriais com '
          'sincronizacao offline-first.',
      icon: Icons.engineering_outlined,
    ),
    DomainHighlight(
      id: 'platform',
      label: 'Plataforma interna',
      blurb:
          'Ferramentas internas pra gestao de equipes e operacao '
          'corporativa em larga escala.',
      icon: Icons.hub_outlined,
    ),
    DomainHighlight(
      id: 'retail',
      label: 'Varejo B2B',
      blurb:
          'Apps mobile de operacao de loja, controle de estoque, '
          'inventario e pedidos. Front end Flutter inteiro, em time '
          'pequeno, ao longo de 5 anos.',
      icon: Icons.storefront_outlined,
      scope: DomainScope.endToEnd,
    ),
  ];
}
