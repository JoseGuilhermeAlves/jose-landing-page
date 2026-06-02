import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/presentation/mock_section_label.dart';
import 'package:feature_showcase/src/scheduling/data/vitral_specialists_catalog.dart';
import 'package:feature_showcase/src/scheduling/domain/appointment.dart';
import 'package:feature_showcase/src/scheduling/domain/service_category.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_bloc.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_event.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_state.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_app_bar.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_brand.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_category_illustration.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_clock_painter.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_hero_backdrop.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_navigation.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_service_list_page.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_specialist_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'vitral_home_widgets.dart';

/// Home da marca Vitral — entry point do demo de agendamento.
/// Composta por:
/// - hero com backdrop animado (grid de horas + cursor varrendo) e
///   relogio analogico real ao lado;
/// - card de proximo agendamento (quando existe);
/// - strip de categorias de servico com ilustracao por categoria;
/// - lista de profissionais em destaque com avatar monograma.
///
/// Os sub-widgets (hero, cards de agendamento, categorias, lista de
/// profissionais, bloco sobre) vivem na part irma
/// `vitral_home_widgets.dart`.
class VitralHomePage extends StatelessWidget {
  const VitralHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: VitralAppBar(
        leading: IconButton(
          key: const Key('vitral-close-demo'),
          tooltip: context.l10n.vitral_closeDemoTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: MockBodyConstraint(
        child: SafeArea(
          top: false,
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
                _HeroCard(colors: colors, textTheme: textTheme),
                const SizedBox(height: AppSpacing.xl),
                BlocBuilder<SchedulingBloc, SchedulingState>(
                  builder: (context, state) {
                    final next = state.nextAppointment;
                    if (next == null) {
                      return _NoAppointmentCard(
                        colors: colors,
                        textTheme: textTheme,
                      );
                    }
                    final others = [
                      for (final a in state.confirmedAppointments)
                        if (a.id != next.id) a,
                    ]..sort((a, b) => a.slot.compareTo(b.slot));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NextAppointmentCard(
                          appointment: next,
                          colors: colors,
                          textTheme: textTheme,
                          onCancel: () => _confirmCancelAppointment(
                            context,
                            next.id,
                            next.serviceName,
                          ),
                        ),
                        if (others.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          _OtherAppointmentsList(
                            appointments: others,
                            colors: colors,
                            textTheme: textTheme,
                            onCancel: (id, label) =>
                                _confirmCancelAppointment(context, id, label),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                MockSectionLabel(
                  eyebrow: 'Categorias',
                  title: context.l10n.vitral_categoriesTitle,
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                _CategoriesStrip(colors: colors, textTheme: textTheme),
                const SizedBox(height: AppSpacing.xl),
                MockSectionLabel(
                  eyebrow: 'Profissionais',
                  title: context.l10n.vitral_specialistsTitle,
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                _SpecialistsList(colors: colors, textTheme: textTheme),
                const SizedBox(height: AppSpacing.xxl),
                _AboutBlock(colors: colors, textTheme: textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
