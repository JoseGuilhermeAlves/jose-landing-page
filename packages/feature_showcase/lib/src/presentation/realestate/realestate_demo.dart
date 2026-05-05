import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/properties_catalog.dart';
import 'package:feature_showcase/src/domain/property.dart';
import 'package:feature_showcase/src/domain/property_type.dart';
import 'package:feature_showcase/src/presentation/realestate/realestate_bloc.dart';
import 'package:feature_showcase/src/presentation/realestate/realestate_event.dart';
import 'package:feature_showcase/src/presentation/realestate/realestate_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela do mock de imobiliaria. Filtros (bairro, quartos, preco max)
/// no topo + grid de cards de imoveis. Sem backend — lista filtrada
/// e derivada do state.
class RealEstateDemo extends StatelessWidget {
  const RealEstateDemo({this.properties, super.key});

  /// Override do catalogo. Quando null, usa [PropertiesCatalog.all].
  final List<Property>? properties;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => RealEstateBloc(
        initialProperties: properties ?? PropertiesCatalog.all,
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              title: Text('Imoveis disponiveis', style: textTheme.titleLarge),
              actions: [
                BlocBuilder<RealEstateBloc, RealEstateState>(
                  builder: (context, state) {
                    if (!state.hasActiveFilters) return const SizedBox.shrink();
                    return TextButton(
                      key: const Key('realestate-clear-filters'),
                      onPressed: () => context
                          .read<RealEstateBloc>()
                          .add(const RealEstateFiltersCleared()),
                      child: const Text('Limpar filtros'),
                    );
                  },
                ),
              ],
            ),
            body: const SafeArea(
              child: Column(
                children: [
                  _Filters(),
                  Expanded(child: _PropertiesList()),
                ],
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bairro',
            style: textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _NeighborhoodChips(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Quartos',
            style: textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _BedroomChips(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Preco maximo',
            style: textTheme.labelLarge?.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
          const _PriceSlider(),
        ],
      ),
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
              _FilterChip(
                key: Key('realestate-neighborhood-chip-$n'),
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

  // Buckets: 1, 2, 3, 4+. Mais que isso vira ruido visual.
  static const List<int> _buckets = [1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealEstateBloc, RealEstateState>(
      builder: (context, state) {
        return Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final n in _buckets)
              _FilterChip(
                key: Key('realestate-bedroom-chip-$n'),
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

  // Range de 200 mil a 1.5 milhao em reais — cobre o catalogo.
  static const int minCents = 20000000;
  static const int maxCents = 150000000;
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
            Slider(
              key: const Key('realestate-price-slider'),
              value: current.toDouble().clamp(
                    minCents.toDouble(),
                    maxCents.toDouble(),
                  ),
              min: minCents.toDouble(),
              max: maxCents.toDouble(),
              divisions: divisions,
              activeColor: colors.primary,
              inactiveColor: colors.surfaceMuted,
              onChanged: (value) {
                final rounded = value.round();
                final eventValue = rounded >= maxCents ? null : rounded;
                context
                    .read<RealEstateBloc>()
                    .add(RealEstateMaxPriceChanged(eventValue));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                isCapped
                    ? 'sem teto'
                    : 'ate ${_formatPrice(current)}',
                key: const Key('realestate-price-label'),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
          ),
        ),
      ),
    );
  }
}

class _PropertiesList extends StatelessWidget {
  const _PropertiesList();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<RealEstateBloc, RealEstateState>(
      builder: (context, state) {
        final list = state.filtered;

        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: colors.onSurfaceMuted,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Nenhum imovel com esses filtros',
                    style: textTheme.titleMedium
                        ?.copyWith(color: colors.onSurface),
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
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Text(
                      _countLabel(list.length),
                      key: const Key('realestate-results-count'),
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < list.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                _PropertyCard(property: list[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _countLabel(int n) {
    if (n == 1) return '1 imovel';
    return '$n imoveis';
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      key: const Key('realestate-property-card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PhotoPlaceholder(type: property.type, colors: colors),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property.neighborhood,
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      _formatPrice(property.priceCents),
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  property.type.label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _IconStat(
                      icon: Icons.bed_outlined,
                      label: '${property.bedrooms} '
                          '${property.bedrooms == 1 ? 'quarto' : 'quartos'}',
                    ),
                    _IconStat(
                      icon: Icons.square_foot_outlined,
                      label: '${property.areaM2} m²',
                    ),
                    _IconStat(
                      icon: Icons.directions_car_outlined,
                      label: '${property.parkingSpots} '
                          '${property.parkingSpots == 1 ? 'vaga' : 'vagas'}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.type, required this.colors});

  final PropertyType type;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        type == PropertyType.house
            ? Icons.home_outlined
            : Icons.apartment_outlined,
        color: colors.primary,
        size: 28,
      ),
    );
  }
}

class _IconStat extends StatelessWidget {
  const _IconStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(color: colors.onSurfaceMuted),
        ),
      ],
    );
  }
}

/// Formata preco em centavos como "R$ X.XXX.XXX". Mantemos no
/// arquivo do demo pra nao expor um util generico antes da hora.
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
