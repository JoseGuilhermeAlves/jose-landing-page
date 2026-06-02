import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/case_study_cosmos.dart';

/// Galeria de cenas isoladas — cada painter sozinho pra mostrar a tecnica
/// por tras: planeta em camadas, galaxia espiral em `drawPoints`, e
/// constelacoes nomeadas. Desktop em linha, mobile empilhado. As cenas
/// reusam os catalogos de `CaseStudyCosmos`, isolando cada tipo de corpo
/// (listas vazias desligam os demais).
class CaseStudyScenes extends StatelessWidget {
  const CaseStudyScenes({required this.isMobile, super.key});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final canvasHeight = context.responsive<double>(mobile: 200, desktop: 260);

    final scenes = <Widget>[
      _SceneCard(
        title: l10n.caseStudy_painterStrainTitle,
        caption: l10n.caseStudy_painterStrainCaption,
        canvasHeight: canvasHeight,
        scene: CosmosField(
          planets: CaseStudyCosmos.layersPlanets,
          nebulas: const [],
          galaxies: const [],
          pulsars: const [],
          asteroidBelts: const [],
          wisps: const [],
          comet: null,
          shootingStars: const [],
          starColor: colors.primary,
        ),
      ),
      _SceneCard(
        title: l10n.caseStudy_painterTempoTitle,
        caption: l10n.caseStudy_painterTempoCaption,
        canvasHeight: canvasHeight,
        scene: CosmosField(
          planets: const [],
          nebulas: const [],
          galaxies: CaseStudyCosmos.spiralGalaxies,
          pulsars: const [],
          asteroidBelts: const [],
          wisps: const [],
          comet: null,
          shootingStars: const [],
          starColor: colors.primary,
        ),
      ),
      _SceneCard(
        title: l10n.caseStudy_painterPeriodTitle,
        caption: l10n.caseStudy_painterPeriodCaption,
        canvasHeight: canvasHeight,
        scene: ConstellationField(
          constellations: const [KnownConstellations.cruzeiroDoSul],
          starColor: colors.onSurface,
          linkColor: colors.primary.withValues(alpha: 0.35),
        ),
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < scenes.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            scenes[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < scenes.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            Expanded(child: scenes[i]),
          ],
        ],
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  const _SceneCard({
    required this.title,
    required this.caption,
    required this.canvasHeight,
    required this.scene,
  });

  final String title;
  final String caption;
  final double canvasHeight;
  final Widget scene;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08080B),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF26262F)),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            image: true,
            label: '$title: $caption',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                height: canvasHeight,
                width: double.infinity,
                child: RepaintBoundary(child: scene),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF2F2F5),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            caption,
            style: const TextStyle(
              color: Color(0xFF9A9AA6),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
