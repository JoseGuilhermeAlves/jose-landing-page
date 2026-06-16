import 'package:design_system/design_system.dart';
import 'package:feature_about/src/data/domains_catalog.dart';
import 'package:feature_about/src/presentation/delivery_block.dart';
import 'package:feature_about/src/presentation/domain_constellation.dart';
import 'package:flutter/material.dart';

/// Secao "Sobre" (quem entrega) — prosa direta no canvas, texto-primeiro,
/// sem cards genericos. Estrutura herdada da branch designmd (superior ao
/// bio-card) revestida na identidade Arcade: eyebrow em fonte pixel ciano,
/// titulo com acento magenta, bio em prosa + linhas-fato escaneaveis,
/// hairlines neon entre blocos, grafo de dominios e o bloco "Como eu
/// entrego" em rows estilo changelog.
///
/// **Sem timeline cronologica, sem nomear empresas/produtos** — detalhe
/// nominal fica no LinkedIn.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = context.colors;
    final l10n = context.l10n;
    final blockGap = context.responsive(
      mobile: AppSpacing.lg,
      desktop: AppSpacing.xxl,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow em fonte pixel ciano.
        PixelText(l10n.about_eyebrow, color: colors.accent, pixelSize: 3),
        const SizedBox(height: AppSpacing.md),
        // Titulo legivel com acento magenta inline.
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              style: tt.headlineLarge?.copyWith(color: colors.onSurface),
              children: [
                TextSpan(text: '${l10n.about_title} '),
                TextSpan(
                  text: l10n.about_titleAccent,
                  style: TextStyle(color: colors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Bio em prosa: subtitle muted + lead em destaque + linhas-fato +
        // fecho de escopo.
        Text(
          l10n.about_subtitle,
          style: tt.bodyLarge?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.about_bioLead,
          style: tt.bodyLarge?.copyWith(
            color: colors.onSurface,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.about_bioClose,
          style: tt.bodyMedium?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.55,
          ),
        ),
        SizedBox(height: blockGap),
        const _NeonHairline(),
        SizedBox(height: blockGap),
        // Mapa de dominios (grafo) — cada dominio e uma criatura espacial
        // clicavel; o detalhe vive no balao, nao em texto duplicado acima.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Text(
              l10n.about_domainsMapLabel,
              style: tt.headlineSmall?.copyWith(color: colors.onSurface),
            ),
            Text(
              l10n.about_domainsHint,
              style: tt.labelMedium?.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        DomainConstellation(domains: DomainsCatalog.all(l10n)),
        SizedBox(height: blockGap),
        const _NeonHairline(),
        SizedBox(height: blockGap),
        // "Como eu entrego" — rows changelog arcade.
        Text(
          l10n.about_deliveryTitle,
          style: tt.headlineSmall?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: AppSpacing.lg),
        const DeliveryBlock(),
      ],
    );
  }
}

/// Hairline horizontal neon — separador de blocos (estetica texto-primeiro,
/// sem caixas). Magenta com alpha baixo pra ler como traco de tubo.
class _NeonHairline extends StatelessWidget {
  const _NeonHairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: context.colors.primary.withValues(alpha: 0.25),
    );
  }
}

