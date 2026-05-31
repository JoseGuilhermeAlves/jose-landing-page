import 'package:design_system/design_system.dart';
import 'package:feature_tech/src/domain/stack_category.dart';
import 'package:feature_tech/src/domain/stack_item.dart';
import 'package:flutter/material.dart';

/// Grade do stack agrupada por categoria. Cada categoria vira um
/// cluster com header pequeno + Wrap de chips. Chip exibe nome + versao
/// em mono, com role como tooltip.
class StackByCategory extends StatelessWidget {
  const StackByCategory({required this.itemsByCategory, super.key});

  final Map<StackCategory, List<StackItem>> itemsByCategory;

  @override
  Widget build(BuildContext context) {
    final entries = itemsByCategory.entries
        .where((e) => e.value.isNotEmpty)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          _CategoryCluster(category: entries[i].key, items: entries[i].value),
        ],
      ],
    );
  }
}

class _CategoryCluster extends StatelessWidget {
  const _CategoryCluster({required this.category, required this.items});

  final StackCategory category;
  final List<StackItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              category.label(context.l10n).toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [for (final item in items) _StackChip(item: item)],
        ),
      ],
    );
  }
}

class _StackChip extends StatelessWidget {
  const _StackChip({required this.item});

  final StackItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Tooltip(
      message: item.role,
      preferBelow: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(width: 1, height: 12, color: colors.border),
            const SizedBox(width: AppSpacing.sm),
            Text(
              item.version,
              style: textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
