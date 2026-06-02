import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/presentation/mock_section_label.dart';
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

part 'solar_property_detail_widgets.dart';

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
                tooltip: isFav
                    ? 'Remover dos favoritos'
                    : 'Salvar nos favoritos',
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? colors.primary : colors.onSurface,
                ),
                onPressed: () => context.read<RealEstateBloc>().add(
                  RealEstateFavoriteToggled(property.id),
                ),
              );
            },
          ),
        ],
      ),
      body: MockBodyConstraint(
        child: SafeArea(
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
                _Header(
                  property: property,
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.lg),
                _StatsCard(
                  property: property,
                  colors: colors,
                  textTheme: textTheme,
                ),
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
                  MockSectionLabel(
                    eyebrow: 'Caracteristicas',
                    title: 'O que o imovel oferece',
                    colors: colors,
                    textTheme: textTheme,
                    titleFontFamily: SolarBrand.displayFontFamily,
                    titleFontWeight: FontWeight.w600,
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
                  MockSectionLabel(
                    eyebrow: 'Planta baixa',
                    title: 'Planta esquematica do imovel',
                    colors: colors,
                    textTheme: textTheme,
                    titleFontFamily: SolarBrand.displayFontFamily,
                    titleFontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FloorPlanCard(property: property, colors: colors),
                ],
                const SizedBox(height: AppSpacing.xl),
                MockSectionLabel(
                  eyebrow: 'Localizacao',
                  title: 'Onde fica',
                  colors: colors,
                  textTheme: textTheme,
                  titleFontFamily: SolarBrand.displayFontFamily,
                  titleFontWeight: FontWeight.w600,
                ),
                const SizedBox(height: AppSpacing.md),
                _MapCard(
                  property: property,
                  colors: colors,
                  textTheme: textTheme,
                ),
                if (broker != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  MockSectionLabel(
                    eyebrow: 'Corretor responsavel',
                    title: 'Quem te acompanha',
                    colors: colors,
                    textTheme: textTheme,
                    titleFontFamily: SolarBrand.displayFontFamily,
                    titleFontWeight: FontWeight.w600,
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
      ),
    );
  }
}
