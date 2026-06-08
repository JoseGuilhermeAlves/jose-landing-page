import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/finance/data/mira_assets_catalog.dart';
import 'package:feature_showcase/src/finance/domain/order_side.dart';
import 'package:feature_showcase/src/finance/presentation/finance_bloc.dart';
import 'package:feature_showcase/src/finance/presentation/finance_event.dart';
import 'package:feature_showcase/src/finance/presentation/finance_state.dart';
import 'package:feature_showcase/src/finance/presentation/mira_app_bar.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/util/mira_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'mira_order_entry_widgets.dart';

/// Form de envio de ordem (compra ou venda) do ativo. Estado local
/// segura quantidade, tipo (mercado/limitada) e preco limite quando
/// aplicavel. Submit dispara `FinanceTradeExecuted` e volta pra home
/// do demo.
///
/// Os sub-widgets do form (resumo do ativo, quantidade, segmento de
/// tipo, total, banner de aviso, barra de confirmar) vivem na part
/// irma `mira_order_entry_widgets.dart`.
class MiraOrderEntryPage extends StatefulWidget {
  const MiraOrderEntryPage({
    required this.assetId,
    required this.side,
    this.initialQuantity,
    super.key,
  });

  final String assetId;
  final OrderSide side;

  /// Quantidade inicial do form. Quando nula, usa o default de 100.
  /// Preenchida pelo fluxo de venda direta a partir de uma posicao do
  /// portfolio (vem com a quantidade total do holding).
  final int? initialQuantity;

  @override
  State<MiraOrderEntryPage> createState() => _MiraOrderEntryPageState();
}

class _MiraOrderEntryPageState extends State<MiraOrderEntryPage> {
  late int _quantity;
  OrderType _type = OrderType.market;
  late TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity ?? 100;
    final asset = MiraAssetsCatalog.byId(widget.assetId);
    _limitController = TextEditingController(
      text: (asset.currentPriceCents / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  int _effectivePriceCents() {
    if (_type == OrderType.market) {
      return MiraAssetsCatalog.byId(widget.assetId).currentPriceCents;
    }
    final raw = _limitController.text.replaceAll(',', '.').trim();
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) return 0;
    return (parsed * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final asset = MiraAssetsCatalog.byId(widget.assetId);
    final isBuy = widget.side == OrderSide.buy;
    final actionColor = isBuy ? colors.success : colors.error;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: MiraAppBar(title: '${widget.side.label} ${asset.symbol}'),
      body: MockBodyConstraint(
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final holding = state.holdingOf(asset.id);
            final maxSellable = holding?.quantity ?? 0;
            final priceCents = _effectivePriceCents();
            final totalCents = priceCents * _quantity;
            final canSubmit =
                priceCents > 0 &&
                _quantity > 0 &&
                (isBuy || _quantity <= maxSellable);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _AssetSummary(),
                        SizedBox(
                          height: context.responsive(
                            mobile: AppSpacing.lg,
                            desktop: AppSpacing.xl,
                          ),
                        ),
                        const _Label(text: 'Quantidade'),
                        const SizedBox(height: AppSpacing.sm),
                        _QuantityRow(
                          value: _quantity,
                          max: isBuy ? null : maxSellable,
                          onChanged: (v) => setState(() => _quantity = v),
                        ),
                        if (!isBuy && maxSellable > 0) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _QuickPicks(
                            max: maxSellable,
                            current: _quantity,
                            onPicked: (v) => setState(() => _quantity = v),
                          ),
                        ],
                        SizedBox(
                          height: context.responsive(
                            mobile: AppSpacing.lg,
                            desktop: AppSpacing.xl,
                          ),
                        ),
                        const _Label(text: 'Tipo de ordem'),
                        const SizedBox(height: AppSpacing.sm),
                        _TypeSegment(
                          selected: _type,
                          onChanged: (t) => setState(() => _type = t),
                        ),
                        if (_type == OrderType.limit) ...[
                          const SizedBox(height: AppSpacing.lg),
                          const _Label(text: r'Preco limite (R$)'),
                          const SizedBox(height: AppSpacing.sm),
                          _LimitPriceField(
                            controller: _limitController,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                        SizedBox(
                          height: context.responsive(
                            mobile: AppSpacing.lg,
                            desktop: AppSpacing.xl,
                          ),
                        ),
                        _TotalCard(
                          priceCents: priceCents,
                          quantity: _quantity,
                          totalCents: totalCents,
                          type: _type,
                        ),
                        if (!isBuy && maxSellable < _quantity) ...[
                          const SizedBox(height: AppSpacing.md),
                          _WarningBanner(
                            text:
                                'Você tem $maxSellable papéis dessa posição. '
                                'Ajuste a quantidade.',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _BottomConfirmBar(
                  label: '${widget.side.label} ${asset.symbol}',
                  color: actionColor,
                  enabled: canSubmit,
                  onSubmit: canSubmit
                      ? () => _submit(context, asset.symbol)
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context, String symbol) {
    final priceCents = _effectivePriceCents();
    context.read<FinanceBloc>().add(
      FinanceTradeExecuted(
        assetId: widget.assetId,
        side: widget.side,
        quantity: _quantity,
        priceCents: priceCents,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Ordem ${widget.side == OrderSide.buy ? 'de compra' : 'de venda'} '
            'enviada · $_quantity $symbol a ${formatMiraPrice(priceCents)}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    Navigator.of(context).popUntil((r) => r.isFirst);
  }
}
