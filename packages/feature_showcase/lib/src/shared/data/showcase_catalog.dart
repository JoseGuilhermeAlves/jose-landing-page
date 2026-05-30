import 'package:design_system/l10n/generated/app_localizations.dart';
import 'package:feature_showcase/src/shared/domain/showcase_template.dart';
import 'package:flutter/material.dart';

/// Catalogo dos nichos da vitrine. Cada entry com `hasDemo: true`
/// resolve um widget de demo em `showcase_section.dart`.
abstract final class ShowcaseCatalog {
  static List<ShowcaseTemplate> all(AppLocalizations l10n) => [
    ShowcaseTemplate(
      id: 'finance',
      label: l10n.showcase_financeLabel,
      description: l10n.showcase_financeDescription,
      icon: Icons.show_chart_rounded,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'delivery',
      label: l10n.showcase_deliveryLabel,
      description: l10n.showcase_deliveryDescription,
      icon: Icons.delivery_dining_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'scheduling',
      label: l10n.showcase_schedulingLabel,
      description: l10n.showcase_schedulingDescription,
      icon: Icons.calendar_month_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'fitness',
      label: l10n.showcase_fitnessLabel,
      description: l10n.showcase_fitnessDescription,
      icon: Icons.monitor_heart_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'realestate',
      label: l10n.showcase_realestateLabel,
      description: l10n.showcase_realestateDescription,
      icon: Icons.home_work_outlined,
      hasDemo: true,
    ),
  ];
}
