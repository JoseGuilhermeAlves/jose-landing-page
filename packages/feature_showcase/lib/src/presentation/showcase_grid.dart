import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/domain/showcase_template.dart';
import 'package:flutter/material.dart';

/// Grid responsivo de [ShowcaseCard]. 1/2/3 col por breakpoint.
class ShowcaseGrid extends StatelessWidget {
  const ShowcaseGrid({
    required this.templates,
    required this.onTemplateTapped,
    super.key,
  });

  final List<ShowcaseTemplate> templates;
  final ValueChanged<ShowcaseTemplate> onTemplateTapped;

  int _columnsFor(Breakpoint bp) => switch (bp) {
        Breakpoint.mobile => 1,
        Breakpoint.tablet => 2,
        Breakpoint.desktop || Breakpoint.wide => 3,
      };

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) return const SizedBox.shrink();

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
            for (final t in templates)
              SizedBox(
                width: cardWidth,
                child: ShowcaseCard(
                  template: t,
                  onTap: () => onTemplateTapped(t),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ShowcaseCard extends StatelessWidget {
  const ShowcaseCard({
    required this.template,
    required this.onTap,
    super.key,
  });

  final ShowcaseTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final disabled = !template.hasDemo;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: template.label,
      onTap: disabled ? null : onTap,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: GestureDetector(
          key: Key('showcase-card-${template.id}'),
          onTap: disabled ? null : onTap,
          child: Container(
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
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    template.icon,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      template.label,
                      style: textTheme.titleLarge?.copyWith(
                        color: disabled
                            ? colors.onSurfaceMuted
                            : colors.onSurface,
                      ),
                    ),
                    if (disabled) _ComingSoonBadge(colors: colors),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  template.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),
                if (!disabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        'Abrir demo',
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge({required this.colors});
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
        color: colors.surfaceMuted,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        'em breve',
        style: textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
