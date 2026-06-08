import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/realestate/domain/property.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_bloc.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_event.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_state.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_brand.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_navigation.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_property_detail_page.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_property_illustration.dart';
import 'package:feature_showcase/src/shared/presentation/showcase_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'solar_property_card_widgets.dart';

/// Card de imovel reutilizado pela home e pela listagem. Layout
/// vertical: ilustracao no topo, headline em serif, bairro/cidade,
/// preco em destaque e stats (quartos / area / vagas). Botao de
/// favorito no canto da ilustracao.
class SolarPropertyCard extends StatelessWidget {
  const SolarPropertyCard({required this.property, super.key});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        key: Key('solar-property-card-${property.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => solarWithDemoBloc(
              context,
              SolarPropertyDetailPage(property: property),
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Illustration(property: property, colors: colors),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (property.headline.isNotEmpty)
                      Text(
                        property.headline,
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontFamily: SolarBrand.displayFontFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _locationLine(),
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      property.formattedPrice,
                      key: Key('solar-property-card-price-${property.id}'),
                      style: textTheme.titleLarge?.copyWith(
                        color: colors.primary,
                        fontFamily: SolarBrand.displayFontFamily,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StatsRow(property: property),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _locationLine() {
    if (property.city.isEmpty) return property.neighborhood;
    return '${property.neighborhood} · ${property.city}';
  }
}
