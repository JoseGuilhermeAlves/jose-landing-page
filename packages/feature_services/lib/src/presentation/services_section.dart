import 'package:design_system/design_system.dart';
import 'package:feature_services/src/presentation/services_grid.dart';
import 'package:flutter/material.dart';

/// Secao "Services" pronta pra plugar na home — combina cabecalho
/// padrao (`SectionHeader`) com o `ServicesGrid` existente.
///
/// O grid continua sendo um widget independente; quem nao precisa do
/// cabecalho (ex.: testes especificos do grid) pode importa-lo direto.
class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: l10n.services_eyebrow,
          title: l10n.services_title,
          titleAccent: l10n.services_titleAccent,
          subtitle: l10n.services_subtitle,
        ),
        const SizedBox(height: AppSpacing.xxl),
        const ServicesGrid(),
      ],
    );
  }
}
