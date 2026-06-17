import 'package:design_system/l10n/generated/app_localizations.dart';
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
  static List<DomainHighlight> all(AppLocalizations l10n) => [
    DomainHighlight(
      id: 'fintech',
      label: l10n.domain_fintech_label,
      blurb: l10n.domain_fintech_blurb,
      icon: Icons.credit_card_outlined,
    ),
    DomainHighlight(
      id: 'public_services',
      label: l10n.domain_publicServices_label,
      blurb: l10n.domain_publicServices_blurb,
      icon: Icons.account_balance_outlined,
    ),
    DomainHighlight(
      id: 'sanitation',
      label: l10n.domain_sanitation_label,
      blurb: l10n.domain_sanitation_blurb,
      icon: Icons.engineering_outlined,
    ),
    DomainHighlight(
      id: 'retail',
      label: l10n.domain_retail_label,
      blurb: l10n.domain_retail_blurb,
      icon: Icons.storefront_outlined,
      scope: DomainScope.endToEnd,
    ),
  ];
}
