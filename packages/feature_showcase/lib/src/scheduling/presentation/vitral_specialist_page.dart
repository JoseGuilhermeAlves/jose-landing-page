import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/scheduling/data/vitral_reviews_catalog.dart';
import 'package:feature_showcase/src/scheduling/data/vitral_services_catalog.dart';
import 'package:feature_showcase/src/scheduling/domain/service.dart';
import 'package:feature_showcase/src/scheduling/domain/service_category.dart';
import 'package:feature_showcase/src/scheduling/domain/specialist.dart';
import 'package:feature_showcase/src/scheduling/domain/specialist_review.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_app_bar.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_brand.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_calendar_page.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_category_illustration.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_navigation.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_specialist_avatar.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_specialist_headshot.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/presentation/mock_section_label.dart';
import 'package:flutter/material.dart';

part 'vitral_specialist_widgets.dart';

/// Perfil do profissional Vitral — antes os cards de profissional eram
/// becos sem saida; agora cada um abre esta tela: headshot, bio,
/// rating/avaliacoes, servicos que ele oferece (tocaveis para o fluxo de
/// agenda), strip de portfolio e CTA "Agendar".
///
/// Tap em qualquer servico empurra `VitralCalendarPage` — reaproveita o
/// fluxo de agenda existente sem duplicar tela. O CTA "Agendar" abre o
/// calendario com o primeiro servico disponivel do profissional.
class VitralSpecialistPage extends StatelessWidget {
  const VitralSpecialistPage({required this.specialist, super.key});

  final Specialist specialist;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final services = VitralServicesCatalog.byspecialist(specialist.id);
    final reviews = VitralReviewsCatalog.bySpecialist(specialist.id);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const VitralAppBar(),
      body: MockBodyConstraint(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileHeader(
                        specialist: specialist,
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _BioBlock(
                        specialist: specialist,
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      MockSectionLabel(
                        eyebrow: 'Portfolio',
                        title: 'Trabalhos recentes',
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PortfolioStrip(
                        specialist: specialist,
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      MockSectionLabel(
                        eyebrow: 'Servicos',
                        title: services.length == 1
                            ? '1 servico disponivel'
                            : '${services.length} servicos disponiveis',
                        colors: colors,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (var i = 0; i < services.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.sm),
                        _SpecialistServiceCard(
                          service: services[i],
                          colors: colors,
                          textTheme: textTheme,
                        ),
                      ],
                      if (reviews.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        MockSectionLabel(
                          eyebrow: 'Avaliacoes',
                          title: 'O que dizem',
                          colors: colors,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ReviewsBlock(
                          specialist: specialist,
                          reviews: reviews,
                          colors: colors,
                          textTheme: textTheme,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _AgendarCta(
                specialist: specialist,
                services: services,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
