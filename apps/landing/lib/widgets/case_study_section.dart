import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class CaseStudySection extends StatelessWidget {
  const CaseStudySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(
          eyebrow: context.l10n.caseStudy_eyebrow,
          title: context.l10n.caseStudy_title,
          titleAccent: context.l10n.caseStudy_titleAccent,
          subtitle: context.l10n.caseStudy_subtitle,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _HeroBlock(isMobile: isMobile),
        const SizedBox(height: AppSpacing.xxl),
        _PainterShowcase(isMobile: isMobile),
        const SizedBox(height: AppSpacing.xxl),
        _DecisionsGrid(isMobile: isMobile),
        const SizedBox(height: AppSpacing.xxl),
        const _ClosingTakeaway(),
      ],
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final narrative = _Narrative();
    final preview = _CosmosLivePreview();
    if (isMobile) {
      return Column(
        children: [
          preview,
          const SizedBox(height: AppSpacing.lg),
          narrative,
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 6, child: narrative),
          const SizedBox(width: AppSpacing.xl),
          Expanded(flex: 4, child: preview),
        ],
      ),
    );
  }
}

class _Narrative extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.caseStudy_pivotEyebrow,
            style: tt.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.caseStudy_pivotTitle,
            style: tt.headlineSmall?.copyWith(
              color: colors.onSurface,
              height: 1.2,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Paragraph(context.l10n.caseStudy_pivotPara1),
          const SizedBox(height: AppSpacing.md),
          _Paragraph(context.l10n.caseStudy_pivotPara2),
          const SizedBox(height: AppSpacing.md),
          _Paragraph(context.l10n.caseStudy_pivotPara3),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceMuted,
        height: 1.6,
      ),
    );
  }
}

class _CosmosLivePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08080B),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF26262F)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: RepaintBoundary(
              child: CosmosField(
                planets: const [
                  CosmosPlanet(
                    id: 'case-study-hero',
                    canvasAnchor: Offset(0.50, 0.45),
                    radiusPixels: 48,
                    pattern: PlanetPattern.bands,
                    seed: 42,
                    palette: [
                      Color(0xFF0A0420),
                      Color(0xFF2E1466),
                      Color(0xFF6B40E0),
                      Color(0xFFB89BFF),
                      Color(0xFFE6DCFF),
                    ],
                    ring: PlanetRing(
                      innerRadiusPixels: 62,
                      outerRadiusPixels: 82,
                      color: Color(0xCC9D6BFF),
                      tiltY: 0.22,
                    ),
                    moon: PlanetMoon(
                      orbitRadiusPixels: 70,
                      moonRadiusPixels: 6,
                      color: Color(0xFFE6DCFF),
                      phaseOffset: 0.3,
                    ),
                  ),
                  CosmosPlanet(
                    id: 'case-study-small',
                    canvasAnchor: Offset(0.22, 0.70),
                    radiusPixels: 18,
                    pattern: PlanetPattern.speckled,
                    seed: 7,
                    palette: [
                      Color(0xFF1A0008),
                      Color(0xFF7A0E2A),
                      Color(0xFFFF1F44),
                      Color(0xFFFF6679),
                      Color(0xFFFFDADE),
                    ],
                  ),
                  CosmosPlanet(
                    id: 'case-study-ice',
                    canvasAnchor: Offset(0.80, 0.25),
                    radiusPixels: 14,
                    pattern: PlanetPattern.hemispheres,
                    seed: 11,
                    palette: [
                      Color(0xFF010E1A),
                      Color(0xFF0A446A),
                      Color(0xFF0AC4FF),
                      Color(0xFF7FE9FF),
                      Color(0xFFE8FBFF),
                    ],
                  ),
                ],
                nebulas: const [
                  CosmosNebula(
                    canvasAnchor: Offset(0.75, 0.60),
                    radiusPixels: 70,
                    color: Color(0xFFFF2D95),
                    density: 0.5,
                    seed: 3,
                  ),
                ],
                pulsars: const [
                  CosmosPulsar(
                    canvasAnchor: Offset(0.15, 0.30),
                    coreColor: Color(0xFF0AC4FF),
                    beamColor: Color(0xFF0AC4FF),
                    beamLengthPixels: 35,
                    beamWidthRadians: 0.08,
                    phaseOffset: 0.2,
                    seed: 5,
                  ),
                ],
                starColor: colors.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text(
                  context.l10n.caseStudy_recoveryLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF7E7E8A),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.caseStudy_recoveryHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFF2F2F5),
                    height: 1.5,
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

class _PainterShowcase extends StatelessWidget {
  const _PainterShowcase({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cards = [
      _PainterCard(
        title: context.l10n.caseStudy_painterStrainTitle,
        caption: context.l10n.caseStudy_painterStrainCaption,
        child: SizedBox(
          height: 200,
          child: RepaintBoundary(
            child: CosmosField(
              planets: const [
                CosmosPlanet(
                  id: 'layers-demo',
                  canvasAnchor: Offset(0.50, 0.50),
                  radiusPixels: 42,
                  pattern: PlanetPattern.bands,
                  seed: 211,
                  palette: [
                    Color(0xFF0A0420),
                    Color(0xFF2E1466),
                    Color(0xFF6B40E0),
                    Color(0xFFB89BFF),
                    Color(0xFFE6DCFF),
                  ],
                  ring: PlanetRing(
                    innerRadiusPixels: 56,
                    outerRadiusPixels: 74,
                    color: Color(0xCC9D6BFF),
                    tiltY: 0.22,
                  ),
                ),
              ],
              starColor: colors.primary,
            ),
          ),
        ),
      ),
      _PainterCard(
        title: context.l10n.caseStudy_painterTempoTitle,
        caption: context.l10n.caseStudy_painterTempoCaption,
        child: SizedBox(
          height: 200,
          child: RepaintBoundary(
            child: CosmosField(
              galaxies: const [
                CosmosGalaxy(
                  canvasAnchor: Offset(0.50, 0.50),
                  radiusPixels: 60,
                  coreColor: Color(0xFFFFE0B2),
                  armColor: Color(0xFF9D6BFF),
                  armCount: 3,
                  tiltY: 0.55,
                  rotation: 0.3,
                  dustCount: 200,
                  seed: 42,
                ),
              ],
              starColor: colors.primary,
            ),
          ),
        ),
      ),
      _PainterCard(
        title: context.l10n.caseStudy_painterPeriodTitle,
        caption: context.l10n.caseStudy_painterPeriodCaption,
        child: SizedBox(
          height: 200,
          child: RepaintBoundary(
            child: ConstellationField(
              constellations: const [KnownConstellations.cruzeiroDoSul],
              starColor: colors.onSurface,
              linkColor: colors.primary.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    ];
    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            cards[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: cards[1]),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: cards[2]),
        ],
      ),
    );
  }
}

class _PainterCard extends StatelessWidget {
  const _PainterCard({
    required this.title,
    required this.caption,
    required this.child,
  });

  final String title;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08080B),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF26262F)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(image: true, label: '$title: $caption', child: child),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF2F2F5),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: const TextStyle(
              color: Color(0xFF7E7E8A),
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionsGrid extends StatelessWidget {
  const _DecisionsGrid({required this.isMobile});
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final decisions = [
      _DecisionCard(
        eyebrow: l10n.caseStudy_decisionArchEyebrow,
        title: l10n.caseStudy_decisionArchTitle,
        body: l10n.caseStudy_decisionArchBody,
      ),
      _DecisionCard(
        eyebrow: l10n.caseStudy_decisionPaintersEyebrow,
        title: l10n.caseStudy_decisionPaintersTitle,
        body: l10n.caseStudy_decisionPaintersBody,
      ),
      _DecisionCard(
        eyebrow: l10n.caseStudy_decisionStateEyebrow,
        title: l10n.caseStudy_decisionStateTitle,
        body: l10n.caseStudy_decisionStateBody,
      ),
    ];
    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < decisions.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            decisions[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: decisions[0]),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: decisions[1]),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: decisions[2]),
        ],
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            eyebrow,
            style: tt.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosingTakeaway extends StatelessWidget {
  const _ClosingTakeaway();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.12),
            colors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.caseStudy_takeawayEyebrow,
            style: tt.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.caseStudy_takeawayTitle,
            style: tt.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.caseStudy_takeawayBody,
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
