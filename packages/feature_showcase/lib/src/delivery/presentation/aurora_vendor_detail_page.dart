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

part 'aurora_vendor_detail_widgets.dart';

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
