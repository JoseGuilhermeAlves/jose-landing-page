import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/finance/data/mira_assets_catalog.dart';
import 'package:feature_showcase/src/finance/domain/asset.dart';
import 'package:feature_showcase/src/finance/presentation/finance_bloc.dart';
import 'package:feature_showcase/src/finance/presentation/finance_event.dart';
import 'package:feature_showcase/src/finance/presentation/finance_state.dart';
import 'package:feature_showcase/src/finance/presentation/mira_app_bar.dart';
import 'package:feature_showcase/src/finance/presentation/mira_asset_detail_page.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/presentation/mira_change_pill.dart';
import 'package:feature_showcase/src/finance/presentation/mira_hero_backdrop.dart';
import 'package:feature_showcase/src/finance/presentation/mira_navigation.dart';
import 'package:feature_showcase/src/finance/presentation/mira_portfolio_page.dart';
import 'package:feature_showcase/src/finance/presentation/mira_portfolio_sparkline.dart';
import 'package:feature_showcase/src/finance/presentation/mira_ticker_tape.dart';
import 'package:feature_showcase/src/finance/presentation/mira_trade_history_page.dart';
import 'package:feature_showcase/src/finance/util/mira_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'mira_home_widgets.dart';

/// Home da marca Mira — entry point do demo. Composta por:
/// - **AppBar dark** + actions pra portfolio e historico;
/// - **ticker tape** continuo logo abaixo do AppBar (estilo trading
///   platform — strip que scrolla pra esquerda);
/// - **hero block** com backdrop animado (`MiraHeroBackdrop` —
///   grid Bloomberg + sparkline ghost + glow dots) sobre o qual flutua
///   o card de patrimonio com sparkline de 30 dias;
/// - **section "Watchlist"** com headers em eyebrow + line;
/// - **section "Outros ativos"** com o resto do catalogo.
class MiraHomePage extends StatelessWidget {
  const MiraHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: MiraAppBar(
        title: 'Mira',
        leading: IconButton(
          key: const Key('mira-close-demo'),
          tooltip: context.l10n.mira_closeDemoTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            key: const Key('mira-portfolio-icon'),
            tooltip: context.l10n.mira_portfolioTooltip,
            icon: const Icon(Icons.pie_chart_outline_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    miraWithDemoBloc(context, const MiraPortfolioPage()),
              ),
            ),
          ),
          IconButton(
            key: const Key('mira-history-icon'),
            tooltip: context.l10n.mira_historyTooltip,
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    miraWithDemoBloc(context, const MiraTradeHistoryPage()),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: MockBodyConstraint(
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            final favoriteIds = state.favoriteIds;
            final watchlist = MiraAssetsCatalog.all
                .where((a) => favoriteIds.contains(a.id))
                .toList();
            final others = MiraAssetsCatalog.all
                .where((a) => !favoriteIds.contains(a.id))
                .toList();
            final isMobile = context.isMobile;

            return Column(
              children: [
                const MiraTickerTape(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PortfolioHero(state: state),
                        SizedBox(
                          height: isMobile ? AppSpacing.xl : AppSpacing.xxl,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SectionHeader(
                                eyebrow: context.l10n.mira_watchlistEyebrow,
                                title: context.l10n.mira_watchlistTitle,
                                count: null,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (watchlist.isEmpty)
                                const _EmptyFavoritesNote()
                              else
                                ...watchlist.map(
                                  (a) => _AssetRow(asset: a, isFavorite: true),
                                ),
                              SizedBox(
                                height: isMobile
                                    ? AppSpacing.xl
                                    : AppSpacing.xxl,
                              ),
                              _SectionHeader(
                                eyebrow: context.l10n.mira_catalogEyebrow,
                                title: context.l10n.mira_otherAssetsTitle,
                                count: others.length,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ...others.map(
                                (a) => _AssetRow(asset: a, isFavorite: false),
                              ),
                              SizedBox(
                                height: isMobile
                                    ? AppSpacing.xl
                                    : AppSpacing.xxl,
                              ),
                              const _BrandFootnote(),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
