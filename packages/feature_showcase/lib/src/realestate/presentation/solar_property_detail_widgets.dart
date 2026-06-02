part of 'solar_property_detail_page.dart';

// =============================================================================
// GALERIA
// =============================================================================

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.property,
    required this.colors,
    required this.galleryIndex,
    required this.onChange,
  });

  final Property property;
  final AppColorScheme colors;
  final int galleryIndex;
  final ValueChanged<int> onChange;

  static const _labels = ['frente', 'lateral', 'topo'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: context.responsive(mobile: 1.95, desktop: 1.6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: ColoredBox(
              color: colors.surfaceMuted,
              child: SolarPropertyIllustration(
                key: ValueKey('solar-detail-illustration-$galleryIndex'),
                type: property.type,
                variant: galleryIndex,
                foregroundColor: colors.primary,
                accentColor: colors.accent,
                backgroundColor: colors.surface,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < _labels.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              _GalleryDot(
                key: Key('solar-gallery-dot-$i'),
                index: i,
                label: _labels[i],
                selected: galleryIndex == i,
                onTap: () => onChange(i),
                colors: colors,
                textTheme: textTheme,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _GalleryDot extends StatelessWidget {
  const _GalleryDot({
    required this.index,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.textTheme,
    super.key,
  });

  final int index;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: selected ? colors.onPrimary : colors.onSurfaceMuted,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HEADER + STATS
// =============================================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.property,
    required this.colors,
    required this.textTheme,
  });

  final Property property;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (property.city.isEmpty
                  ? property.neighborhood
                  : '${property.neighborhood} · ${property.city}')
              .toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          property.headline.isEmpty
              ? '${property.type.label} em ${property.neighborhood}'
              : property.headline,
          key: const Key('solar-detail-headline'),
          style: textTheme.headlineMedium?.copyWith(
            color: colors.onSurface,
            fontFamily: SolarBrand.displayFontFamily,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            height: 1.15,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          property.formattedPrice,
          key: const Key('solar-detail-price'),
          style: context
              .responsive(
                mobile: textTheme.headlineMedium,
                desktop: textTheme.displaySmall,
              )
              ?.copyWith(
                color: colors.primary,
                fontFamily: SolarBrand.displayFontFamily,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.property,
    required this.colors,
    required this.textTheme,
  });

  final Property property;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final entries = <_StatEntry>[
      if (property.bedrooms > 0)
        _StatEntry(
          icon: Icons.bed_outlined,
          value: '${property.bedrooms}',
          label: property.bedrooms == 1 ? 'quarto' : 'quartos',
        ),
      if (property.suites > 0)
        _StatEntry(
          icon: Icons.king_bed_outlined,
          value: '${property.suites}',
          label: property.suites == 1 ? 'suite' : 'suites',
        ),
      if (property.areaM2 > 0)
        _StatEntry(
          icon: Icons.square_foot_outlined,
          value: '${property.areaM2}',
          label: 'm² uteis',
        ),
      if (property.areaLandM2 > 0)
        _StatEntry(
          icon: Icons.crop_landscape_outlined,
          value: '${property.areaLandM2}',
          label: 'm² terreno',
        ),
      if (property.parkingSpots > 0)
        _StatEntry(
          icon: Icons.directions_car_outlined,
          value: '${property.parkingSpots}',
          label: property.parkingSpots == 1 ? 'vaga' : 'vagas',
        ),
    ];
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.md,
        children: [
          for (final e in entries)
            SizedBox(
              width: 92,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(e.icon, size: 18, color: colors.primary),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    e.value,
                    style: textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontFamily: SolarBrand.displayFontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    e.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatEntry {
  const _StatEntry({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
}

class _Description extends StatelessWidget {
  const _Description({
    required this.text,
    required this.colors,
    required this.textTheme,
  });

  final String text;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textTheme.bodyLarge?.copyWith(
        color: colors.onSurface,
        height: 1.55,
      ),
    );
  }
}

// =============================================================================
// FEATURES
// =============================================================================

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid({
    required this.property,
    required this.colors,
    required this.textTheme,
  });

  final Property property;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final f in property.features)
          Container(
            key: Key('solar-feature-${f.name}'),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SolarFeatureIcon(feature: f, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  f.label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// PLANTA BAIXA
// =============================================================================

class _FloorPlanCard extends StatelessWidget {
  const _FloorPlanCard({required this.property, required this.colors});

  final Property property;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: AspectRatio(
        aspectRatio: context.responsive(mobile: 1.9, desktop: 1.5),
        child: SolarFloorPlan(
          property: property,
          foregroundColor: colors.onSurface,
          accentColor: colors.accent,
          backgroundColor: colors.surface,
          wallColor: colors.primary,
        ),
      ),
    );
  }
}

// =============================================================================
// MAPA
// =============================================================================

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.property,
    required this.colors,
    required this.textTheme,
  });

  final Property property;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: context.responsive<double>(mobile: 2, desktop: 1.7),
            child: SolarNeighborhoodMap(
              propertySeed: solarMapSeedFor(property.id),
              blockColor: colors.surfaceMuted,
              streetColor: colors.border,
              parkColor: colors.accent.withValues(alpha: 0.50),
              pinColor: colors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(Icons.place_outlined, size: 18, color: colors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.neighborhood,
                        style: textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontFamily: SolarBrand.displayFontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (property.city.isNotEmpty)
                        Text(
                          property.city,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CORRETOR
// =============================================================================

class _BrokerCard extends StatelessWidget {
  const _BrokerCard({
    required this.broker,
    required this.colors,
    required this.textTheme,
  });

  final Broker broker;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          SolarBrokerAvatar(
            monogram: broker.monogram,
            size: 56,
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  broker.name,
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontFamily: SolarBrand.displayFontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  broker.creci,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  broker.phone,
                  style: textTheme.labelMedium?.copyWith(color: colors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
