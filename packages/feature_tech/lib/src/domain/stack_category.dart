import 'package:design_system/l10n/generated/app_localizations.dart';

/// Agrupamento das libs do stack pra apresentacao. Cada categoria
/// vira um cluster visual proprio na secao Engineering do shell.
enum StackCategory {
  framework,
  state,
  routing,
  graphics,
  persistence,
  architecture,
  observability,
  quality,
  tooling;

  String label(AppLocalizations l10n) => switch (this) {
    StackCategory.framework => l10n.stack_cat_framework,
    StackCategory.state => l10n.stack_cat_state,
    StackCategory.routing => l10n.stack_cat_routing,
    StackCategory.graphics => l10n.stack_cat_graphics,
    StackCategory.persistence => l10n.stack_cat_persistence,
    StackCategory.architecture => l10n.stack_cat_architecture,
    StackCategory.observability => l10n.stack_cat_observability,
    StackCategory.quality => l10n.stack_cat_quality,
    StackCategory.tooling => l10n.stack_cat_tooling,
  };
}
