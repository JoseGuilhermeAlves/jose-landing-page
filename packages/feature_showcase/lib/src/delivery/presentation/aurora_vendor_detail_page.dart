import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/delivery/data/aurora_items_catalog.dart';
import 'package:feature_showcase/src/delivery/domain/market_item.dart';
import 'package:feature_showcase/src/delivery/domain/vendor.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_app_bar.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_brand.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_checkout_page.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_item_detail_sheet.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_navigation.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_product_illustration.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/presentation/showcase_photo.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
import 'package:flutter/material.dart';

part 'aurora_vendor_detail_widgets.dart';

/// Detalhe de uma banca — mostra header do vendor + lista de produtos
/// com stepper de quantidade + barra flutuante de carrinho. Tap no card
/// do produto abre o [AuroraItemDetailSheet] (foto + descricao +
/// quantidade). Tap em "Continuar" leva ao [AuroraCheckoutPage], onde o
/// pedido e de fato fechado.
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

  /// Abre o sheet de detalhe do item. O sheet devolve a quantidade
  /// escolhida, que sobrescreve a linha do carrinho (substitui em vez
  /// de somar — o stepper do sheet ja parte da qty atual).
  Future<void> _openItemDetail(MarketItem item) async {
    final chosen = await AuroraItemDetailSheet.show(
      context,
      item: item,
      initialQuantity: _cart[item.id] ?? 0,
    );
    if (chosen == null || !mounted) return;
    setState(() => _cart[item.id] = chosen);
  }

  /// Vai pra etapa de checkout (endereco + pagamento + observacao). O
  /// pedido so e criado la, ao confirmar — aqui apenas carregamos a
  /// selecao do carrinho.
  void _goToCheckout() {
    if (_cart.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => auroraWithDemoBloc(
          context,
          AuroraCheckoutPage(
            vendor: widget.vendor,
            quantities: Map.unmodifiable(_cart),
          ),
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
                        onTap: () => _openItemDetail(items[i]),
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
                  onTap: _goToCheckout,
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
