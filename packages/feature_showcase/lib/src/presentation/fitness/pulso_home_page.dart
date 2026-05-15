import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/domain/workout_day.dart';
import 'package:feature_showcase/src/presentation/fitness/fitness_bloc.dart';
import 'package:feature_showcase/src/presentation/fitness/fitness_state.dart';
import 'package:feature_showcase/src/presentation/fitness/muscle_taxonomy.dart';
import 'package:feature_showcase/src/presentation/fitness/pulso_activity_rings.dart';
import 'package:feature_showcase/src/presentation/fitness/pulso_athlete_figure.dart';
import 'package:feature_showcase/src/presentation/fitness/pulso_body_diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela inicial do demo Pulso — dashboard estilo Strava/Nike Run Club
/// sobre a paleta light/laranja da marca. Composta por:
/// - greeting + data;
/// - hero card do treino do dia (silhueta de atleta + CTA);
/// - aneis de atividade (sets / tempo estimado / exercicios);
/// - diagrama corporal com musculos do dia destacados;
/// - resumo da semana.
///
/// Cada bloco visual e um Custom Painter dedicado — sem assets nem
/// stock photos. Le `FitnessState` pra calcular o que mostrar.
class PulsoHomePage extends StatelessWidget {
  const PulsoHomePage({required this.onEnterApp, super.key});

  /// Callback do CTA "Iniciar treino" — o `FitnessDemo` pai troca
  /// pro Scaffold com TabBar.
  final VoidCallback onEnterApp;

  static const List<String> _weekdayShort = [
    '',
    'segunda',
    'terça',
    'quarta',
    'quinta',
    'sexta',
    'sábado',
    'domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        final today = state.selectedDay;
        final isRest = today.isRestDay;
        final activeDays = state.plan.where((d) => !d.isRestDay).length;
        final weeklyVolume = _estimatedVolume(state);
        final volumeLabel = weeklyVolume >= 1000
            ? '${(weeklyVolume / 1000).toStringAsFixed(1)} t'
            : '${weeklyVolume.round()} kg';
        final estimatedMinutes = isRest
            ? 0
            : (today.exercises.length * 12 + 5).clamp(15, 90);

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
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
                  _Header(
                    colors: colors,
                    textTheme: textTheme,
                    weekdayLabel: _weekdayShort[today.weekday],
                    onClose: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _WorkoutTodayCard(
                    day: today,
                    estimatedMinutes: estimatedMinutes,
                    colors: colors,
                    textTheme: textTheme,
                    onStart: onEnterApp,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionLabel(
                    text: 'Hoje em foco',
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ActivityRingsCard(
                    day: today,
                    state: state,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  if (!isRest) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _SectionLabel(
                      text: 'Musculos do dia',
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MuscleFocusCard(
                      day: today,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  _SectionLabel(
                    text: 'Sua semana',
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _WeekSummaryCard(
                    activeDays: activeDays,
                    totalSets: state.weeklyTargetSets,
                    volumeLabel: volumeLabel,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static double _estimatedVolume(FitnessState state) {
    var total = 0.0;
    for (final day in state.plan) {
      for (final ex in day.exercises) {
        total += ex.targetSets * ex.reps * ex.weightKg;
      }
    }
    return total;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.colors,
    required this.textTheme,
    required this.weekdayLabel,
    required this.onClose,
  });

  final AppColorScheme colors;
  final TextTheme textTheme;
  final String weekdayLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.bolt, size: 22, color: colors.onPrimary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bom dia, atleta',
                key: const Key('pulso-home-greeting'),
                style: textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Pulso · $weekdayLabel',
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('pulso-home-close'),
          tooltip: 'Fechar demo',
          icon: const Icon(Icons.close_rounded),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.text,
    required this.colors,
    required this.textTheme,
  });

  final String text;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: textTheme.labelMedium?.copyWith(
        color: colors.onSurfaceMuted,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _WorkoutTodayCard extends StatelessWidget {
  const _WorkoutTodayCard({
    required this.day,
    required this.estimatedMinutes,
    required this.colors,
    required this.textTheme,
    required this.onStart,
  });

  final WorkoutDay day;
  final int estimatedMinutes;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final isRest = day.isRestDay;

    return Container(
      key: const Key('pulso-home-workout-card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    isRest ? 'descanso' : 'treino de hoje',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isRest ? 'Dia de recuperação' : day.label,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: colors.onSurfaceMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      isRest
                          ? 'sem exercícios'
                          : '~$estimatedMinutes min · ${day.exercises.length} ex',
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    key: const Key('pulso-home-cta'),
                    label: isRest ? 'Ver plano da semana' : 'Iniciar treino',
                    icon: isRest
                        ? Icons.calendar_view_week
                        : Icons.play_arrow_rounded,
                    size: AppButtonSize.large,
                    expand: true,
                    onPressed: onStart,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Hero visual: silhueta de atleta com barra acima da cabeca.
          // No dia de descanso ela some — substituida por glow vazio.
          if (!isRest)
            const PulsoAthleteFigure(height: 160)
          else
            _RestVisual(colors: colors),
        ],
      ),
    );
  }
}

class _RestVisual extends StatelessWidget {
  const _RestVisual({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 110,
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.self_improvement, size: 36, color: colors.primary),
        ),
      ),
    );
  }
}

class _ActivityRingsCard extends StatelessWidget {
  const _ActivityRingsCard({
    required this.day,
    required this.state,
    required this.colors,
    required this.textTheme,
  });

  final WorkoutDay day;
  final FitnessState state;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final completedSets = state.totalCompletedOn(day.weekday);
    final targetSets = day.totalTargetSets;
    final completedExercises = day.exercises
        .where(
          (e) =>
              state.completedFor(weekday: day.weekday, exerciseId: e.id) >=
              e.targetSets,
        )
        .length;
    final estimatedTotalMinutes = (day.exercises.length * 12).toDouble();
    // Tempo "feito" no mock: proporcional ao set ratio.
    final completedMinutes = targetSets == 0
        ? 0.0
        : (completedSets / targetSets) * estimatedTotalMinutes;

    final setsProgress = targetSets == 0 ? 0.0 : completedSets / targetSets;
    final minutesProgress = estimatedTotalMinutes == 0
        ? 0.0
        : completedMinutes / estimatedTotalMinutes;
    final exercisesProgress = day.exercises.isEmpty
        ? 0.0
        : completedExercises / day.exercises.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          PulsoActivityRings(
            outerProgress: setsProgress,
            middleProgress: minutesProgress,
            innerProgress: exercisesProgress,
            outerColor: colors.primary,
            middleColor: colors.info,
            innerColor: colors.success,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RingLegend(
                  label: 'Sets',
                  value: '$completedSets/$targetSets',
                  color: colors.primary,
                  textTheme: textTheme,
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.md),
                _RingLegend(
                  label: 'Minutos',
                  value:
                      '${completedMinutes.round()}/${estimatedTotalMinutes.round()}',
                  color: colors.info,
                  textTheme: textTheme,
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.md),
                _RingLegend(
                  label: 'Exercícios',
                  value: '$completedExercises/${day.exercises.length}',
                  color: colors.success,
                  textTheme: textTheme,
                  colors: colors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingLegend extends StatelessWidget {
  const _RingLegend({
    required this.label,
    required this.value,
    required this.color,
    required this.textTheme,
    required this.colors,
  });

  final String label;
  final String value;
  final Color color;
  final TextTheme textTheme;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MuscleFocusCard extends StatelessWidget {
  const _MuscleFocusCard({
    required this.day,
    required this.colors,
    required this.textTheme,
  });

  final WorkoutDay day;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final muscles = MuscleTaxonomy.forDay(day);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulsoBodyDiagram(active: muscles),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.label,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Grupos musculares ativados neste treino:',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final m in muscles)
                      _MuscleChip(
                        label: MuscleTaxonomy.label(m),
                        colors: colors,
                        textTheme: textTheme,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  const _MuscleChip({
    required this.label,
    required this.colors,
    required this.textTheme,
  });

  final String label;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.primary.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _WeekSummaryCard extends StatelessWidget {
  const _WeekSummaryCard({
    required this.activeDays,
    required this.totalSets,
    required this.volumeLabel,
    required this.colors,
    required this.textTheme,
  });

  final int activeDays;
  final int totalSets;
  final String volumeLabel;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCell(
              value: '$activeDays',
              label: 'Dias',
              colors: colors,
              textTheme: textTheme,
            ),
          ),
          _SummaryDivider(colors: colors),
          Expanded(
            child: _SummaryCell(
              value: volumeLabel,
              label: 'Volume',
              colors: colors,
              textTheme: textTheme,
            ),
          ),
          _SummaryDivider(colors: colors),
          Expanded(
            child: _SummaryCell(
              value: '$totalSets',
              label: 'Sets',
              colors: colors,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.value,
    required this.label,
    required this.colors,
    required this.textTheme,
  });

  final String value;
  final String label;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceMuted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: colors.border,
    );
  }
}
