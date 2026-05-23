import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/delivery/data/aurora_items_catalog.dart';
import 'package:feature_showcase/src/delivery/domain/market_item.dart';
import 'package:feature_showcase/src/delivery/domain/vendor.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_app_bar.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_brand.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_navigation.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_order_detail_page.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_product_illustration.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_bloc.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_event.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Detalhe de uma banca — mostra header do vendor + lista de produtos
/// com stepper de quantidade + barra flutuante de carrinho. Tap em
/// "Fazer pedido" dispara [DeliveryOrderPlaced] com os itens
/// selecionados e navega pro [AuroraOrderDetailPage].
class AuroraVendorDetailPage extends StatefulWidget {
  const AuroraVendorDetailPage({required this.vendor, super.key});

  final Vendor vendor;

  @override
  State<AuroraVendorDetailPage> createState() => _AuroraVendorDetailPageState();
}

class _AuroraVendorDetailPageState extends State<AuroraVendorDetailPage> {
  final Map<String, int> _cart = {};

  List<MarketItem> get _items => AuroraItemsCatalog.byVendor(widget.vendor.id);

  int get _totalItems => _cart.values.fold(0, (s, q) => s + q);

  double get _subtotalCents {
    var total = 0.0;
    for (final entry in _cart.entries) {
      final item = _items.firstWhere((i) => i.id == entry.key);
      total += item.priceCents * entry.value;
    }
    return total;
  }

  void _increment(String itemId) =>
      setState(() => _cart[itemId] = (_cart[itemId] ?? 0) + 1);

  void _decrement(String itemId) {
    setState(() {
      final qty = (_cart[itemId] ?? 0) - 1;
      if (qty <= 0) {
        _cart.remove(itemId);
      } else {
        _cart[itemId] = qty;
      }
    });
  }

  void _placeOrder() {
    if (_cart.isEmpty) return;
    final bloc = context.read<DeliveryBloc>();
    final orderId = DeliveryBloc.peekNextOrderId();
    bloc.add(
      DeliveryOrderPlacedWithCart(
        vendorId: widget.vendor.id,
        quantities: Map.unmodifiable(_cart),
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => auroraWithDemoBloc(
          context,
          AuroraOrderDetailPage(orderId: orderId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final items = _items;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AuroraAppBar(),
      body: MockBodyConstraint(
        child: Stack(
          children: [
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  _cart.isNotEmpty ? 100 : AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VendorHeader(
                      vendor: widget.vendor,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Produtos',
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontFamily: AuroraBrand.displayFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${items.length} ${items.length == 1 ? 'item' : 'itens'}'
                      ' disponiveis',
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      _ProductCard(
                        item: items[i],
                        quantity: _cart[items[i].id] ?? 0,
                        onIncrement: () => _increment(items[i].id),
                        onDecrement: () => _decrement(items[i].id),
                        colors: colors,
                        textTheme: textTheme,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_cart.isNotEmpty)
              Positioned(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
                child: _CartBar(
                  totalItems: _totalItems,
                  subtotalCents: _subtotalCents,
                  deliveryFeeCents: widget.vendor.deliveryFeeCents,
                  onTap: _placeOrder,
                  colors: colors,
                  textTheme: textTheme,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _VendorHeader extends StatelessWidget {
  const _VendorHeader({
    required this.vendor,
    required this.colors,
    required this.textTheme,
  });

  final Vendor vendor;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: AuroraProductIllustration(
              category: vendor.primaryCategory,
              foregroundColor: colors.primary,
              accentColor: colors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontFamily: AuroraBrand.displayFontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vendor.tagline,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 12,
                      color: colors.onSurfaceMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${vendor.etaMinutes} min',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 12,
                      color: colors.onSurfaceMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vendor.formattedDeliveryFee,
                      style: textTheme.labelSmall?.copyWith(
                        color: vendor.deliveryFeeCents == 0
                            ? colors.primary
                            : colors.onSurfaceMuted,
                        fontWeight: vendor.deliveryFeeCents == 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.star_rounded, size: 12, color: colors.accent),
                    const SizedBox(width: 2),
                    Text(
                      vendor.rating.toStringAsFixed(1),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.colors,
    required this.textTheme,
  });

  final MarketItem item;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final inCart = quantity > 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: inCart ? colors.primary.withValues(alpha: 0.4) : colors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: AuroraProductIllustration(
              category: item.category,
              foregroundColor: colors.primary,
              accentColor: colors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 0,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.formattedPrice,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QtyStepper(
            quantity: quantity,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
            colors: colors,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.colors,
    required this.textTheme,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Material(
          color: colors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            key: const Key('aurora-add-item'),
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onIncrement,
            child: Icon(Icons.add_rounded, color: colors.onPrimary, size: 20),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: onDecrement,
                child: Icon(
                  Icons.remove_rounded,
                  color: colors.onSurface,
                  size: 18,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: onIncrement,
                child: Icon(Icons.add_rounded, color: colors.primary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.totalItems,
    required this.subtotalCents,
    required this.deliveryFeeCents,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  final int totalItems;
  final double subtotalCents;
  final double deliveryFeeCents;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final totalCents = subtotalCents + deliveryFeeCents;
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      elevation: 8,
      shadowColor: colors.primary.withValues(alpha: 0.4),
      child: InkWell(
        key: const Key('aurora-cart-bar'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '$totalItems',
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Fazer pedido',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                formatBrl(totalCents),
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
