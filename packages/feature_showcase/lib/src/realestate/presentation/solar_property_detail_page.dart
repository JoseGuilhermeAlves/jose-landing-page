import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/realestate/data/solar_brokers_catalog.dart';
import 'package:feature_showcase/src/realestate/domain/broker.dart';
import 'package:feature_showcase/src/realestate/domain/property.dart';
import 'package:feature_showcase/src/realestate/domain/property_type.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_bloc.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_event.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_state.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_app_bar.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_brand.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_broker_avatar.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_contact_page.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_feature_icon.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_floor_plan.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_navigation.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_neighborhood_map.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_property_illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela de detalhe do imovel Solar. Composta por galeria de 3 angulos
/// (variants do `SolarPropertyIllustration`), headline em serif,
/// preco em destaque, descricao editorial, grid de features com
/// glifos desenhados, planta baixa esquematica (destaque tecnico),
/// mapa do bairro, card do corretor e CTA "Falar com o corretor".
class SolarPropertyDetailPage extends StatefulWidget {
  const SolarPropertyDetailPage({required this.property, super.key});

  final Property property;

  @override
  State<SolarPropertyDetailPage> createState() =>
      _SolarPropertyDetailPageState();
}

class _SolarPropertyDetailPageState extends State<SolarPropertyDetailPage> {
  int _galleryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final property = widget.property;
    final broker = SolarBrokersCatalog.byId(property.brokerId);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: SolarAppBar(
        actions: [
          BlocBuilder<RealEstateBloc, RealEstateState>(
            buildWhen: (a, b) =>
                a.isFavorite(property.id) != b.isFavorite(property.id),
            builder: (context, state) {
              final isFav = state.isFavorite(property.id);
              return IconButton(
                key: const Key('solar-detail-favorite'),
                tooltip:
                    isFav ? 'Remover dos favoritos' : 'Salvar nos favoritos',
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? colors.primary : colors.onSurface,
                ),
                onPressed: () => context
                    .read<RealEstateBloc>()
                    .add(RealEstateFavoriteToggled(property.id)),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Gallery(
                property: property,
                colors: colors,
                galleryIndex: _galleryIndex,
                onChange: (i) => setState(() => _galleryIndex = i),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Header(property: property, colors: colors, textTheme: textTheme),
              const SizedBox(height: AppSpacing.lg),
              _StatsCard(property: property, colors: colors, textTheme: textTheme),
              if (property.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _Description(
                  text: property.description,
                  colors: colors,
                  textTheme: textTheme,
                ),
              ],
              if (property.features.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(
                  eyebrow: 'Caracteristicas',
                  title: 'O que o imovel oferece',
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                _FeaturesGrid(
                  property: property,
                  colors: colors,
                  textTheme: textTheme,
                ),
              ],
              if (property.type != PropertyType.land) ...[
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(
                  eyebrow: 'Planta baixa',
                  title: 'Planta esquematica do imovel',
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                _FloorPlanCard(property: property, colors: colors),
              ],
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(
                eyebrow: 'Localizacao',
                title: 'Onde fica',
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.md),
              _MapCard(
                property: property,
                colors: colors,
                textTheme: textTheme,
              ),
              if (broker != null) ...[
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(
                  eyebrow: 'Corretor responsavel',
                  title: 'Quem te acompanha',
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                _BrokerCard(
                  broker: broker,
                  colors: colors,
                  textTheme: textTheme,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              BlocBuilder<RealEstateBloc, RealEstateState>(
                buildWhen: (a, b) =>
                    a.hasSentContact(property.id) !=
                    b.hasSentContact(property.id),
                builder: (context, state) {
                  final sent = state.hasSentContact(property.id);
                  return AppButton(
                    key: const Key('solar-detail-contact-cta'),
                    label: sent
                        ? 'Pedido enviado · ver detalhes'
                        : 'Falar com o corretor',
                    icon: sent ? Icons.check_rounded : Icons.send_rounded,
                    size: AppButtonSize.large,
                    expand: true,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => solarWithDemoBloc(
                          context,
                          SolarContactPage(property: property),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          aspectRatio: 1.6,
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
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
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
          style: textTheme.displaySmall?.copyWith(
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
  const _StatEntry({required this.icon, required this.value, required this.label});
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
        aspectRatio: 1.5,
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
            aspectRatio: 1.7,
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
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.accent,
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
// SECTION LABEL (reusada em varias secoes)
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
