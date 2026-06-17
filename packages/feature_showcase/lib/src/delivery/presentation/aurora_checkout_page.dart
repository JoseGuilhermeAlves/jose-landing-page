import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/delivery/data/aurora_checkout_catalog.dart';
import 'package:feature_showcase/src/delivery/data/aurora_items_catalog.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_address.dart';
import 'package:feature_showcase/src/delivery/domain/market_item.dart';
import 'package:feature_showcase/src/delivery/domain/payment_method.dart';
import 'package:feature_showcase/src/delivery/domain/vendor.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_app_bar.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_brand.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_navigation.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_order_detail_page.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_bloc.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_event.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'aurora_checkout_widgets.dart';

/// Etapa de checkout do Aurora — fecha a lacuna entre o carrinho e o
/// pedido. O cliente escolhe endereco de entrega, forma de pagamento e
/// uma observacao opcional, ve o resumo de valores e confirma. So entao
/// o pedido e criado via [DeliveryOrderPlacedWithCart] (com os campos
/// de checkout) e a navegacao segue pro [AuroraOrderDetailPage].
///
/// Selecao em estado local com `setState`: e escolha efemera de UI (qual
/// endereco/pagamento esta marcado), sem fluxo de eventos — fica fora da
/// maquina do bloc, que so entra em jogo ao confirmar.
class AuroraCheckoutPage extends StatefulWidget {
  const AuroraCheckoutPage({
    required this.vendor,
    required this.quantities,
    super.key,
  });

  final Vendor vendor;

  /// Mapa `itemId` → quantidade trazido do carrinho da banca.
  final Map<String, int> quantities;

  @override
  State<AuroraCheckoutPage> createState() => _AuroraCheckoutPageState();
}

class _AuroraCheckoutPageState extends State<AuroraCheckoutPage> {
  late DeliveryAddress _address = AuroraCheckoutCatalog.addresses.first;
  late PaymentMethod _payment = AuroraCheckoutCatalog.paymentMethods.first;

  /// Index da observacao selecionada em [AuroraCheckoutCatalog.noteSuggestions];
  /// null = sem observacao.
  int? _noteIndex;

  List<MarketItem> get _vendorItems =>
      AuroraItemsCatalog.byVendor(widget.vendor.id);

  /// Linhas do pedido derivadas do carrinho, na ordem do catalogo.
  List<_CheckoutLine> get _lines => [
    for (final item in _vendorItems)
      if (widget.quantities.containsKey(item.id))
        _CheckoutLine(item: item, quantity: widget.quantities[item.id]!),
  ];

  double get _subtotalCents =>
      _lines.fold(0, (sum, l) => sum + l.item.priceCents * l.quantity);

  double get _totalCents => _subtotalCents + widget.vendor.deliveryFeeCents;

  String? get _note => _noteIndex == null
      ? null
      : AuroraCheckoutCatalog.noteSuggestions[_noteIndex!];

  void _confirm() {
    final bloc = context.read<DeliveryBloc>();
    final orderId = DeliveryBloc.peekNextOrderId();
    bloc.add(
      DeliveryOrderPlacedWithCart(
        vendorId: widget.vendor.id,
        quantities: Map.unmodifiable(widget.quantities),
        addressLine: _address.oneLine,
        paymentLabel: _payment.oneLine,
        notes: _note ?? '',
      ),
    );
    Navigator.of(context).pushReplacement(
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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AuroraAppBar(),
      body: MockBodyConstraint(
        child: Stack(
          children: [
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINALIZAR',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Revisar pedido',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colors.onSurface,
                        fontFamily: AuroraBrand.displayFontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.vendor.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionTitle(
                      label: 'Endereço de entrega',
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final addr in AuroraCheckoutCatalog.addresses) ...[
                      _AddressTile(
                        address: addr,
                        selected: addr.id == _address.id,
                        onTap: () => setState(() => _address = addr),
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _SectionTitle(
                      label: 'Pagamento',
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final pay in AuroraCheckoutCatalog.paymentMethods) ...[
                      _PaymentTile(
                        method: pay,
                        selected: pay.id == _payment.id,
                        onTap: () => setState(() => _payment = pay),
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _SectionTitle(
                      label: 'Observação',
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _NotesPicker(
                      selectedIndex: _noteIndex,
                      onChanged: (i) => setState(() => _noteIndex = i),
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SectionTitle(
                      label: 'Resumo',
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SummaryCard(
                      lines: _lines,
                      subtotalCents: _subtotalCents,
                      deliveryFeeCents: widget.vendor.deliveryFeeCents,
                      totalCents: _totalCents,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: _ConfirmBar(
                totalCents: _totalCents,
                onConfirm: _confirm,
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

/// Linha de checkout — item do catalogo + quantidade selecionada.
class _CheckoutLine {
  const _CheckoutLine({required this.item, required this.quantity});
  final MarketItem item;
  final int quantity;

  double get subtotalCents => item.priceCents * quantity;
}
