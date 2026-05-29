import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/engineering/bento_grid.dart';

/// Secao "Engenharia e servicos" — bento grid de techs por categoria.
/// Cada tile carrega cor signature da tech e abre `showTechBodyPopup`
/// com descricao expandida ao tap. Layout segue best practice de sites
/// tecnicos (Linear/Vercel/Stripe): hierarquia visual por categoria,
/// densidade alta, escaneamento rapido.
class EngineeringSection extends StatelessWidget {
  const EngineeringSection({this.githubUrl, this.onOpenGithub, super.key});

  final String? githubUrl;
  final void Function(String url)? onOpenGithub;

  @override
  Widget build(BuildContext context) {
    final ctaBlock = githubUrl == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: AppButton(
              label: 'Ver repositório no GitHub',
              variant: AppButtonVariant.secondary,
              icon: Icons.open_in_new,
              onPressed: () => onOpenGithub?.call(githubUrl!),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(
          eyebrow: 'Engenharia e servicos',
          title: 'A stack que sustenta',
          titleAccent: 'cada decisao do projeto.',
          subtitle:
              'Tecnologias que domino e aplico em producao. '
              'Toque em qualquer tile para saber mais.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        TechBentoGrid(onOpenDocs: onOpenGithub),
        ctaBlock,
      ],
    );
  }
}
