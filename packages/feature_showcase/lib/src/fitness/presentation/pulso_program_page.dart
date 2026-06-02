import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/domain/program_week.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_copy.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_periodization_timeline.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_exercise_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pulso_program_widgets.dart';

/// Visao geral do mesociclo de 8 semanas. Header com nome do programa
/// + semana atual highlight. Grid PulsoPeriodizationTimeline embaixo
/// permite tap em qualquer celula pra pre-visualizar a sessao.
class PulsoProgramPage extends StatefulWidget {
  const PulsoProgramPage({super.key});

  @override
  State<PulsoProgramPage> createState() => _PulsoProgramPageState();
}

class _PulsoProgramPageState extends State<PulsoProgramPage> {
  int? _selectedWeek;
  int? _selectedWeekday;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: BlocBuilder<FitnessBloc, FitnessState>(
          builder: (context, state) {
            final program = state.program;
            final week = program.weeks.firstWhere(
              (w) => w.index == (_selectedWeek ?? program.currentWeekIndex),
              orElse: () => program.weeks.first,
            );
            final template = _selectedWeekday == null
                ? null
                : week.sessionFor(_selectedWeekday!);
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _ProgramHeader(state: state),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: context.colors.border),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: PulsoPeriodizationTimeline(
                    program: program,
                    height: context.isMobile ? 184 : 240,
                    selectedWeek: _selectedWeek ?? program.currentWeekIndex,
                    selectedWeekday: _selectedWeekday ?? 0,
                    onCellTap: (w, d) {
                      setState(() {
                        _selectedWeek = w;
                        _selectedWeekday = d;
                      });
                      context.read<FitnessBloc>().add(ProgramDaySelected(d));
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SelectionLegend(week: week, weekday: _selectedWeekday),
                const SizedBox(height: AppSpacing.md),
                if (template != null)
                  _SessionPreviewCard(week: week, template: template)
                else
                  const _SelectHint(),
              ],
            );
          },
        ),
      ),
    );
  }
}
