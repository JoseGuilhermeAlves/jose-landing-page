import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/domain/product.dart';
import 'package:feature_showcase/src/domain/product_variant.dart';
import 'package:feature_showcase/src/presentation/ecommerce/cart_bloc.dart';
import 'package:feature_showcase/src/presentation/ecommerce/cart_event.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_app_bar.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_brand.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_navigation.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_product_illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Detalhe do produto Garoa — composta por:
/// - galeria ilustrada com 3 angulos (ilustracao em rotacao via
///   tonalidades diferentes, sem stock photos);
/// - eyebrow editorial + nome em serif + origem;
/// - descricao;
/// - variantes (chips com label + sublabel);
/// - stepper de quantidade;
/// - CTA "Adicionar ao carrinho" com feedback de snackbar.
class GaroaProductDetailPage extends StatefulWidget {
  const GaroaProductDetailPage({required this.product, super.key});

  final Product product;

  @override
  State<GaroaProductDetailPage> createState() => _GaroaProductDetailPageState();
}

class _GaroaProductDetailPageState extends State<GaroaProductDetailPage> {
  int _galleryIndex = 0;
  ProductVariant? _selectedVariant;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first;
    }
  }

  double _currentPriceCents() =>
      widget.product.priceWithVariantCents(_selectedVariant);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final product = widget.product;

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
              _Gallery(
                product: product,
                activeIndex: _galleryIndex,
                onTapIndex: (i) => setState(() => _galleryIndex = i),
                colors: colors,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                product.category.label.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                product.name,
                style: textTheme.headlineMedium?.copyWith(
                  color: colors.onSurface,
                  fontFamily: GaroaBrand.displayFontFamily,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              if (product.origin.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product.origin,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                Product.formatBrl(_currentPriceCents()),
                style: textTheme.displaySmall?.copyWith(
                  color: colors.primary,
                  fontFamily: GaroaBrand.displayFontFamily,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (product.description.isNotEmpty) ...[
                Text(
                  product.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (product.variants.isNotEmpty) ...[
                _VariantsBlock(
                  product: product,
                  selected: _selectedVariant,
                  onSelect: (v) => setState(() => _selectedVariant = v),
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              _QtyAndCta(
                qty: _qty,
                onChanged: (n) => setState(() => _qty = n),
                onAdd: _addToCart,
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.xl),
              _ShippingInfoCard(colors: colors, textTheme: textTheme),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    context
        .read<CartBloc>()
        .add(CartAddProduct(widget.product, quantity: _qty));

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
      SnackBar(
        backgroundColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        content: Text(
          _qty == 1
              ? '1 ${widget.product.name} foi pro carrinho.'
              : '$_qty x ${widget.product.name} foram pro carrinho.',
          style: textTheme.bodyMedium?.copyWith(color: colors.onPrimary),
        ),
        action: SnackBarAction(
          textColor: colors.onPrimary,
          label: 'Ver',
          onPressed: () => openGaroaCart(navigator.context),
        ),
      ),
    );
  }
}

// =============================================================================
// GALERIA
// =============================================================================

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.product,
    required this.activeIndex,
    required this.onTapIndex,
    required this.colors,
  });

  final Product product;
  final int activeIndex;
  final ValueChanged<int> onTapIndex;
  final AppColorScheme colors;

  /// Cores derivadas para os 3 angulos — a mesma silhueta com
  /// background diferente da um efeito de "rotacao" sem painters
  /// separados.
  List<Color> _backgrounds() => [
        colors.surfaceMuted,
        colors.surfaceMuted.withValues(alpha: 0.55),
        colors.primary.withValues(alpha: 0.08),
      ];

  List<Color> _foregrounds() => [
        colors.primary,
        colors.accent,
        colors.primary,
      ];

  @override
  Widget build(BuildContext context) {
    final backgrounds = _backgrounds();
    final foregrounds = _foregrounds();
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: AnimatedSwitcher(
            duration: AppDuration.fast,
            child: Container(
              key: ValueKey<int>(activeIndex),
              decoration: BoxDecoration(
                color: backgrounds[activeIndex],
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: colors.border),
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: GaroaProductIllustration(
                category: product.category,
                foregroundColor: foregrounds[activeIndex],
                accentColor: colors.accent,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              _Thumb(
                index: i,
                active: i == activeIndex,
                background: backgrounds[i],
                foreground: foregrounds[i],
                product: product,
                onTap: () => onTapIndex(i),
                colors: colors,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.index,
    required this.active,
    required this.background,
    required this.foreground,
    required this.product,
    required this.onTap,
    required this.colors,
  });

  final int index;
  final bool active;
  final Color background;
  final Color foreground;
  final Product product;
  final VoidCallback onTap;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('garoa-gallery-thumb-$index'),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        width: 56,
        height: 56,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: active ? colors.primary : colors.border,
            width: active ? 2 : 1,
          ),
        ),
        child: GaroaProductIllustration(
          category: product.category,
          foregroundColor: foreground,
          accentColor: colors.accent,
        ),
      ),
    );
  }
}

// =============================================================================
// VARIANTES
// =============================================================================

class _VariantsBlock extends StatelessWidget {
  const _VariantsBlock({
    required this.product,
    required this.selected,
    required this.onSelect,
    required this.colors,
    required this.textTheme,
  });

  final Product product;
  final ProductVariant? selected;
  final ValueChanged<ProductVariant> onSelect;
  final AppColorScheme colors;
  final TextTheme textTheme;

  String _variantsHeading() {
    return switch (product.category.name) {
      'coffee' => 'Torra',
      'stationery' => 'Acabamento',
      _ => 'Variantes',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _variantsHeading(),
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontFamily: GaroaBrand.displayFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final v in product.variants)
              _VariantTile(
                variant: v,
                selected: selected?.id == v.id,
                onTap: () => onSelect(v),
                colors: colors,
                textTheme: textTheme,
              ),
          ],
        ),
      ],
    );
  }
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({
    required this.variant,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  final ProductVariant variant;
  final bool selected;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.08)
          : colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        key: Key('garoa-variant-${variant.id}'),
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      variant.label,
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (variant.deltaCents != 0)
                    Text(
                      variant.deltaCents > 0
                          ? '+ ${Product.formatBrl(variant.deltaCents)}'
                          : Product.formatBrl(variant.deltaCents),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                variant.sublabel,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 0,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// QTY + CTA
// =============================================================================

class _QtyAndCta extends StatelessWidget {
  const _QtyAndCta({
    required this.qty,
    required this.onChanged,
    required this.onAdd,
    required this.colors,
    required this.textTheme,
  });

  final int qty;
  final ValueChanged<int> onChanged;
  final VoidCallback onAdd;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: const Key('garoa-qty-decrement'),
                tooltip: 'Reduzir quantidade',
                onPressed: qty > 1 ? () => onChanged(qty - 1) : null,
                icon: const Icon(Icons.remove_rounded),
                color: colors.onSurface,
                disabledColor: colors.onSurfaceMuted.withValues(alpha: 0.5),
              ),
              SizedBox(
                width: 24,
                child: Text(
                  '$qty',
                  key: const Key('garoa-qty-value'),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                key: const Key('garoa-qty-increment'),
                tooltip: 'Aumentar quantidade',
                onPressed: qty < 99 ? () => onChanged(qty + 1) : null,
                icon: const Icon(Icons.add_rounded),
                color: colors.onSurface,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppButton(
            key: const Key('garoa-detail-add-to-cart'),
            label: 'Adicionar ao carrinho',
            icon: Icons.shopping_bag_outlined,
            size: AppButtonSize.large,
            expand: true,
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}

class _ShippingInfoCard extends StatelessWidget {
  const _ShippingInfoCard({required this.colors, required this.textTheme});

  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: colors.accent, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r'Frete gratis acima de R$ 150,00',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Despachamos em 24h uteis · Sedex e PAC',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
