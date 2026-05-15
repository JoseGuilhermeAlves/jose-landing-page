import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/aurora_vendors_catalog.dart';
import 'package:feature_showcase/src/domain/market_category.dart';
import 'package:feature_showcase/src/domain/vendor.dart';
import 'package:feature_showcase/src/presentation/delivery/aurora_app_bar.dart';
import 'package:feature_showcase/src/presentation/delivery/aurora_brand.dart';
import 'package:feature_showcase/src/presentation/delivery/aurora_category_icon.dart';
import 'package:feature_showcase/src/presentation/delivery/aurora_home_page.dart'
    show AuroraVendorCard;
import 'package:flutter/material.dart';

/// Lista de bancas/lojas filtravel por categoria. Reaproveita o
/// `AuroraVendorCard` da home como item da lista.
class AuroraStoreListPage extends StatefulWidget {
  const AuroraStoreListPage({this.initialCategory, super.key});

  /// Categoria pre-selecionada quando a navegacao parte de um chip da
  /// home ou de um vendor card. Null = "Todas".
  final MarketCategory? initialCategory;

  @override
  State<AuroraStoreListPage> createState() => _AuroraStoreListPageState();
}

class _AuroraStoreListPageState extends State<AuroraStoreListPage> {
  MarketCategory? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  List<Vendor> _visibleVendors() {
    if (_category == null) return AuroraVendorsCatalog.all;
    return AuroraVendorsCatalog.byCategory(_category!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final vendors = _visibleVendors();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AuroraAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'bancas'.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _category == null
                    ? 'Todas as bancas'
                    : 'Em ${_category!.label.toLowerCase()}',
                style: textTheme.headlineMedium?.copyWith(
                  color: colors.onSurface,
                  fontFamily: AuroraBrand.displayFontFamily,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _FilterChips(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                vendors.length == 1
                    ? '1 banca'
                    : '${vendors.length} bancas',
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < vendors.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                AuroraVendorCard(vendor: vendors[i]),
              ],
              if (vendors.isEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text(
                    'Nenhuma banca nessa categoria por enquanto.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        key: Key('aurora-filter-${icon?.name ?? 'all'}'),
        borderRadius: BorderRadius.circular(AppRadius.full),
        onTap: onTap,
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
                  color: selected ? colors.onPrimary : colors.primary,
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
    );
  }
}
