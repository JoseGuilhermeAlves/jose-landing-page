import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/realestate/domain/broker.dart';
import 'package:feature_showcase/src/realestate/domain/property.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_bloc.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_state.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_app_bar.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_brand.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_contact_page.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_navigation.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_property_card.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/presentation/showcase_monogram_avatar.dart';
import 'package:feature_showcase/src/shared/presentation/showcase_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Perfil do corretor Solar — antes os corretores eram um beco sem saida
/// (apareciam no card do imovel mas nao abriam nada). Esta tela mostra
/// headshot (real via [ShowcasePhoto], com fallback pro monograma),
/// bio editorial, stats (anos de atuacao + imoveis na carteira) e a
/// lista de imoveis que o corretor atende — derivada de
/// `state.allProperties` cruzada com `brokerId`. CTA reaproveita a
/// `SolarContactPage` apontando pro primeiro imovel da carteira.
class SolarBrokerPage extends StatelessWidget {
  const SolarBrokerPage({required this.broker, super.key});

  final Broker broker;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: const Key('solar-broker-page'),
      backgroundColor: colors.background,
      appBar: const SolarAppBar(),
      body: MockBodyConstraint(
        child: SafeArea(
          top: false,
          child: BlocBuilder<RealEstateBloc, RealEstateState>(
            buildWhen: (a, b) => a.allProperties != b.allProperties,
            builder: (context, state) {
              final listings = <Property>[
                for (final p in state.allProperties)
                  if (p.brokerId == broker.id) p,
              ];
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _BrokerHeader(
                      broker: broker,
                      listingCount: listings.length,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                  ),
                  if (listings.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.sm,
                        ),
                        child: Text(
                          'Carteira de imoveis',
                          key: const Key('solar-broker-listings'),
                          style: textTheme.titleMedium?.copyWith(
                            color: colors.onSurface,
                            fontFamily: SolarBrand.displayFontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      sliver: SliverList.separated(
                        itemCount: listings.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) =>
                            SolarPropertyCard(property: listings[index]),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xxl,
                      ),
                      child: AppButton(
                        key: const Key('solar-broker-contact-cta'),
                        label: 'Falar com ${broker.name}',
                        icon: Icons.send_rounded,
                        size: AppButtonSize.large,
                        expand: true,
                        onPressed: listings.isEmpty
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => solarWithDemoBloc(
                                    context,
                                    SolarContactPage(property: listings.first),
                                  ),
                                ),
                              ),
                      ),
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

class _BrokerHeader extends StatelessWidget {
  const _BrokerHeader({
    required this.broker,
    required this.listingCount,
    required this.colors,
    required this.textTheme,
  });

  final Broker broker;
  final int listingCount;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: ShowcasePhoto(
                    assetPath: broker.photoAsset,
                    semanticLabel: 'Foto de ${broker.name}',
                    width: 84,
                    height: 84,
                    fallback: ShowcaseMonogramAvatar(
                      monogram: broker.monogram,
                      size: 84,
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      fontFamily: SolarBrand.displayFontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      broker.name,
                      key: const Key('solar-broker-name'),
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontFamily: SolarBrand.displayFontFamily,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (broker.role.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        broker.role,
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.accent,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      broker.creci,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _BrokerStat(
                value: broker.yearsActive > 0 ? '${broker.yearsActive}' : '—',
                label: 'anos atuando',
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(width: AppSpacing.xl),
              _BrokerStat(
                value: '$listingCount',
                label: listingCount == 1 ? 'imovel' : 'imoveis',
                colors: colors,
                textTheme: textTheme,
              ),
            ],
          ),
          if (broker.bio.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              broker.bio,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceMuted,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BrokerStat extends StatelessWidget {
  const _BrokerStat({
    required this.value,
    required this.label,
    required this.colors,
    required this.textTheme,
  });

  final String value;
  final String label;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            color: colors.onSurface,
            fontFamily: SolarBrand.displayFontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceMuted),
        ),
      ],
    );
  }
}
