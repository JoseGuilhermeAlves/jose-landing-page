import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/delivery/data/aurora_vendors_catalog.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_order.dart';
import 'package:feature_showcase/src/delivery/domain/market_category.dart';
import 'package:feature_showcase/src/delivery/domain/vendor.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_app_bar.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_brand.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_category_icon.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_delivery_map.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_hero_backdrop.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_history_page.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_navigation.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_order_detail_page.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_product_illustration.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_store_list_page.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_vendor_detail_page.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_bloc.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_event.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_state.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/presentation/mock_section_label.dart';
import 'package:feature_showcase/src/shared/presentation/showcase_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'aurora_home_widgets.dart';

/// Home da marca Aurora — entry point do demo. Composta por:
/// - hero com backdrop animado (ondulacoes verdes + folhas);
/// - card de "pedido ativo" (quando existe), com mini-mapa, ETA e
///   acesso ao detalhe completo;
/// - strip horizontal de categorias com glifos desenhados;
/// - lista de bancas em destaque (cards com ilustracao + ETA + frete);
/// - link discreto pra historico.
class AuroraHomePage extends StatelessWidget {
  const AuroraHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AuroraAppBar(
        leading: IconButton(
          key: const Key('aurora-close-demo'),
          tooltip: context.l10n.aurora_closeDemoTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            key: const Key('aurora-reset-icon'),
            tooltip: context.l10n.aurora_resetDemoTooltip,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<DeliveryBloc>().add(const DeliveryReset()),
          ),
          IconButton(
            key: const Key('aurora-history-icon'),
            tooltip: context.l10n.aurora_historyTooltip,
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    auroraWithDemoBloc(context, const AuroraHistoryPage()),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: MockBodyConstraint(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCard(colors: colors, textTheme: textTheme),
                SizedBox(
                  height: context.responsive(
                    mobile: AppSpacing.lg,
                    desktop: AppSpacing.xl,
                  ),
                ),
                BlocBuilder<DeliveryBloc, DeliveryState>(
                  builder: (context, state) {
                    final order = state.activeOrder;
                    if (order == null) {
                      return _NoActiveOrderCard(
                        colors: colors,
                        textTheme: textTheme,
                      );
                    }
                    return _ActiveOrderCard(
                      order: order,
                      colors: colors,
                      textTheme: textTheme,
                    );
                  },
                ),
                SizedBox(
                  height: context.responsive(
                    mobile: AppSpacing.lg,
                    desktop: AppSpacing.xl,
                  ),
                ),
                MockSectionLabel(
                  eyebrow: context.l10n.aurora_categoriesEyebrow,
                  title: context.l10n.aurora_categoriesTitle,
                  colors: colors,
                  textTheme: textTheme,
                  titleFontFamily: AuroraBrand.displayFontFamily,
                  titleFontWeight: FontWeight.w600,
                ),
                const SizedBox(height: AppSpacing.md),
                _CategoriesStrip(colors: colors, textTheme: textTheme),
                SizedBox(
                  height: context.responsive(
                    mobile: AppSpacing.lg,
                    desktop: AppSpacing.xl,
                  ),
                ),
                MockSectionLabel(
                  eyebrow: context.l10n.aurora_vendorsEyebrow,
                  title: context.l10n.aurora_vendorsTitle,
                  colors: colors,
                  textTheme: textTheme,
                  titleFontFamily: AuroraBrand.displayFontFamily,
                  titleFontWeight: FontWeight.w600,
                ),
                const SizedBox(height: AppSpacing.md),
                _VendorsList(colors: colors, textTheme: textTheme),
                SizedBox(
                  height: context.responsive(
                    mobile: AppSpacing.lg,
                    desktop: AppSpacing.xxl,
                  ),
                ),
                _AboutBlock(colors: colors, textTheme: textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
