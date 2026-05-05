import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/workout_plan_catalog.dart';
import 'package:feature_showcase/src/domain/workout_day.dart';
import 'package:feature_showcase/src/domain/workout_exercise.dart';
import 'package:feature_showcase/src/presentation/fitness/fitness_bloc.dart';
import 'package:feature_showcase/src/presentation/fitness/fitness_event.dart';
import 'package:feature_showcase/src/presentation/fitness/fitness_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela do mock de fitness. Strip de 7 dias da semana + lista de
/// exercicios do dia + barra de progresso semanal e mini-grafico
/// dia-a-dia. Tap no dot de set marca/desmarca.
class FitnessDemo extends StatelessWidget {
  const FitnessDemo({
    required this.today,
    this.plan,
    super.key,
  });

  /// Hoje como ancora pro foco inicial. Em produto real,
  /// `today: DateTime.now().weekday`.
  final int today;

  /// Override do plano. Quando null, usa [WorkoutPlanCatalog.week].
  final List<WorkoutDay>? plan;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => FitnessBloc(
        plan: plan ?? WorkoutPlanCatalog.week,
        today: today,
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              title: Text('Treino da semana', style: textTheme.titleLarge),
              actions: [
                IconButton(
                  key: const Key('fitness-reset-button'),
                  tooltip: 'Zerar semana',
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<FitnessBloc>().add(const FitnessReset()),
                ),
              ],
            ),
            body: const SafeArea(
              child: Column(
                children: [
                  _WeeklyProgressCard(),
                  _DayStrip(),
                  Expanded(child: _ExercisesList()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        final progress = state.weeklyProgress.clamp(0.0, 1.0);
        final pct = (progress * 100).round();

        return Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Progresso semanal',
                    style: textTheme.titleMedium
                        ?.copyWith(color: colors.onSurface),
                  ),
                  const Spacer(),
                  Text(
                    '$pct%',
                    key: const Key('fitness-weekly-percent'),
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: TweenAnimationBuilder<double>(
                  duration: AppDuration.base,
                  curve: AppCurves.standard,
                  tween: Tween(begin: 0, end: progress),
                  builder: (_, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: colors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const _DayBars(),
            ],
          ),
        );
      },
    );
  }
}

/// Mini-grafico dia-a-dia: barra vertical por dia com altura
/// proporcional aos sets concluidos. Usa AnimatedContainer pra
/// transicionar suavemente quando o usuario marca/desmarca um set.
class _DayBars extends StatelessWidget {
  const _DayBars();

  static const List<String> _weekdayLabels = [
    'seg', 'ter', 'qua', 'qui', 'sex', 'sab', 'dom',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        return SizedBox(
          height: 56,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in state.plan)
                Expanded(
                  child: _DayBar(
                    label: _weekdayLabels[day.weekday - 1],
                    completed: state.totalCompletedOn(day.weekday),
                    target: day.totalTargetSets,
                    isRest: day.isRestDay,
                    isSelected: day.weekday == state.selectedWeekday,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.completed,
    required this.target,
    required this.isRest,
    required this.isSelected,
    required this.colors,
    required this.textTheme,
  });

  final String label;
  final int completed;
  final int target;
  final bool isRest;
  final bool isSelected;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final ratio = target == 0 ? 0.0 : (completed / target).clamp(0.0, 1.0);
    final maxBarHeight = 32.0;
    final barHeight = isRest ? 2.0 : (4 + ratio * (maxBarHeight - 4));
    final barColor = isRest
        ? colors.surfaceMuted
        : (isSelected ? colors.primary : colors.primary.withValues(alpha: 0.4));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            key: const Key('fitness-day-bar'),
            duration: AppDuration.base,
            curve: AppCurves.standard,
            height: barHeight,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? colors.onSurface
                  : colors.onSurfaceMuted,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip();

  static const List<String> _weekdayLabels = [
    'segunda', 'terca', 'quarta', 'quinta', 'sexta', 'sabado', 'domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        // 7 itens — eager Row dentro de SingleChildScrollView garante
        // que o tester veja todos sem scroll.
        return SizedBox(
          height: 84,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                for (final day in state.plan) ...[
                  if (day.weekday > 1) const SizedBox(width: AppSpacing.sm),
                  _DayChip(
                    day: day,
                    label: _weekdayLabels[day.weekday - 1],
                    selected: day.weekday == state.selectedWeekday,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.label,
    required this.selected,
    required this.colors,
    required this.textTheme,
  });

  final WorkoutDay day;
  final String label;
  final bool selected;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('fitness-day-chip'),
      onTap: () =>
          context.read<FitnessBloc>().add(FitnessDaySelected(day.weekday)),
      child: AnimatedContainer(
        duration: AppDuration.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day.isRestDay ? 'descanso' : day.label.toLowerCase(),
              style: textTheme.labelSmall?.copyWith(
                color: selected
                    ? colors.onPrimary.withValues(alpha: 0.85)
                    : colors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExercisesList extends StatelessWidget {
  const _ExercisesList();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        final day = state.selectedDay;

        if (day.isRestDay) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.self_improvement, size: 48, color: colors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Dia de descanso',
                    style: textTheme.titleMedium
                        ?.copyWith(color: colors.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Recuperacao tambem faz parte do plano.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              for (var i = 0; i < day.exercises.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                _ExerciseCard(
                  weekday: day.weekday,
                  exercise: day.exercises[i],
                  completed: state.completedFor(
                    weekday: day.weekday,
                    exerciseId: day.exercises[i].id,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.weekday,
    required this.exercise,
    required this.completed,
  });

  final int weekday;
  final WorkoutExercise exercise;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final bloc = context.read<FitnessBloc>();
    final isDone = completed >= exercise.targetSets;

    return Container(
      key: const Key('fitness-exercise-card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDone ? colors.success : colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (isDone)
                Icon(
                  Icons.check_circle_outline,
                  color: colors.success,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _exerciseSubtitle(exercise),
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < exercise.targetSets; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                _SetDot(
                  filled: i < completed,
                  onTap: () {
                    if (i < completed) {
                      bloc.add(FitnessSetUndone(
                        weekday: weekday,
                        exerciseId: exercise.id,
                      ));
                    } else {
                      bloc.add(FitnessSetCompleted(
                        weekday: weekday,
                        exerciseId: exercise.id,
                      ));
                    }
                  },
                ),
              ],
              const Spacer(),
              Text(
                '$completed / ${exercise.targetSets}',
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _exerciseSubtitle(WorkoutExercise e) {
    final reps = e.reps == 1 ? 'serie' : '${e.reps} reps';
    if (e.weightKg <= 0) return '${e.targetSets} x $reps';
    final weight = _formatWeight(e.weightKg);
    return '${e.targetSets} x $reps · $weight';
  }

  static String _formatWeight(double kg) {
    if (kg == kg.roundToDouble()) return '${kg.toInt()} kg';
    return '${kg.toStringAsFixed(1)} kg';
  }
}

class _SetDot extends StatelessWidget {
  const _SetDot({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      key: const Key('fitness-set-dot'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: filled ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: filled ? colors.primary : colors.border,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: filled
            ? Icon(Icons.check, size: 16, color: colors.onPrimary)
            : null,
      ),
    );
  }
}
