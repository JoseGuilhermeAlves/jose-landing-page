import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/domain/program_week.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_periodization_timeline.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_exercise_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class _ProgramHeader extends StatelessWidget {
  const _ProgramHeader({required this.state});
  final FitnessState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final program = state.program;
    final week = program.currentWeek;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROGRAMA',
          style: TextStyle(
            color: colors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          program.name,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          program.tagline,
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _Stat(
              label: 'SEMANA',
              value: '${program.currentWeekIndex}/${program.durationWeeks}',
            ),
            const SizedBox(width: AppSpacing.lg),
            _Stat(
              label: 'INTENSIDADE',
              value: 'x${(week?.intensityMultiplier ?? 1).toStringAsFixed(2)}',
            ),
            const SizedBox(width: AppSpacing.lg),
            _Stat(
              label: 'STRAIN ALVO',
              value: (week?.targetStrain ?? 0).toStringAsFixed(1),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: FitnessBrand.displayMonoFontFamily,
          ),
        ),
      ],
    );
  }
}

class _SelectionLegend extends StatelessWidget {
  const _SelectionLegend({required this.week, required this.weekday});
  final ProgramWeek week;
  final int? weekday;

  static const _weekdayLabels = [
    'Segunda',
    'Terca',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sabado',
    'Domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dayLabel = weekday == null
        ? 'Selecione um dia'
        : _weekdayLabels[(weekday! - 1).clamp(0, 6)];
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          week.label,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          ' · $dayLabel',
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SessionPreviewCard extends StatelessWidget {
  const _SessionPreviewCard({required this.week, required this.template});
  final ProgramWeek week;
  final SessionTemplate template;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mult = week.intensityMultiplier;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.label,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      template.focusMuscles.map((m) => m.label).join(' · '),
                      style: TextStyle(
                        color: colors.onSurfaceMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${template.estimatedMinutes}min',
                style: TextStyle(
                  color: colors.onSurfaceMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: FitnessBrand.displayMonoFontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final ex in template.exercises)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<FitnessBloc>(),
                    child: PulsoExerciseDetailPage(exerciseId: ex.id),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        ex.name,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${(ex.suggestedWeightKg * mult).round()} kg',
                      style: TextStyle(
                        color: colors.onSurfaceMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: FitnessBrand.displayMonoFontFamily,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${ex.targetSets}x${ex.targetReps}',
                      style: TextStyle(
                        color: colors.onSurfaceMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: FitnessBrand.displayMonoFontFamily,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: colors.onSurfaceMuted,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectHint extends StatelessWidget {
  const _SelectHint();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.touch_app_outlined, color: colors.onSurfaceMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Toque uma celula do grid pra previsualizar a sessao.',
              style: TextStyle(
                color: colors.onSurfaceMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
