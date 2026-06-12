import 'package:design_system/l10n/generated/app_localizations.dart';

/// Contexto da conversa que o visitante quer abrir. Conjunto fixo do
/// dropdown do form de contato, orientado ao funil recrutador/tech
/// lead (vaga, contrato, consultoria). Labels resolvidos via l10n em
/// [localizedLabel].
enum ProjectType {
  position,
  contractProject,
  consulting,
  other;

  /// Label fixo pt-BR usado no corpo do mailto (sem contexto).
  String get label => switch (this) {
    ProjectType.position => 'Vaga (CLT/PJ)',
    ProjectType.contractProject => 'Projeto ou contrato',
    ProjectType.consulting => 'Consultoria pontual',
    ProjectType.other => 'Outro',
  };

  /// Label localizado para UI com BuildContext disponivel.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ProjectType.position => l10n.contact_projectPosition,
    ProjectType.contractProject => l10n.contact_projectContract,
    ProjectType.consulting => l10n.contact_projectConsulting,
    ProjectType.other => l10n.contact_projectOther,
  };
}
