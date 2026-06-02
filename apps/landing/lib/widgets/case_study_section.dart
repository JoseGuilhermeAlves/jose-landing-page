import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing/router/route_paths.dart';
import 'package:landing/widgets/case_study_cosmos.dart';

/// Teaser do estudo de caso na home. Antes era uma secao longa (hero
/// narrativo + 3 cards de painter com planetas aninhados + 3 decisoes +
/// takeaway) — informacao demais pro scroll. Agora e um convite curto: um
/// cosmos vivo + gancho + CTA que leva pra pagina `/estudo`, onde o estudo
/// completo (planetas, painters, decisoes) tem espaco pra respirar.
class CaseStudySection extends StatelessWidget {
  const CaseStudySection({super.key});

  @override
  Widget build(BuildContext context) {
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
        SizedBox(
          height: context.responsive(
            mobile: AppSpacing.lg,
            desktop: AppSpacing.xl,
          ),
        ),
        const _CosmosTeaserCard(),
      ],
    );
  }
}

/// Card unico: cosmos vivo de fundo + scrim + gancho + CTA. O card
/// inteiro e tappable (alem do botao) pra abrir `/estudo`.
class _CosmosTeaserCard extends StatelessWidget {
  const _CosmosTeaserCard();

  void _open(BuildContext context) => context.push(RoutePaths.caseStudy);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final height = context.responsive<double>(mobile: 300, desktop: 380);

    return Semantics(
      button: true,
      label: context.l10n.caseStudy_ctaExplore,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: const Key('case-study-teaser'),
          onTap: () => _open(context),
          child: Container(
            height: height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: const Color(0xFF26262F)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cosmos vivo de fundo — os mesmos painters do hero.
                ColoredBox(
                  color: const Color(0xFF08080B),
                  child: RepaintBoundary(
                    child: CosmosField(
                      planets: CaseStudyCosmos.heroPlanets,
                      nebulas: CaseStudyCosmos.heroNebulas,
                      pulsars: CaseStudyCosmos.heroPulsars,
                      starColor: colors.primary,
                    ),
                  ),
                ),
                // Scrim pra leitura do texto sobreposto no rodape.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xD9050507)],
                      stops: [0.3, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.caseStudy_recoveryLabel,
                        style: tt.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Text(
                          context.l10n.caseStudy_recoveryHint,
                          style: tt.titleMedium?.copyWith(
                            color: const Color(0xFFF2F2F5),
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        key: const Key('case-study-cta'),
                        label: context.l10n.caseStudy_ctaExplore,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => _open(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
