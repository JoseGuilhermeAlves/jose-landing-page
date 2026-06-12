import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_bloc.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_event.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_state.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_app_bar.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_brand.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_property_card.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_saved_action.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'solar_listings_widgets.dart';

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
                onPressed: () => context.read<RealEstateBloc>().add(
                  const RealEstateFiltersCleared(),
                ),
                child: const Text('Limpar filtros'),
              );
            },
          ),
          const SolarSavedAction(),
        ],
      ),
      body: MockBodyConstraint(
        child: SafeArea(
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
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Text(
                              _countLabel(list.length),
                              key: const Key('solar-results-count'),
                              style: Theme.of(context).textTheme.labelMedium
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
      ),
    );
  }

  static String _countLabel(int n) {
    if (n == 1) return '1 imovel encontrado';
    return '$n imoveis encontrados';
  }
}
