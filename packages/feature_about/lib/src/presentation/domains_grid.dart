import 'package:design_system/design_system.dart';
import 'package:feature_about/src/domain/domain_highlight.dart';
import 'package:flutter/material.dart';

/// Grade responsiva de [DomainCard]. Quantidade de colunas por
/// breakpoint, igual a `ServicesGrid`:
/// - mobile (<600): 1 col;
/// - tablet (600..900): 2 col;
/// - desktop+ (>=900): 3 col.
class DomainsGrid extends StatelessWidget {
  const DomainsGrid({required this.domains, super.key});

  final List<DomainHighlight> domains;

  int _columnsFor(Breakpoint bp) {
    switch (bp) {
      case Breakpoint.mobile:
        return 1;
      case Breakpoint.tablet:
        return 2;
      case Breakpoint.desktop:
      case Breakpoint.wide:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (domains.isEmpty) return const SizedBox.shrink();

    final columns = _columnsFor(context.breakpoint);

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.md;
        final totalGap = gap * (columns - 1);
        final cardWidth = (constraints.maxWidth - totalGap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final d in domains)
              SizedBox(
                width: cardWidth,
                child: DomainCard(domain: d),
              ),
          ],
        );
      },
    );
  }
}

/// Card individual de dominio. Nao tem hover-animado (diferente do
/// ServiceCard) porque nao e clickable — e ilustrativo.
class DomainCard extends StatelessWidget {
  const DomainCard({required this.domain, super.key});

  final DomainHighlight domain;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: AppGradients.brandSoft(colors),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(domain.icon, color: colors.primary, size: 22),
          ),
          const SizedBox(height: AppSpacing.md),
          // `Wrap` em vez de `Row` permite o badge cair pra linha de
          // baixo em viewports apertados sem estourar.
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                domain.label,
                style: textTheme.titleLarge?.copyWith(color: colors.onSurface),
              ),
              if (domain.isEndToEnd) _EndToEndBadge(colors: colors),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            domain.blurb,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndToEndBadge extends StatelessWidget {
  const _EndToEndBadge({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        'front end inteiro',
        style: textTheme.labelSmall?.copyWith(
          color: colors.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
