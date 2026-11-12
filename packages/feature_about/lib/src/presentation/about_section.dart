import 'package:design_system/design_system.dart';
import 'package:feature_about/src/data/domains_catalog.dart';
import 'package:feature_about/src/domain/domain_highlight.dart';
import 'package:feature_about/src/presentation/delivery_block.dart';
import 'package:flutter/material.dart';

/// Secao "Sobre" (quem entrega). Redesign 2026-11 â€” tres blocos com
/// tratamentos distintos, sem listas numeradas:
///
/// 1. **Abertura**: citacao em destaque (barra magenta) + fechamento, e uma
///    faixa de numeros-chave a direita (anos, setores, apps).
/// 2. **Onde ja entreguei**: setores em cards 2x2 com icone; o varejo leva o
///    selo "front end inteiro" (escopo ponta a ponta).
/// 3. **Como eu entrego**: tres principios em colunas ([DeliveryBlock]).
///
/// **Sem nomear empresas/produtos** â€” detalhe nominal fica no LinkedIn.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = context.colors;
    final l10n = context.l10n;
    final isMobile = context.isMobile;
    final domains = DomainsCatalog.all(l10n);
    final blockGap = isMobile ? 56.0 : 96.0;

    final quote = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(left: AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: colors.primary, width: 3)),
          ),
          child: Text(
            l10n.about_bioLead,
            style: (isMobile ? tt.titleLarge : tt.headlineSmall)?.copyWith(
              color: colors.onSurface,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg + 3),
          child: Text(
            l10n.about_bioClose,
            style: tt.bodyLarge?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ),
      ],
    );

    final stats = _StatStrip(
      stats: [
        (l10n.hero_trustYearsValue, l10n.hero_trustYearsLabel),
        (domains.length.toString(), l10n.about_statSectorsLabel),
        ('5', l10n.about_statAppsLabel),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonSectionHeading(
          index: '02',
          eyebrow: l10n.about_eyebrow,
          title: l10n.about_title,
          titleAccent: l10n.about_titleAccent,
          subtitle: l10n.about_subtitle,
        ),
        SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxl),
        if (isMobile) ...[
          quote,
          const SizedBox(height: AppSpacing.xl),
          stats,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: quote),
              const SizedBox(width: AppSpacing.huge),
              Expanded(flex: 4, child: stats),
            ],
          ),
        SizedBox(height: blockGap),
        _BlockTitle(l10n.about_domainsMapLabel),
        const SizedBox(height: AppSpacing.lg),
        _DomainGrid(domains: domains),
        SizedBox(height: blockGap),
        _BlockTitle(l10n.about_deliveryTitle),
        const SizedBox(height: AppSpacing.lg),
        const DeliveryBlock(),
      ],
    );
  }
}

/// Titulo de bloco interno: texto + filete que corre ate a borda.
class _BlockTitle extends StatelessWidget {
  const _BlockTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: Container(height: 1, color: colors.border)),
      ],
    );
  }
}

/// Numeros-chave empilhados, separados por filetes â€” leitura em segundos.
class _StatStrip extends StatelessWidget {
  const _StatStrip({required this.stats});

  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    Widget stat((String, String) s) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              s.$1,
              style: tt.displaySmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                height: 1,
                shadows: [
                  Shadow(
                    color: colors.primary.withValues(alpha: 0.5),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              s.$2,
              style: tt.bodyMedium?.copyWith(
                color: colors.onSurfaceMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) Container(height: 1, color: colors.border),
            stat(stats[i]),
          ],
        ],
      );
    }
    return Column(
      children: [
        Container(height: 1, color: colors.border),
        for (final s in stats) ...[
          stat(s),
          Container(height: 1, color: colors.border),
        ],
      ],
    );
  }
}

/// Setores em grade 2x2 (1 coluna no mobile), linhas com altura igual.
class _DomainGrid extends StatelessWidget {
  const _DomainGrid({required this.domains});

  final List<DomainHighlight> domains;

  @override
  Widget build(BuildContext context) {
    final cols = context.isMobile ? 1 : 2;
    final rows = <Widget>[];
    for (var i = 0; i < domains.length; i += cols) {
      final slice = domains.sublist(i, (i + cols).clamp(0, domains.length));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < cols; j++) ...[
                if (j > 0) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: j < slice.length
                      ? _DomainCard(domain: slice[j])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          rows[i],
        ],
      ],
    );
  }
}

class _DomainCard extends StatefulWidget {
  const _DomainCard({required this.domain});

  final DomainHighlight domain;

  @override
  State<_DomainCard> createState() => _DomainCardState();
}

class _DomainCardState extends State<_DomainCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final d = widget.domain;
    final tint = d.isEndToEnd ? colors.primary : colors.accent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppDuration.fast,
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: _hovered ? 0.85 : 0.55),
          border: Border.all(
            color: _hovered ? tint.withValues(alpha: 0.7) : colors.border,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: tint.withValues(alpha: 0.18), blurRadius: 24)]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.1),
                border: Border.all(color: tint.withValues(alpha: 0.45)),
              ),
              child: Icon(d.icon, color: tint, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        d.label,
                        style: tt.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (d.isEndToEnd)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          color: colors.primary.withValues(alpha: 0.14),
                          child: Text(
                            context.l10n.about_scopeEndToEnd.toUpperCase(),
                            style: tt.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    d.blurb,
                    style: tt.bodyMedium?.copyWith(
                      color: colors.onSurfaceMuted,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
