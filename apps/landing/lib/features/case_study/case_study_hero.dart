import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Hero full-bleed da pagina de estudo: o cosmos default (todos os 7
/// tipos de corpo) pintado ao vivo, constelacoes nomeadas por cima e
/// scrim pra leitura do titulo. Botao voltar flutua no topo-esquerdo.
class CaseStudyHero extends StatelessWidget {
  const CaseStudyHero({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final isMobile = context.isMobile;
    final height = context.responsive<double>(mobile: 460, desktop: 560);
    final hPad = context.responsive(
      mobile: AppSpacing.lg,
      desktop: AppSpacing.huge,
    );

    final headlineStyle = (isMobile ? tt.displaySmall : tt.displayMedium)
        ?.copyWith(color: colors.onSurface, height: 1.05, letterSpacing: -0.6);

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cosmos default ao vivo — prova tecnica em primeira pessoa.
          ColoredBox(
            color: const Color(0xFF050507),
            child: RepaintBoundary(
              child: CosmosField(starColor: colors.primary),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: ConstellationField()),
          ),
          // Scrim: escurece topo (pro back button) e rodape (pro texto).
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xAA050507),
                  Color(0x00050507),
                  Color(0xF2050507),
                ],
                stops: [0, 0.42, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Align(
                alignment: Alignment.topLeft,
                child: _BackButton(onTap: onBack),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              hPad,
              0,
              hPad,
              context.responsive(
                mobile: AppSpacing.xl,
                desktop: AppSpacing.huge,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EyebrowBadge(label: context.l10n.caseStudy_eyebrow),
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      header: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.caseStudy_title,
                            style: headlineStyle,
                          ),
                          GradientText(
                            text: context.l10n.caseStudy_titleAccent,
                            gradient: AppGradients.brand(colors),
                            style: headlineStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Text(
                        context.l10n.caseStudy_subtitle,
                        style: (isMobile ? tt.bodyMedium : tt.bodyLarge)
                            ?.copyWith(
                              color: colors.onSurfaceMuted,
                              height: 1.55,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface.withValues(alpha: 0.7),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        key: const Key('case-study-back'),
        tooltip: CommonStrings.back,
        icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
        onPressed: onTap,
      ),
    );
  }
}
