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

/// Lista texto-primeiro dos dominios em que o Jose ja atuou — **mesma
/// gramatica visual do `DeliveryBlock`**: rows estilo changelog com numero
/// de stage em pixel magenta, titulo legivel e blurb muted, em duas colunas
/// no desktop e empilhado no mobile, separados por hairline neon.
class _DomainsList extends StatelessWidget {
  const _DomainsList({required this.domains});

  final List<DomainHighlight> domains;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < domains.length; i++)
          _DomainRow(
            stage: (i + 1).toString().padLeft(2, '0'),
            domain: domains[i],
          ),
      ],
    );
  }
}

/// Row unica da lista de dominios — espelha `_DeliveryRow`: heading com
/// stage em pixel + titulo, paragrafo na segunda coluna, hairline embaixo.
class _DomainRow extends StatelessWidget {
  const _DomainRow({required this.stage, required this.domain});

  final String stage;
  final DomainHighlight domain;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = context.colors;
    final isMobile = context.isMobile;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        PixelText(stage, color: colors.primary, pixelSize: 3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          domain.label,
          style: tt.titleMedium?.copyWith(
            color: colors.onSurface,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final paragraph = Text(
      domain.blurb,
      style: tt.bodyMedium?.copyWith(color: colors.onSurfaceMuted, height: 1.5),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                heading,
                const SizedBox(height: AppSpacing.sm),
                paragraph,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 260, child: heading),
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: paragraph),
              ],
            ),
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
