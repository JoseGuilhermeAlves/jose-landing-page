import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_bloc.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_event.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_state.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_app_bar.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_brand.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_property_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Listagem completa de imoveis Solar com filtros (bairro, quartos,
/// preco maximo) no topo + grid responsivo. Substitui a tela unica do
/// demo antigo — agora vive empurrada via push pela home.
class SolarListingsPage extends StatelessWidget {
  const SolarListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: SolarAppBar(
        actions: [
          BlocBuilder<RealEstateBloc, RealEstateState>(
            buildWhen: (a, b) => a.hasActiveFilters != b.hasActiveFilters,
            builder: (context, state) {
              if (!state.hasActiveFilters) return const SizedBox.shrink();
              return TextButton(
                key: const Key('solar-clear-filters'),
                onPressed: () => context
                    .read<RealEstateBloc>()
                    .add(const RealEstateFiltersCleared()),
                child: const Text('Limpar filtros'),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _ListingsHeader()),
            const SliverToBoxAdapter(child: _Filters()),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: BlocBuilder<RealEstateBloc, RealEstateState>(
                builder: (context, state) {
                  final list = state.filtered;
                  if (list.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyState(colors: colors),
                    );
                  }
                  return SliverList.separated(
                    itemCount: list.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Text(
                            _countLabel(list.length),
                            key: const Key('solar-results-count'),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: colors.onSurfaceMuted),
                          ),
                        );
                      }
                      return SolarPropertyCard(property: list[index - 1]);
                    },
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }

  static String _countLabel(int n) {
    if (n == 1) return '1 imovel encontrado';
    return '$n imoveis encontrados';
  }
}

class _ListingsHeader extends StatelessWidget {
  const _ListingsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'catalogo'.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.accent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Imoveis em curadoria',
            style: textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontFamily: SolarBrand.displayFontFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Casas, chacaras, terrenos e apartamentos selecionados a mao.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterLabel('Bairro', colors: colors, textTheme: textTheme),
          const SizedBox(height: AppSpacing.sm),
          const _NeighborhoodChips(),
          const SizedBox(height: AppSpacing.md),
          _FilterLabel('Quartos', colors: colors, textTheme: textTheme),
          const SizedBox(height: AppSpacing.sm),
          const _BedroomChips(),
          const SizedBox(height: AppSpacing.md),
          _FilterLabel('Preco maximo', colors: colors, textTheme: textTheme),
          const _PriceSlider(),
        ],
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.label, {required this.colors, required this.textTheme});
  final String label;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: textTheme.labelLarge?.copyWith(color: colors.onSurfaceMuted),
    );
  }
}

class _NeighborhoodChips extends StatelessWidget {
  const _NeighborhoodChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealEstateBloc, RealEstateState>(
      builder: (context, state) {
        final neighborhoods = <String>{
          for (final p in state.allProperties) p.neighborhood,
        }.toList();
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final n in neighborhoods)
              _SolarFilterChip(
                key: Key('solar-neighborhood-chip-$n'),
                label: n,
                selected: state.selectedNeighborhood == n,
                onTap: () => context
                    .read<RealEstateBloc>()
                    .add(RealEstateNeighborhoodSelected(n)),
              ),
          ],
        );
      },
    );
  }
}

class _BedroomChips extends StatelessWidget {
  const _BedroomChips();

  static const List<int> _buckets = [1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealEstateBloc, RealEstateState>(
      builder: (context, state) {
        return Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final n in _buckets)
              _SolarFilterChip(
                key: Key('solar-bedroom-chip-$n'),
                label: n == 4 ? '4+' : '$n',
                selected: state.selectedBedrooms == n,
                onTap: () => context
                    .read<RealEstateBloc>()
                    .add(RealEstateBedroomsSelected(n)),
              ),
          ],
        );
      },
    );
  }
}

class _PriceSlider extends StatelessWidget {
  const _PriceSlider();

  // Cobre 200k a 2.5M, granularidade de 50k.
  static const int minCents = 20000000;
  static const int maxCents = 250000000;
  static const int stepCents = 5000000;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<RealEstateBloc, RealEstateState>(
      builder: (context, state) {
        final current = state.maxPriceCents ?? maxCents;
        final divisions = ((maxCents - minCents) / stepCents).round();
        final isCapped = state.maxPriceCents == null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: colors.primary,
                inactiveTrackColor: colors.surfaceMuted,
                thumbColor: colors.primary,
                overlayColor: colors.primary.withValues(alpha: 0.15),
              ),
              child: Slider(
                key: const Key('solar-price-slider'),
                value: current.toDouble().clamp(
                      minCents.toDouble(),
                      maxCents.toDouble(),
                    ),
                min: minCents.toDouble(),
                max: maxCents.toDouble(),
                divisions: divisions,
                onChanged: (value) {
                  final rounded = value.round();
                  final eventValue = rounded >= maxCents ? null : rounded;
                  context
                      .read<RealEstateBloc>()
                      .add(RealEstateMaxPriceChanged(eventValue));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                isCapped ? 'sem teto' : 'ate ${_formatPrice(current)}',
                key: const Key('solar-price-label'),
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SolarFilterChip extends StatelessWidget {
  const _SolarFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: selected ? colors.onPrimary : colors.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});

  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: colors.onSurfaceMuted),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nenhum imovel com esses filtros',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontFamily: SolarBrand.displayFontFamily,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tente afrouxar bairro, quartos ou preco maximo.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _formatPrice(int cents) {
  final reais = cents ~/ 100;
  final buf = StringBuffer();
  final s = reais.toString();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'R\$ $buf';
}
