import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/realestate/domain/property.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_bloc.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_state.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_app_bar.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_brand.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_property_card.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela de imoveis salvos (favoritos) — surfacea o `favoriteIds` do
/// `RealEstateState`, que ate entao so era escrito mas nunca lido numa
/// tela propria. Reutiliza o `SolarPropertyCard` (com botao de favorito
/// inline, entao o usuario pode remover daqui mesmo). Acessivel pela
/// action de coracao na app bar da home/listagem.
///
/// Sem novos eventos no bloc: a lista deriva de `state.favoriteIds`
/// cruzado com `state.allProperties`. Remover um favorito daqui dispara
/// o `RealEstateFavoriteToggled` ja existente (via card), e a tela
/// reage automaticamente — quando esvazia, mostra o empty state.
class SolarSavedPage extends StatelessWidget {
  const SolarSavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const SolarAppBar(),
      body: MockBodyConstraint(
        child: SafeArea(
          top: false,
          child: BlocBuilder<RealEstateBloc, RealEstateState>(
            // So reconstroi quando o set de favoritos muda.
            buildWhen: (a, b) => a.favoriteIds != b.favoriteIds,
            builder: (context, state) {
              final saved = <Property>[
                for (final p in state.allProperties)
                  if (state.isFavorite(p.id)) p,
              ];
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _SavedHeader(
                      count: saved.length,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                  ),
                  if (saved.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptySaved(colors: colors, textTheme: textTheme),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.xxl,
                      ),
                      sliver: SliverList.separated(
                        itemCount: saved.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) =>
                            SolarPropertyCard(property: saved[index]),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SavedHeader extends StatelessWidget {
  const _SavedHeader({
    required this.count,
    required this.colors,
    required this.textTheme,
  });

  final int count;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'favoritos'.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.accent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Imoveis que voce salvou',
            key: const Key('solar-saved-title'),
            style: textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontFamily: SolarBrand.displayFontFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            count == 0
                ? 'Toque no coracao de qualquer imovel pra guardar aqui.'
                : count == 1
                ? '1 imovel guardado pra ver depois.'
                : '$count imoveis guardados pra ver depois.',
            key: const Key('solar-saved-count'),
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

class _EmptySaved extends StatelessWidget {
  const _EmptySaved({required this.colors, required this.textTheme});

  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        context.responsive(mobile: AppSpacing.xl, desktop: AppSpacing.xxl),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 48,
            color: colors.onSurfaceMuted,
            key: const Key('solar-saved-empty'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nenhum imovel salvo ainda',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontFamily: SolarBrand.displayFontFamily,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Os imoveis que voce favoritar aparecem nesta lista.',
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
