import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
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
          tooltip: 'Fechar demo',
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
                _SectionLabel(
                  eyebrow: 'Bairros',
                  title: 'Por onde voce procura',
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                const _NeighborhoodStrip(),
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(
                  eyebrow: 'Em destaque',
                  title: 'Selecionados a mao',
                  colors: colors,
                  textTheme: textTheme,
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

// =============================================================================
// HERO
// =============================================================================

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.colors, required this.textTheme});

  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surface, colors.surfaceMuted],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            Positioned.fill(
              child: SolarHeroBackdrop(
                skyColor: colors.surface,
                hillColor: colors.accent.withValues(alpha: 0.40),
                sunColor: colors.primary,
                particleColor: colors.primary.withValues(alpha: 0.45),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'imobiliaria · interior de sao paulo',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    SolarBrand.tagline,
                    style: textTheme.displaySmall?.copyWith(
                      color: colors.onSurface,
                      fontFamily: SolarBrand.displayFontFamily,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Casas, chacaras, terrenos e apartamentos em cidades '
                    'do interior — com curadoria, planta baixa e corretor '
                    'local em cada anuncio.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    key: const Key('solar-cta-listings'),
                    label: 'Ver imoveis',
                    icon: Icons.arrow_forward_rounded,
                    size: AppButtonSize.large,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => solarWithDemoBloc(
                          context,
                          const SolarListingsPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// BAIRROS
// =============================================================================

class _NeighborhoodStrip extends StatelessWidget {
  const _NeighborhoodStrip();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealEstateBloc, RealEstateState>(
      // Deriva bairros do catalogo injetado no bloc — assim o demo
      // respeita o override de `RealEstateDemo(properties:)` em
      // testes / sandboxes, e fica consistente com os chips do
      // filtro da listagem.
      buildWhen: (a, b) =>
          a.selectedNeighborhood != b.selectedNeighborhood ||
          a.allProperties != b.allProperties,
      builder: (context, state) {
        final seen = <String>{};
        final neighborhoods = <String>[
          for (final p in state.allProperties)
            if (seen.add(p.neighborhood)) p.neighborhood,
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              for (var i = 0; i < neighborhoods.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                _NeighborhoodChip(
                  name: neighborhoods[i],
                  selected: state.selectedNeighborhood == neighborhoods[i],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _NeighborhoodChip extends StatelessWidget {
  const _NeighborhoodChip({required this.name, required this.selected});

  final String name;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      key: Key('solar-home-neighborhood-$name'),
      onTap: () {
        context.read<RealEstateBloc>().add(
          RealEstateNeighborhoodSelected(name),
        );
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                solarWithDemoBloc(context, const SolarListingsPage()),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(
          name,
          style: textTheme.labelMedium?.copyWith(
            color: selected ? colors.onPrimary : colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EM DESTAQUE
// =============================================================================

class _FeaturedList extends StatelessWidget {
  const _FeaturedList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealEstateBloc, RealEstateState>(
      // Featured saem do allProperties (catalogo via bloc) pra refletir
      // qualquer override de propriedades passado ao demo.
      buildWhen: (a, b) => a.allProperties != b.allProperties,
      builder: (context, state) {
        final featured = state.allProperties.take(4).toList();
        return Column(
          children: [
            for (var i = 0; i < featured.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              SolarPropertyCard(property: featured[i]),
            ],
          ],
        );
      },
    );
  }
}

// =============================================================================
// SOBRE
// =============================================================================

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.colors, required this.textTheme});

  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sobre a Solar',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontFamily: SolarBrand.displayFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Imobiliaria pequena, com corretores locais que visitam o '
            'imovel antes de listar. Cada anuncio tem planta baixa '
            'esquematica e mapa do bairro pra voce ter ideia do entorno '
            'antes do primeiro contato.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION LABEL
// =============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.eyebrow,
    required this.title,
    required this.colors,
    required this.textTheme,
  });

  final String eyebrow;
  final String title;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontFamily: SolarBrand.displayFontFamily,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
