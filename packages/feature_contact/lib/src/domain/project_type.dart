import 'package:design_system/l10n/generated/app_localizations.dart';

/// Tipo de projeto que o cliente quer discutir. Eh o conjunto fixo do
/// dropdown do form de contato (PROJECT.md §4.5). Labels resolvidos
/// via l10n em [localizedLabel].
enum ProjectType {
  newApp,
  existingApp,
  consulting,
  other;

  /// Label fixo pt-BR usado no corpo da mensagem WhatsApp (sem contexto).
  String get label => switch (this) {
    ProjectType.newApp => 'App novo',
    ProjectType.existingApp => 'Evoluir app existente',
    ProjectType.consulting => 'Consultoria',
    ProjectType.other => 'Outro',
  };

  /// Label localizado para UI com BuildContext disponivel.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ProjectType.newApp => l10n.contact_projectNewApp,
    ProjectType.existingApp => l10n.contact_projectExisting,
    ProjectType.consulting => l10n.contact_projectConsulting,
    ProjectType.other => l10n.contact_projectOther,
  };
}
