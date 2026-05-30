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
              label: context.l10n.engineering_githubButton,
              variant: AppButtonVariant.secondary,
              icon: Icons.open_in_new,
              onPressed: () => onOpenGithub?.call(githubUrl!),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(
          eyebrow: context.l10n.engineering_eyebrow,
          title: context.l10n.engineering_title,
          titleAccent: context.l10n.engineering_titleAccent,
          subtitle: context.l10n.engineering_subtitle,
        ),
        const SizedBox(height: AppSpacing.xxl),
        TechBentoGrid(onOpenDocs: onOpenGithub),
        ctaBlock,
      ],
    );
  }
}
