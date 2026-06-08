import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_bloc.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_state.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_navigation.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_saved_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Botao de favoritos da app bar com badge de contagem. Abre a
/// `SolarSavedPage` via push interno. O badge so aparece quando ha ao
/// menos um favorito; reage ao `favoriteIds` do `RealEstateState`.
class SolarSavedAction extends StatelessWidget {
  const SolarSavedAction({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<RealEstateBloc, RealEstateState>(
      buildWhen: (a, b) => a.favoriteIds.length != b.favoriteIds.length,
      builder: (context, state) {
        final count = state.favoriteIds.length;
        return IconButton(
          key: const Key('solar-saved-action'),
          tooltip: 'Imoveis salvos',
          icon: _BadgeIcon(count: count, colors: colors),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => solarWithDemoBloc(context, const SolarSavedPage()),
            ),
          ),
        );
      },
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.count, required this.colors});

  final int count;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          count > 0 ? Icons.favorite : Icons.favorite_border,
          color: count > 0 ? colors.primary : colors.onSurface,
        ),
        if (count > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              key: const Key('solar-saved-badge'),
              constraints: const BoxConstraints(minWidth: 16),
              height: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: colors.background, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
