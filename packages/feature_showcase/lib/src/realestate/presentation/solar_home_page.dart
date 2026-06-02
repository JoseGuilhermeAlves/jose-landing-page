import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/presentation/mock_section_label.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_bloc.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_event.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_state.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_app_bar.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_brand.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_hero_backdrop.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_listings_page.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_navigation.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_property_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'solar_home_widgets.dart';

/// Home da marca Solar — entry point do demo de imobiliaria. Composta
/// por hero com backdrop animado (morros + sol + particulas), chips
/// de bairros pra busca rapida e grid de imoveis em destaque (4
/// propriedades). CTA "Ver todos" empurra a `SolarListingsPage`.
class SolarHomePage extends StatelessWidget {
  const SolarHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: SolarAppBar(
        leading: IconButton(
          key: const Key('solar-close-demo'),
          tooltip: context.l10n.solar_closeDemoTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
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
                const SizedBox(height: AppSpacing.xl),
                MockSectionLabel(
                  eyebrow: context.l10n.solar_neighborhoodsEyebrow,
                  title: context.l10n.solar_neighborhoodsTitle,
                  colors: colors,
                  textTheme: textTheme,
                  titleFontFamily: SolarBrand.displayFontFamily,
                  titleFontWeight: FontWeight.w600,
                ),
                const SizedBox(height: AppSpacing.md),
                const _NeighborhoodStrip(),
                const SizedBox(height: AppSpacing.xl),
                MockSectionLabel(
                  eyebrow: context.l10n.solar_featuredEyebrow,
                  title: context.l10n.solar_featuredTitle,
                  colors: colors,
                  textTheme: textTheme,
                  titleFontFamily: SolarBrand.displayFontFamily,
                  titleFontWeight: FontWeight.w600,
                ),
                const SizedBox(height: AppSpacing.md),
                const _FeaturedList(),
                const SizedBox(height: AppSpacing.xxl),
                _AboutBlock(colors: colors, textTheme: textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
