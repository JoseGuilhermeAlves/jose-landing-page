part of 'solar_property_card.dart';

class _Illustration extends StatelessWidget {
  const _Illustration({required this.property, required this.colors});

  final Property property;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: context.responsive(mobile: 2.2, desktop: 1.7),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: colors.surfaceMuted,
                // Foto de capa quando ha asset; cai no painter da
                // silhueta enquanto os .webp nao existem.
                child: ShowcasePhoto(
                  assetPath: property.coverPhoto,
                  semanticLabel: property.headline.isEmpty
                      ? 'Foto do imovel em ${property.neighborhood}'
                      : property.headline,
                  fallback: SolarPropertyIllustration(
                    type: property.type,
                    foregroundColor: colors.primary,
                    accentColor: colors.accent,
                    backgroundColor: colors.surface,
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: _FavoriteButton(property: property),
            ),
            if (property.photosCount > 0)
              Positioned(
                bottom: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _PhotosBadge(
                  count: property.photosCount,
                  colors: colors,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<RealEstateBloc, RealEstateState>(
      buildWhen: (a, b) =>
          a.isFavorite(property.id) != b.isFavorite(property.id),
      builder: (context, state) {
        final isFav = state.isFavorite(property.id);
        return Material(
          color: colors.surface.withValues(alpha: 0.9),
          shape: const CircleBorder(),
          child: IconButton(
            key: Key('solar-favorite-${property.id}'),
            tooltip: isFav ? 'Remover dos favoritos' : 'Salvar nos favoritos',
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? colors.primary : colors.onSurfaceMuted,
            ),
            onPressed: () => context.read<RealEstateBloc>().add(
              RealEstateFavoriteToggled(property.id),
            ),
          ),
        );
      },
    );
  }
}

class _PhotosBadge extends StatelessWidget {
  const _PhotosBadge({required this.count, required this.colors});

  final int count;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_camera_outlined,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '$count fotos',
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final stats = <_Stat>[
      if (property.bedrooms > 0)
        _Stat(
          icon: Icons.bed_outlined,
          label:
              '${property.bedrooms} '
              '${property.bedrooms == 1 ? "quarto" : "quartos"}',
        ),
      if (property.areaM2 > 0)
        _Stat(icon: Icons.square_foot_outlined, label: '${property.areaM2} m²'),
      if (property.areaLandM2 > 0 && property.areaM2 == 0)
        _Stat(
          icon: Icons.crop_landscape_outlined,
          label: '${property.areaLandM2} m²',
        ),
      if (property.parkingSpots > 0)
        _Stat(
          icon: Icons.directions_car_outlined,
          label:
              '${property.parkingSpots} '
              '${property.parkingSpots == 1 ? "vaga" : "vagas"}',
        ),
    ];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final s in stats)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(s.icon, size: 14, color: colors.onSurfaceMuted),
              const SizedBox(width: AppSpacing.xs),
              Text(
                s.label,
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _Stat {
  const _Stat({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
