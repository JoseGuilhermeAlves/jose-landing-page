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

/// Form de envio de ordem (compra ou venda) do ativo. Estado local
/// segura quantidade, tipo (mercado/limitada) e preco limite quando
/// aplicavel. Submit dispara `FinanceTradeExecuted` e volta pra home
/// do demo.
class MiraOrderEntryPage extends StatefulWidget {
  const MiraOrderEntryPage({
    required this.assetId,
    required this.side,
    super.key,
  });

  final String assetId;
  final OrderSide side;

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
    _quantity = 100;
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
                        const SizedBox(height: AppSpacing.xl),
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
                            onPicked: (v) => setState(() => _quantity = v),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
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
                        const SizedBox(height: AppSpacing.xl),
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

class _AssetSummary extends StatelessWidget {
  const _AssetSummary();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final route = ModalRoute.of(context);
    if (route is! ModalRoute) return const SizedBox.shrink();
    // Pega o asset id via Provider/state — caller monta com mira_navigation
    // que ja injeta o bloc. Pegamos do state pra ler o preco corrente.
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        final orderPage = context
            .findAncestorWidgetOfExactType<MiraOrderEntryPage>();
        if (orderPage == null) return const SizedBox.shrink();
        final asset = MiraAssetsCatalog.byId(orderPage.assetId);
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.symbol,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                        fontFamily: MiraBrand.monoFontFamily,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      asset.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatMiraPrice(asset.currentPriceCents),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  fontFamily: MiraBrand.monoFontFamily,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      text,
      style: TextStyle(
        color: colors.onSurfaceMuted,
        fontSize: 11,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int? max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    void delta(int by) {
      final next = (value + by).clamp(1, max ?? 99999);
      onChanged(next);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('mira-qty-minus'),
            tooltip: 'Diminuir',
            onPressed: value > 1 ? () => delta(-10) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          Expanded(
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: MiraBrand.monoFontFamily,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          IconButton(
            key: const Key('mira-qty-plus'),
            tooltip: 'Aumentar',
            onPressed: () => delta(10),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _QuickPicks extends StatelessWidget {
  const _QuickPicks({required this.max, required this.onPicked});

  final int max;
  final ValueChanged<int> onPicked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final options = <(String, int)>[
      ('25%', (max * 0.25).round()),
      ('50%', (max * 0.5).round()),
      ('75%', (max * 0.75).round()),
      ('MAX', max),
    ];
    return Row(
      children: [
        for (final opt in options) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: opt.$2 > 0 ? () => onPicked(opt.$2) : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.onSurfaceMuted,
                side: BorderSide(color: colors.border),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: Text(
                opt.$1,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          if (opt != options.last) const SizedBox(width: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({required this.selected, required this.onChanged});

  final OrderType selected;
  final ValueChanged<OrderType> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          for (final t in OrderType.values)
            Expanded(
              child: GestureDetector(
                key: Key('mira-type-${t.name}'),
                onTap: () => onChanged(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: t == selected ? colors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: t == selected
                        ? Border.all(color: colors.border)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t.label,
                    style: TextStyle(
                      color: t == selected
                          ? colors.onSurface
                          : colors.onSurfaceMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LimitPriceField extends StatelessWidget {
  const _LimitPriceField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      key: const Key('mira-limit-price-input'),
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
      style: TextStyle(
        color: colors.onSurface,
        fontFamily: MiraBrand.monoFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.priceCents,
    required this.quantity,
    required this.totalCents,
    required this.type,
  });

  final int priceCents;
  final int quantity;
  final int totalCents;
  final OrderType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _TotalRow(
            label: type == OrderType.market ? 'Preco' : 'Preco limite',
            value: formatMiraPrice(priceCents),
          ),
          const SizedBox(height: AppSpacing.xs),
          _TotalRow(label: 'Quantidade', value: '× $quantity'),
          const Divider(height: AppSpacing.lg),
          _TotalRow(
            label: 'Total',
            value: formatMiraTotal(totalCents),
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: emphasize ? 14 : 12,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: emphasize ? 0.6 : 0,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: emphasize ? 18 : 14,
            fontWeight: FontWeight.w800,
            fontFamily: MiraBrand.monoFontFamily,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: colors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colors.error, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomConfirmBar extends StatelessWidget {
  const _BottomConfirmBar({
    required this.label,
    required this.color,
    required this.enabled,
    required this.onSubmit,
  });

  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const Key('mira-confirm-order'),
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              disabledBackgroundColor: colors.surfaceMuted,
              foregroundColor: colors.onPrimary,
              disabledForegroundColor: colors.onSurfaceMuted,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              elevation: 0,
            ),
            child: Text(
              enabled ? label : 'Ajuste a ordem',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
