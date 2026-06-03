import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing/features/case_study/case_study_hero.dart';
import 'package:landing/features/case_study/case_study_narrative.dart';
import 'package:landing/features/case_study/case_study_scenes.dart';
import 'package:landing/router/route_paths.dart';

/// Pagina `/estudo` — estudo de caso dos Custom Painters / cosmos da
/// landing. Hero full-bleed com o cosmos vivo, narrativa "por que
/// pintar", galeria de cenas isoladas e decisoes tecnicas + takeaway.
/// Composta por parts (`case_study_hero/scenes/narrative`) pra nao virar
/// god file — o shell so orquestra o scroll e o padding.
class CaseStudyPage extends StatelessWidget {
  const CaseStudyPage({super.key = const Key('case-study-page')});

  static const double _maxContentWidth = 980;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // Deep-link direto em /estudo (sem rota anterior): manda pra home.
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = context.isMobile;
    final hPad = context.responsive(
      mobile: AppSpacing.lg,
      desktop: AppSpacing.huge,
    );
    final blockGap = context.responsive(
      mobile: AppSpacing.lg,
      desktop: AppSpacing.xl,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CaseStudyHero(onBack: () => _back(context)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: blockGap,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CaseStudyNarrative(),
                      SizedBox(height: blockGap),
                      CaseStudyScenes(isMobile: isMobile),
                      SizedBox(height: blockGap),
                      const CaseStudyDecisions(),
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
