import 'package:design_system/design_system.dart';
import 'package:feature_tech/src/domain/painter_highlight.dart';
import 'package:flutter/material.dart';

/// Lista compacta dos painters de destaque. Cada item: nome em mono +
/// role + localizacao em chip discreto. Visual minimalista — quem quer
/// brincar com eles vai pra `/labs`.
class PaintersStrip extends StatelessWidget {
  const PaintersStrip({required this.painters, super.key});

  final List<PainterHighlight> painters;

  int _columnsFor(Breakpoint bp) => switch (bp) {
        Breakpoint.mobile => 1,
        Breakpoint.tablet => 2,
        Breakpoint.desktop || Breakpoint.wide => 3,
      };

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(context.breakpoint);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.md;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final p in painters)
              SizedBox(
                width: cardWidth,
                child: _PainterCard(painter: p),
              ),
          ],
        );
      },
    );
  }
}

class _PainterCard extends StatelessWidget {
  const _PainterCard({required this.painter});

  final PainterHighlight painter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      key: Key('painter-card-${painter.name}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            painter.name,
            style: textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            painter.role,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.25),
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              painter.location,
              style: textTheme.labelSmall?.copyWith(
                color: colors.primary,
                letterSpacing: 0.3,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
