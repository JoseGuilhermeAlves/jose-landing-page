import 'package:design_system/l10n/generated/app_localizations.dart';

/// Agrupamento das libs do stack pra apresentacao. Cada categoria
/// vira um cluster visual proprio na `TechSection`.
enum StackCategory {
  framework,
  state,
  routing,
  graphics,
  networking,
  persistence,
  codegen,
  architecture,
  quality,
  web,
  tooling;

  String label(AppLocalizations l10n) => switch (this) {
    StackCategory.framework => l10n.stack_cat_framework,
    StackCategory.state => l10n.stack_cat_state,
    StackCategory.routing => l10n.stack_cat_routing,
    StackCategory.graphics => l10n.stack_cat_graphics,
    StackCategory.networking => l10n.stack_cat_networking,
    StackCategory.persistence => l10n.stack_cat_persistence,
    StackCategory.codegen => l10n.stack_cat_codegen,
    StackCategory.architecture => l10n.stack_cat_architecture,
    StackCategory.quality => l10n.stack_cat_quality,
    StackCategory.web => l10n.stack_cat_web,
    StackCategory.tooling => l10n.stack_cat_tooling,
  };
}
