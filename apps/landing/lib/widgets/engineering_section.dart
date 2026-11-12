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
            padding: EdgeInsets.only(
              top: context.responsive(
                mobile: AppSpacing.lg,
                desktop: AppSpacing.xl,
              ),
            ),
            child: NeonButton(
              label: context.l10n.engineering_githubButton,
              color: context.colors.accent,
              icon: Icons.north_east_rounded,
              onPressed: () => onOpenGithub?.call(githubUrl!),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NeonSectionHeading(
          index: '03',
          eyebrow: context.l10n.engineering_eyebrow,
          title: context.l10n.engineering_title,
          titleAccent: context.l10n.engineering_titleAccent,
          subtitle: context.l10n.engineering_subtitle,
        ),
        SizedBox(
          height: context.responsive(
            mobile: AppSpacing.lg,
            desktop: AppSpacing.xxl,
          ),
        ),
        TechBentoGrid(onOpenDocs: onOpenGithub),
        ctaBlock,
      ],
    );
  }
}
