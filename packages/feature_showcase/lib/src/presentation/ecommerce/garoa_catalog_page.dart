import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/products_catalog.dart';
import 'package:feature_showcase/src/domain/product.dart';
import 'package:feature_showcase/src/domain/product_category.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_app_bar.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_brand.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_category_icon.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_home_page.dart'
    show GaroaProductCard;
import 'package:flutter/material.dart';

/// Catalogo da Garoa — grid responsivo com filtro por categoria (chips
/// horizontais) e ordenacao por preco. Cada categoria mostra um glifo
/// desenhado pelo [GaroaCategoryIcon]. Tap em card abre o detalhe.
class GaroaCatalogPage extends StatefulWidget {
  const GaroaCatalogPage({this.initialCategory, super.key});

  /// Categoria pre-selecionada — usado pelos cards de categoria da
  /// home. Quando null, mostra todos.
  final ProductCategory? initialCategory;

  @override
  State<GaroaCatalogPage> createState() => _GaroaCatalogPageState();
}

enum _SortMode {
  recent('Em destaque'),
  priceAsc('Menor preco'),
  priceDesc('Maior preco');

  const _SortMode(this.label);
  final String label;
}

class _GaroaCatalogPageState extends State<GaroaCatalogPage> {
  ProductCategory? _category;
  _SortMode _sort = _SortMode.recent;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  List<Product> _visibleProducts() {
    final base = _category == null
        ? List<Product>.from(ProductsCatalog.all)
        : ProductsCatalog.byCategory(_category!);
    switch (_sort) {
      case _SortMode.recent:
        return base;
      case _SortMode.priceAsc:
        base.sort((a, b) => a.priceCents.compareTo(b.priceCents));
      case _SortMode.priceDesc:
        base.sort((a, b) => b.priceCents.compareTo(a.priceCents));
    }
    return base;
  }

  int _columnsFor(Breakpoint bp) => switch (bp) {
        Breakpoint.mobile => 2,
        Breakpoint.tablet => 3,
        Breakpoint.desktop || Breakpoint.wide => 4,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final products = _visibleProducts();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const GaroaAppBar(),
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
                'catalogo'.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _category == null
                    ? 'Tudo da loja'
                    : 'Em ${_category!.label.toLowerCase()}',
                style: textTheme.headlineMedium?.copyWith(
                  color: colors.onSurface,
                  fontFamily: GaroaBrand.displayFontFamily,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _CategoryFilterChips(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.md),
              _SortRow(
                count: products.length,
                sort: _sort,
                onChanged: (s) => setState(() => _sort = s),
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = _columnsFor(context.breakpoint);
                  const gap = AppSpacing.md;
                  final cardWidth =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final p in products)
                        SizedBox(
                          width: cardWidth,
                          child: GaroaProductCard(product: p),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterChips extends StatelessWidget {
  const _CategoryFilterChips({
    required this.selected,
    required this.onChanged,
    required this.colors,
    required this.textTheme,
  });

  final ProductCategory? selected;
  final ValueChanged<ProductCategory?> onChanged;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'Tudo',
            selected: selected == null,
            onTap: () => onChanged(null),
            colors: colors,
            textTheme: textTheme,
          ),
          for (final c in ProductCategory.values) ...[
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
  final ProductCategory? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        key: Key('garoa-filter-${icon?.name ?? 'all'}'),
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
                GaroaCategoryIcon(
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

class _SortRow extends StatelessWidget {
  const _SortRow({
    required this.count,
    required this.sort,
    required this.onChanged,
    required this.colors,
    required this.textTheme,
  });

  final int count;
  final _SortMode sort;
  final ValueChanged<_SortMode> onChanged;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          count == 1 ? '1 produto' : '$count produtos',
          style: textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceMuted,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        PopupMenuButton<_SortMode>(
          key: const Key('garoa-sort-menu'),
          tooltip: 'Ordenar',
          initialValue: sort,
          onSelected: onChanged,
          color: colors.surface,
          itemBuilder: (_) => [
            for (final s in _SortMode.values)
              PopupMenuItem<_SortMode>(
                value: s,
                child: Text(
                  s.label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sort_rounded,
                  size: 16,
                  color: colors.onSurfaceMuted,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  sort.label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.expand_more_rounded,
                  size: 16,
                  color: colors.onSurfaceMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
