import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/domain/recovery_snapshot.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_card_backdrop.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_recovery_ring.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_strain_dial.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_copy.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_history_page.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_session_logger_page.dart';
import 'package:feature_showcase/src/shared/presentation/showcase_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pulso_today_cards.dart';

/// Home do Pulso. Recovery score como leitura central, strain do dia
/// como leitura complementar, e um card com a sessao planejada pra
/// hoje. CTA "Iniciar treino" empurra [PulsoSessionLoggerPage].
///
/// Os cards (recovery, strain/programa, biometria, CTA da sessao,
/// rest day) vivem na part irma `pulso_today_cards.dart`.
class PulsoTodayPage extends StatelessWidget {
  const PulsoTodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: BlocBuilder<FitnessBloc, FitnessState>(
          builder: (context, state) {
            final snapshot = state.todaySnapshot;
            final template = state.todaysTemplate;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _TodayHeader(weekday: state.selectedProgramDay),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _RecoveryCard(percent: snapshot.recoveryPercent),
                      const SizedBox(height: AppSpacing.md),
                      _StrainAndProgramRow(state: state, template: template),
                      const SizedBox(height: AppSpacing.md),
                      _BiometricsCard(snapshot: snapshot),
                      const SizedBox(height: AppSpacing.md),
                      if (template != null)
                        _SessionCtaCard(
                          template: template,
                          weekday: state.selectedProgramDay,
                        )
                      else
                        const _RestDayCard(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
