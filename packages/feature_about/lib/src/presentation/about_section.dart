import 'package:design_system/design_system.dart';
import 'package:feature_about/src/data/domains_catalog.dart';
import 'package:feature_about/src/domain/domain_highlight.dart';
import 'package:feature_about/src/presentation/delivery_block.dart';
import 'package:flutter/material.dart';

/// Secao "Sobre" (quem entrega) — prosa direta no canvas, texto-primeiro,
/// sem cards genericos. Estrutura herdada da branch designmd (superior ao
/// bio-card) revestida na identidade Arcade: eyebrow em fonte pixel ciano,
/// titulo com acento magenta, bio em prosa + linhas-fato escaneaveis,
/// hairlines neon entre blocos, lista de dominios texto-primeiro e o
/// bloco "Como eu entrego" em rows estilo changelog.
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
        PixelText(l10n.about_eyebrow, color: colors.accent, pixelSize: 3),
        const SizedBox(height: AppSpacing.md),
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
        Text(
          l10n.about_domainsMapLabel,
          style: tt.headlineSmall?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: AppSpacing.lg),
        _DomainsList(domains: DomainsCatalog.all(l10n)),
        SizedBox(height: blockGap),
        const _NeonHairline(),
        SizedBox(height: blockGap),
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

/// Lista texto-primeiro dos dominios em que o Jose ja atuou — rows
/// estilo changelog, mesma gramatica do `DeliveryBlock`. Cada row tem
/// um marcador-pixel ciano no topo, o rotulo em destaque e o blurb
/// abaixo. Sem canvas, sem interacao: leitura direta e escaneavel.
class _DomainsList extends StatelessWidget {
  const _DomainsList({required this.domains});

  final List<DomainHighlight> domains;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < domains.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _DomainRow(domain: domains[i]),
        ],
      ],
    );
  }
}

/// Row unica da lista de dominios: marcador-pixel + rotulo + blurb.
class _DomainRow extends StatelessWidget {
  const _DomainRow({required this.domain});

  final DomainHighlight domain;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: ColoredBox(
            color: colors.primary,
            child: const SizedBox(width: 8, height: 8),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                domain.label,
                style: tt.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                domain.blurb,
                style: tt.bodyMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
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
