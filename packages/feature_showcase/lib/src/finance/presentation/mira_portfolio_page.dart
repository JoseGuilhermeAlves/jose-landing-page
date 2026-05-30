import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/finance/data/mira_assets_catalog.dart';
import 'package:feature_showcase/src/finance/domain/asset.dart';
import 'package:feature_showcase/src/finance/domain/portfolio_holding.dart';
import 'package:feature_showcase/src/finance/presentation/finance_bloc.dart';
import 'package:feature_showcase/src/finance/presentation/finance_state.dart';
import 'package:feature_showcase/src/finance/presentation/mira_allocation_donut.dart';
import 'package:feature_showcase/src/finance/presentation/mira_app_bar.dart';
import 'package:feature_showcase/src/finance/presentation/mira_asset_detail_page.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/presentation/mira_change_pill.dart';
import 'package:feature_showcase/src/finance/presentation/mira_navigation.dart';
import 'package:feature_showcase/src/finance/util/mira_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela do portfolio — donut de alocacao + lista de posicoes com PnL
/// colorido por holding. Tap em qualquer posicao abre o detalhe do
/// ativo correspondente. Quando o portfolio esta vazio, mostra um
/// empty state convidando a abrir a primeira posicao.
class MiraPortfolioPage extends StatelessWidget {
  const MiraPortfolioPage({super.key});

  static const List<Color> _slicePalette = [
    Color(0xFF22C55E),
    Color(0xFF60A5FA),
    Color(0xFFF59E0B),
    Color(0xFFA78BFA),
    Color(0xFFEF4444),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: const MiraAppBar(title: 'Meu portfolio'),
      body: MockBodyConstraint(
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state.holdings.isEmpty) {
              return const _EmptyPortfolio();
            }

            final marketValue = state.marketValueCents;
            final slices = <MiraAllocationSlice>[];
            final holdingViews = <_HoldingView>[];

            for (var i = 0; i < state.holdings.length; i++) {
              final h = state.holdings[i];
              final asset = MiraAssetsCatalog.findById(h.assetId);
              if (asset == null) continue;
              final color = _slicePalette[i % _slicePalette.length];
              final mv = h.marketValueCents(asset.currentPriceCents);
              final weight = marketValue == 0 ? 0.0 : mv / marketValue;
              slices.add(
                MiraAllocationSlice(
                  label: asset.symbol,
                  weight: weight,
                  color: color,
                ),
              );
              holdingViews.add(
                _HoldingView(
                  holding: h,
                  asset: asset,
                  marketValueCents: mv,
                  weight: weight,
                  color: color,
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MiraAllocationDonut(slices: slices, totalCents: marketValue),
                  const SizedBox(height: AppSpacing.xxl),
                  _PortfolioStatsRow(state: state),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionTitle(text: 'Posicoes'),
                  const SizedBox(height: AppSpacing.md),
                  ...holdingViews.map((v) => _HoldingRow(view: v)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

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
        color: colors.surface,
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
  const _SectionTitle({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      text,
      style: TextStyle(
        color: colors.onSurfaceMuted,
        fontSize: 11,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w800,
      ),
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
