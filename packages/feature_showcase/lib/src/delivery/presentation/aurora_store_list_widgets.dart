part of 'aurora_store_list_page.dart';

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onChanged,
    required this.colors,
    required this.textTheme,
  });

  final MarketCategory? selected;
  final ValueChanged<MarketCategory?> onChanged;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'Todas',
            selected: selected == null,
            onTap: () => onChanged(null),
            colors: colors,
            textTheme: textTheme,
          ),
          for (final c in MarketCategory.values) ...[
            const SizedBox(width: AppSpacing.xs),
            _Chip(
              label: c.label,
              icon: c,
              selected: selected == c,
              onTap: () => onChanged(c),
              colors: colors,
              textTheme: textTheme,
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.textTheme,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final MarketCategory? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.primary : auroraCardFill(colors),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        key: Key('aurora-filter-${icon?.name ?? 'all'}'),
        borderRadius: BorderRadius.circular(AppRadius.full),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: selected ? null : auroraCardShadow(colors),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: selected ? colors.primary : colors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  AuroraCategoryIcon(
                    category: icon!,
                    color: selected ? colors.onPrimary : colors.accent,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: selected ? colors.onPrimary : colors.onSurface,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
