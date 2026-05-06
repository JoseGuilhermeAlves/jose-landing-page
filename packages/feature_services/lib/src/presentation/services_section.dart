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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: 'Servicos',
          title: 'Front end mobile.',
          titleAccent: 'Do brief ao deploy.',
          subtitle:
              'Apps mobile com Flutter, versao web/PWA quando '
              'aplicavel, integracao com APIs existentes e consultoria '
              'de arquitetura. Backend e infra permanecem com o time '
              'do cliente.',
        ),
        SizedBox(height: AppSpacing.xxl),
        ServicesGrid(),
      ],
    );
  }
}
