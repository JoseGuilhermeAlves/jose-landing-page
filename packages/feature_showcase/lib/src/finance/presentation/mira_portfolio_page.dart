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

part 'mira_portfolio_widgets.dart';

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
                  SizedBox(
                    height: context.isMobile ? AppSpacing.xl : AppSpacing.xxl,
                  ),
                  _PortfolioStatsRow(state: state),
                  SizedBox(
                    height: context.isMobile ? AppSpacing.lg : AppSpacing.xl,
                  ),
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
