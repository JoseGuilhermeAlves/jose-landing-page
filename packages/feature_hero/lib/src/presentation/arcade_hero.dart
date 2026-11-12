import 'package:design_system/design_system.dart';
import 'package:feature_hero/src/presentation/black_hole_portrait.dart';
import 'package:feature_hero/src/presentation/horizon_floor.dart';
import 'package:flutter/material.dart';

/// Hero da landing — "title screen" enxuto. Duas colunas no desktop:
/// texto a esquerda (eyebrow, nome em fonte pixel, headline, escopo, CTAs,
/// dois numeros) e o retrato no buraco negro neon a direita. O chao Outrun
/// fica confinado ao rodape do hero ([HorizonFloor]).
///
/// Redesign 2026-11: sairam os planetas, galaxia e nebulosas (`HeroCosmos`)
/// e o halo preto do texto — com o fundo calmo, o texto le sozinho. A fonte
/// pixel ficou so no nome (assinatura); o resto e sans.
class ArcadeHero extends StatelessWidget {
  const ArcadeHero({
    required this.minHeight,
    this.onContactPressed,
    this.onSeeProjectsPressed,
    super.key,
  });

  /// Altura MINIMA do hero (geralmente uma viewport). Cresce se o conteudo
  /// nao couber — sem scroll interno.
  final double minHeight;

  final VoidCallback? onContactPressed;
  final VoidCallback? onSeeProjectsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = context.isMobile;
    final width = MediaQuery.sizeOf(context).width;

    final portrait = BlackHolePortrait(
      diskHot: colors.primary,
      diskCool: colors.accent,
      size: isMobile
          ? (width * 0.72).clamp(240.0, 340.0)
          : (width * 0.36).clamp(380.0, 560.0),
      diskScale: 0.75,
    );

    final copy = _HeroCopy(
      onContactPressed: onContactPressed,
      onSeeProjectsPressed: onSeeProjectsPressed,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: isMobile ? 120 : 180,
            child: HorizonFloor(near: colors.primary, far: colors.accent),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.responsive(
                  mobile: AppSpacing.lg,
                  desktop: AppSpacing.huge,
                ),
                context.responsive(mobile: 96, desktop: AppSpacing.huge),
                context.responsive(
                  mobile: AppSpacing.lg,
                  desktop: AppSpacing.huge,
                ),
                isMobile ? 140 : 200,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(child: IgnorePointer(child: portrait)),
                            const SizedBox(height: AppSpacing.lg),
                            copy,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 6, child: copy),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: IgnorePointer(child: portrait),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({this.onContactPressed, this.onSeeProjectsPressed});

  final VoidCallback? onContactPressed;
  final VoidCallback? onSeeProjectsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isMobile = context.isMobile;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, color: colors.accent),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                l10n.hero_eyebrow.toUpperCase(),
                style: tt.labelMedium?.copyWith(
                  color: colors.accent,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          header: true,
          label: 'Jose Guilherme Alves',
          child: ExcludeSemantics(
            child: PixelText(
              'JOSE\nGUILHERME ALVES',
              color: colors.primary,
              glowColor: colors.primary,
              glowBlur: 14,
              pixelSize: isMobile ? 3 : 6,
              lineSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          '${l10n.hero_headline1} ${l10n.hero_headline2}',
          style: (isMobile ? tt.headlineSmall : tt.headlineMedium)?.copyWith(
            color: colors.onSurface,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.hero_scopeLine,
          style: tt.bodyLarge?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            NeonButton(
              label: l10n.hero_ctaContact,
              filled: true,
              onPressed: onContactPressed,
            ),
            NeonButton(
              label: l10n.hero_ctaProjects,
              color: colors.accent,
              icon: Icons.arrow_downward_rounded,
              onPressed: onSeeProjectsPressed,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.md,
          children: [
            _Stat(
              value: l10n.hero_trustYearsValue,
              label: l10n.hero_trustYearsLabel,
            ),
            _Stat(
              value: l10n.hero_trustCanvasValue,
              label: l10n.hero_trustCanvasLabel,
            ),
          ],
        ),
      ],
    );
  }
}

/// Numero + rotulo, separados por um filete vertical a esquerda.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colors.primary.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: tt.headlineMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Text(
              label,
              style: tt.bodySmall?.copyWith(
                color: colors.onSurfaceMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
