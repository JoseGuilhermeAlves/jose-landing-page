part of 'mira_portfolio_page.dart';

class _PortfolioStatsRow extends StatelessWidget {
  const _PortfolioStatsRow({required this.state});

  final FinanceState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pnl = state.unrealizedPnlCents;
    final pnlBps = state.unrealizedPnlBps;
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
            child: _Stat(
              label: 'CUSTO',
              value: formatMiraTotal(state.costBasisCents),
            ),
          ),
          Container(width: 1, height: 40, color: colors.border),
          Expanded(
            child: _Stat(
              label: 'RESULTADO',
              value: '${pnl >= 0 ? '+' : ''}${formatMiraTotal(pnl.abs())}',
              valueColor: pnl >= 0 ? colors.success : colors.error,
              trailing: MiraChangePill(changeBps: pnlBps, compact: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: MiraBrand.monoFontFamily,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (trailing != null) ...[const SizedBox(height: 4), trailing!],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, this.count});
  final String text;
  final int? count;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MiraBrand.neonMint.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            count.toString().padLeft(2, '0'),
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: MiraBrand.monoFontFamily,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }
}

class _HoldingView {
  const _HoldingView({
    required this.holding,
    required this.asset,
    required this.marketValueCents,
    required this.weight,
    required this.color,
  });
  final PortfolioHolding holding;
  final Asset asset;
  final int marketValueCents;
  final double weight;
  final Color color;
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow({required this.view});

  final _HoldingView view;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final pnl = view.holding.unrealizedPnlCents(view.asset.currentPriceCents);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          key: Key('mira-holding-row-${view.asset.id}'),
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => miraWithDemoBloc(
                context,
                MiraAssetDetailPage(assetId: view.asset.id),
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              gradient: MiraBrand.litGlassGradient(colors.surface),
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 38,
                  decoration: BoxDecoration(
                    color: view.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            view.asset.symbol,
                            style: textTheme.titleSmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                              fontFamily: MiraBrand.monoFontFamily,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${(view.weight * 100).toStringAsFixed(1).replaceAll('.', ',')}%',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceMuted,
                              fontFamily: MiraBrand.monoFontFamily,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${view.holding.quantity} × ${formatMiraPrice(view.holding.avgPriceCents)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceMuted,
                          fontFamily: MiraBrand.monoFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMiraTotal(view.marketValueCents),
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                        fontFamily: MiraBrand.monoFontFamily,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pnl >= 0 ? '+' : ''}${formatMiraTotal(pnl.abs())}',
                      style: textTheme.bodySmall?.copyWith(
                        color: pnl >= 0 ? colors.success : colors.error,
                        fontWeight: FontWeight.w700,
                        fontFamily: MiraBrand.monoFontFamily,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SellPositionButton(view: view),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botao "Vender" de uma posicao — abre o form de ordem ja como venda,
/// pre-preenchido com a quantidade total do holding. Fecha o gap de
/// nao ter como vender direto a partir do portfolio (antes so dava pra
/// chegar no form passando pelo detalhe do ativo).
class _SellPositionButton extends StatelessWidget {
  const _SellPositionButton({required this.view});

  final _HoldingView view;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OutlinedButton(
      key: Key('mira-sell-position-${view.asset.id}'),
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => miraWithDemoBloc(
            context,
            MiraOrderEntryPage(
              assetId: view.asset.id,
              side: OrderSide.sell,
              initialQuantity: view.holding.quantity,
            ),
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error.withValues(alpha: 0.6)),
        visualDensity: VisualDensity.compact,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Vender',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 48,
              color: colors.onSurfaceMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sem posições ainda',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Abra sua primeira ordem na aba "Mira" pra ver o donut por aqui.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}
