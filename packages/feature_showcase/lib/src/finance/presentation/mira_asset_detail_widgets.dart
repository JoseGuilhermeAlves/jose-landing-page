part of 'mira_asset_detail_page.dart';

class _AssetHeader extends StatelessWidget {
  const _AssetHeader({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                asset.sector.label,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                asset.name,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatMiraPrice(asset.currentPriceCents),
              style: textTheme.displaySmall?.copyWith(
                color: colors.onSurface,
                fontFamily: MiraBrand.monoFontFamily,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: MiraChangePill(changeBps: asset.dailyChangeBps),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'Cotacao em tempo real · ${formatMiraVolume(_simulatedTodayVolume(asset))} negociados hoje',
            style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceMuted),
          ),
        ),
      ],
    );
  }

  /// Volume "do dia" simulado — derivado do change para parecer
  /// consistente sem expor dados internos do candles catalog.
  int _simulatedTodayVolume(Asset asset) {
    const base = 1500000;
    final boost = asset.dailyChangeBps.abs() * 4500;
    return base + boost;
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.candles});

  final List<Candle> candles;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: MiraBrand.litGlassGradient(colors.surface),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Row(
              children: [
                Text(
                  '60 dias · diario',
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                Text(
                  'Toque pra ver OHLC',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          MiraCandlestickChart(
            candles: candles,
            height: context.responsive<double>(mobile: 210, desktop: 260),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final candles = MiraCandlesCatalog.forAsset(asset.id);
    if (candles.isEmpty) return const SizedBox.shrink();

    var minLow = candles.first.lowCents;
    var maxHigh = candles.first.highCents;
    var sumVolume = 0;
    for (final c in candles) {
      if (c.lowCents < minLow) minLow = c.lowCents;
      if (c.highCents > maxHigh) maxHigh = c.highCents;
      sumVolume += c.volume;
    }
    final avgVolume = (sumVolume / candles.length).round();
    final last = candles.last;

    final stats = [
      ('Abertura', formatMiraPrice(last.openCents)),
      ('Maxima', formatMiraPrice(last.highCents)),
      ('Minima', formatMiraPrice(last.lowCents)),
      ('Vol. medio', formatMiraVolume(avgVolume)),
      ('Max 60d', formatMiraPrice(maxHigh)),
      ('Min 60d', formatMiraPrice(minLow)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive(mobile: 2, desktop: 3),
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.8,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) {
        final s = stats[i];
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.$1,
                style: TextStyle(
                  color: colors.onSurfaceMuted,
                  fontSize: 10,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.$2,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
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

class _MyPositionCard extends StatelessWidget {
  const _MyPositionCard({required this.asset, required this.state});

  final Asset asset;
  final FinanceState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final holding = state.holdingOf(asset.id)!;
    final pnl = holding.unrealizedPnlCents(asset.currentPriceCents);
    final pnlColor = pnl >= 0 ? colors.success : colors.error;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: MiraBrand.litGlassGradient(colors.surface),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MINHA POSICAO',
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _PositionStat(
                  label: 'Quantidade',
                  value: holding.quantity.toString(),
                ),
              ),
              Expanded(
                child: _PositionStat(
                  label: 'Preco medio',
                  value: formatMiraPrice(holding.avgPriceCents),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _PositionStat(
                  label: 'Valor de mercado',
                  value: formatMiraTotal(
                    holding.marketValueCents(asset.currentPriceCents),
                  ),
                ),
              ),
              Expanded(
                child: _PositionStat(
                  label: 'Resultado',
                  value: '${pnl >= 0 ? '+' : ''}${formatMiraTotal(pnl.abs())}',
                  valueColor: pnlColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PositionStat extends StatelessWidget {
  const _PositionStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 10,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: MiraBrand.monoFontFamily,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _BottomCtaBar extends StatelessWidget {
  const _BottomCtaBar({required this.asset});

  final Asset asset;

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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const Key('mira-cta-sell'),
                onPressed: () => _openOrder(context, OrderSide.sell),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text(
                  'Vender',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                key: const Key('mira-cta-buy'),
                onPressed: () => _openOrder(context, OrderSide.buy),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.success,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Comprar',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openOrder(BuildContext context, OrderSide side) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => miraWithDemoBloc(
          context,
          MiraOrderEntryPage(assetId: asset.id, side: side),
        ),
      ),
    );
  }
}
