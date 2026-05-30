import 'package:design_system/l10n/generated/app_localizations.dart';
import 'package:feature_services/src/domain/service.dart';
import 'package:flutter/material.dart';

/// Catalogo do "o que eu faco". Lista canonica do PROJECT.md §4.2 —
/// qualquer ajuste de copy passa pelos ARBs agora.
abstract final class ServicesCatalog {
  static List<Service> all(AppLocalizations l10n) => [
    Service(
      id: 'mobile',
      title: l10n.services_mobile_title,
      description: l10n.services_mobile_description,
      icon: Icons.phone_android,
    ),
    Service(
      id: 'web',
      title: l10n.services_web_title,
      description: l10n.services_web_description,
      icon: Icons.public,
    ),
    Service(
      id: 'integrations',
      title: l10n.services_integrations_title,
      description: l10n.services_integrations_description,
      icon: Icons.hub_outlined,
    ),
    Service(
      id: 'maintenance',
      title: l10n.services_maintenance_title,
      description: l10n.services_maintenance_description,
      icon: Icons.build_outlined,
    ),
    Service(
      id: 'consulting',
      title: l10n.services_consulting_title,
      description: l10n.services_consulting_description,
      icon: Icons.lightbulb_outline,
    ),
  ];
}
