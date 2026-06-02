import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/finance/data/mira_assets_catalog.dart';
import 'package:feature_showcase/src/finance/data/mira_candles_catalog.dart';
import 'package:feature_showcase/src/finance/domain/asset.dart';
import 'package:feature_showcase/src/finance/domain/candle.dart';
import 'package:feature_showcase/src/finance/domain/order_side.dart';
import 'package:feature_showcase/src/finance/presentation/finance_bloc.dart';
import 'package:feature_showcase/src/finance/presentation/finance_state.dart';
import 'package:feature_showcase/src/finance/presentation/mira_app_bar.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/presentation/mira_candlestick_chart.dart';
import 'package:feature_showcase/src/finance/presentation/mira_change_pill.dart';
import 'package:feature_showcase/src/finance/presentation/mira_navigation.dart';
import 'package:feature_showcase/src/finance/presentation/mira_order_entry_page.dart';
import 'package:feature_showcase/src/finance/util/mira_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'mira_asset_detail_widgets.dart';

/// Detalhe do ativo — destaca o **MiraCandlestickChart** (o painter de
/// destaque tecnico do mock). Composta por:
/// - cabecalho com simbolo + nome + setor + preco + variacao;
/// - candlestick com crosshair interativo (tap/drag mostra OHLC);
/// - grid de estatisticas (open/high/low/volume + minha posicao);
/// - bottom sticky com CTAs Vender (red outlined) e Comprar (green
///   filled), ambos abrindo `MiraOrderEntryPage`.
class MiraAssetDetailPage extends StatelessWidget {
  const MiraAssetDetailPage({required this.assetId, super.key});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final asset = MiraAssetsCatalog.byId(assetId);
    final candles = MiraCandlesCatalog.forAsset(assetId);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: MiraAppBar(title: asset.symbol),
      body: MockBodyConstraint(
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final holding = state.holdingOf(assetId);
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AssetHeader(asset: asset),
                        const SizedBox(height: AppSpacing.xl),
                        _ChartCard(candles: candles),
                        const SizedBox(height: AppSpacing.xl),
                        _StatsGrid(asset: asset),
                        if (holding != null) ...[
                          const SizedBox(height: AppSpacing.xl),
                          _MyPositionCard(asset: asset, state: state),
                        ],
                      ],
                    ),
                  ),
                ),
                _BottomCtaBar(asset: asset),
              ],
            );
          },
        ),
      ),
    );
  }
}
