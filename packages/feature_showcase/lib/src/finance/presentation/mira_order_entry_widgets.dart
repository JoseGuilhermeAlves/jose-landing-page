part of 'mira_order_entry_page.dart';

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
            gradient: MiraBrand.litGlassGradient(colors.surface),
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
                  fontSize: context.responsive<double>(mobile: 20, desktop: 24),
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
  const _QuickPicks({
    required this.max,
    required this.current,
    required this.onPicked,
  });

  final int max;
  final int current;
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
            child: Builder(
              builder: (context) {
                // O pick que casa com a quantidade corrente fica ativo
                // em mint/primary — sinaliza selecao em vez de ler como
                // botao desabilitado cinza.
                final isSelected = opt.$2 > 0 && opt.$2 == current;
                return OutlinedButton(
                  onPressed: opt.$2 > 0 ? () => onPicked(opt.$2) : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isSelected
                        ? colors.primary
                        : colors.onSurfaceMuted,
                    backgroundColor: isSelected
                        ? colors.primary.withValues(alpha: 0.12)
                        : null,
                    side: BorderSide(
                      color: isSelected
                          ? colors.primary.withValues(alpha: 0.55)
                          : colors.border,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Text(
                    opt.$1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                );
              },
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
        gradient: MiraBrand.litGlassGradient(colors.surface),
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
