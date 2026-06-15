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
            child: AppButton(
              label: context.l10n.engineering_githubButton,
              variant: AppButtonVariant.secondary,
              icon: Icons.open_in_new,
              onPressed: () => onOpenGithub?.call(githubUrl!),
            ),
          );

    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        PixelText(
          context.l10n.engineering_eyebrow,
          color: colors.accent,
          pixelSize: 3,
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              style: tt.headlineLarge?.copyWith(color: colors.onSurface),
              children: [
                TextSpan(text: '${context.l10n.engineering_title} '),
                TextSpan(
                  text: context.l10n.engineering_titleAccent,
                  style: TextStyle(color: colors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            context.l10n.engineering_subtitle,
            style: tt.bodyLarge?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.55,
            ),
          ),
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
