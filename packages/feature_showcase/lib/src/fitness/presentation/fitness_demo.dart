import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/data/workout_plan_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/workout_day.dart';
import 'package:feature_showcase/src/fitness/domain/workout_exercise.dart';
import 'package:feature_showcase/src/fitness/presentation/exercise_detail_page.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_hero_backdrop.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_home_page.dart';
import 'package:feature_showcase/src/fitness/presentation/rest_timer_sheet.dart';
import 'package:feature_showcase/src/fitness/presentation/volume_history_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Demo de fitness — mock multi-tela com identidade visual propria
/// (marca ficticia "Pulso", paleta lime/navy). Substitui a tela unica
/// original por 3 abas que comunicam o produto como um app real:
/// - **Hoje**: greeting + treino do dia em destaque + stats rapidos;
/// - **Semana**: plano semanal e marcacao de sets (a tela original);
/// - **Progresso**: volume total, sequencia e barras por dia.
///
/// Theme override aplica a `FitnessBrand.palette` localmente — todos
/// os widgets internos que leem `context.colors` ja recebem a paleta
/// da marca sem propagacao manual.
class FitnessDemo extends StatefulWidget {
  const FitnessDemo({
    required this.today,
    this.plan,
    this.skipHome = false,
    super.key,
  });

  /// Hoje como ancora pro foco inicial. Em produto real,
  /// `today: DateTime.now().weekday`.
  final int today;

  /// Override do plano. Quando null, usa [WorkoutPlanCatalog.week].
  final List<WorkoutDay>? plan;

  /// Pula a [PulsoHomePage] e abre direto na TabBar — usado pelos
  /// widget tests pra nao ter que tocar no CTA em cada caso.
  final bool skipHome;

  @override
  State<FitnessDemo> createState() => _FitnessDemoState();
}

class _FitnessDemoState extends State<FitnessDemo>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late bool _showHome;

  @override
  void initState() {
    super.initState();
    // Construir em initState (e nao via `late final` no campo) pra que
    // o `vsync: this` seja resolvido enquanto o State esta ativo. Se
    // o usuario nunca chega a abrir a TabBar (fica no home), o lazy
    // init dispararia createTicker dentro de dispose() — que falha
    // com "Looking up a deactivated widget's ancestor".
    _tabController = TabController(length: 3, vsync: this);
    _showHome = !widget.skipHome;
  }

  void _enterApp() => setState(() => _showHome = false);
  void _backToHome() => setState(() => _showHome = true);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FitnessBrand.buildTheme(context),
      child: BlocProvider(
        create: (_) => FitnessBloc(
          plan: widget.plan ?? WorkoutPlanCatalog.week,
          today: widget.today,
        ),
        child: Builder(
          builder: (context) {
            if (_showHome) {
              return PulsoHomePage(onEnterApp: _enterApp);
            }
            return _PulsoMainScaffold(
              tabController: _tabController,
              today: widget.today,
              onBackToHome: _backToHome,
            );
          },
        ),
      ),
    );
  }
}

/// Scaffold "interno" do Pulso — extraido do `build` original do
/// [FitnessDemo] sem alteracao de comportamento. A unica adicao e o
/// leading [IconButton] que volta pra [PulsoHomePage].
class _PulsoMainScaffold extends StatelessWidget {
  const _PulsoMainScaffold({
    required this.tabController,
    required this.today,
    required this.onBackToHome,
  });

  final TabController tabController;
  final int today;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: colors.background,
        elevation: 0,
        leading: IconButton(
          key: const Key('fitness-back-to-home'),
          tooltip: 'Voltar ao inicio',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBackToHome,
        ),
        title: _BrandTitle(colors: colors, textTheme: textTheme),
        actions: [
          IconButton(
            key: const Key('fitness-reset-button'),
            tooltip: 'Zerar semana',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<FitnessBloc>().add(const FitnessReset()),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Semana'),
            Tab(text: 'Progresso'),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: tabController,
          children: [
            _TodayTab(
              today: today,
              onStartWorkout: () => tabController.animateTo(1),
            ),
            const _WeekTab(),
            const _ProgressTab(),
          ],
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: -2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.bolt, size: 18, color: colors.onPrimary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          FitnessBrand.name,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// HOJE
// =============================================================================

class _TodayTab extends StatelessWidget {
  const _TodayTab({required this.today, required this.onStartWorkout});

  final int today;
  final VoidCallback onStartWorkout;

  static const List<String> _weekdayNames = [
    '',
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        final day = state.plan.firstWhere(
          (d) => d.weekday == today,
          orElse: () => state.selectedDay,
        );
        final dayLabel = _weekdayNames[day.weekday];
        final completedToday = state.totalCompletedOn(day.weekday);
        final targetToday = day.totalTargetSets;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bom treino, atleta'.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Hoje, $dayLabel.',
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TodayHeroCard(
                day: day,
                completed: completedToday,
                target: targetToday,
                onStart: onStartWorkout,
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.lg),
              _QuickStatsRow(state: state),
              if (day.exercises.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'No plano de hoje',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < day.exercises.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _CompactExerciseRow(exercise: day.exercises[i]),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TodayHeroCard extends StatelessWidget {
  const _TodayHeroCard({
    required this.day,
    required this.completed,
    required this.target,
    required this.onStart,
    required this.colors,
    required this.textTheme,
  });

  final WorkoutDay day;
  final int completed;
  final int target;
  final VoidCallback onStart;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final isRest = day.isRestDay;
    final estimatedMinutes = (day.exercises.length * 8 + 5).clamp(15, 90);

    return DecoratedBox(
      key: const Key('fitness-today-hero-card'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary.withValues(alpha: 0.16), colors.surface],
        ),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 32,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      // ClipRRect recorta o backdrop nos cantos arredondados sem
      // afetar a sombra externa (que fica no DecoratedBox de fora).
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            Positioned.fill(child: PulsoHeroBackdrop(isRest: isRest)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: isRest
                              ? colors.surfaceMuted
                              : colors.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          isRest ? 'descanso' : 'treino do dia',
                          style: textTheme.labelSmall?.copyWith(
                            color: isRest
                                ? colors.onSurfaceMuted
                                : colors.primary,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!isRest)
                        Text(
                          '$completed / $target sets',
                          key: const Key('fitness-today-progress-counter'),
                          style: textTheme.labelMedium?.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    isRest ? 'Dia de recuperacao' : day.label,
                    style: textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (!isRest)
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _MetaChip(
                          icon: Icons.fitness_center_outlined,
                          label: '${day.exercises.length} exercicios',
                          colors: colors,
                          textTheme: textTheme,
                        ),
                        _MetaChip(
                          icon: Icons.schedule_outlined,
                          label: '~$estimatedMinutes min',
                          colors: colors,
                          textTheme: textTheme,
                        ),
                      ],
                    )
                  else
                    Text(
                      'Recuperacao tambem faz parte do plano. Volte amanha.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      key: const Key('fitness-today-start-button'),
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
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.colors,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(color: colors.onSurfaceMuted),
        ),
      ],
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.state});
  final FitnessState state;

  // Sequencia mockada (em produto real viria do historico). Estatica
  // pra dar a impressao do MVP — nao e o foco do demo.
  static const int _streakDays = 12;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final volumeKg = state.totalVolumeKg;
    final volumeLabel = volumeKg >= 1000
        ? '${(volumeKg / 1000).toStringAsFixed(1)}t'
        : '${volumeKg.round()} kg';

    return Row(
      children: [
        Expanded(
          child: _StatBlock(
            label: 'Sequencia',
            value: '$_streakDays dias',
            icon: Icons.local_fire_department_outlined,
            highlight: true,
            colors: colors,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatBlock(
            label: 'Sets',
            value: '${state.weeklyCompletedSets}/${state.weeklyTargetSets}',
            icon: Icons.check_circle_outline,
            highlight: false,
            colors: colors,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatBlock(
            label: 'Volume',
            value: volumeLabel,
            icon: Icons.trending_up,
            highlight: false,
            colors: colors,
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.icon,
    required this.highlight,
    required this.colors,
    required this.textTheme,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: highlight ? colors.primary : colors.onSurfaceMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactExerciseRow extends StatelessWidget {
  const _CompactExerciseRow({required this.exercise});
  final WorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.fitness_center, size: 16, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exercise.name,
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  _exerciseSubtitle(exercise),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
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

// =============================================================================
// SEMANA
// =============================================================================

class _WeekTab extends StatelessWidget {
  const _WeekTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _WeeklyProgressCard(),
        _DayStrip(),
        Expanded(child: _ExercisesList()),
      ],
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
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                    ),
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

class _DayBars extends StatelessWidget {
  const _DayBars();

  static const List<String> _weekdayLabels = [
    'seg',
    'ter',
    'qua',
    'qui',
    'sex',
    'sab',
    'dom',
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
    const maxBarHeight = 32.0;
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
              color: isSelected ? colors.onSurface : colors.onSurfaceMuted,
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
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
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
          border: Border.all(color: selected ? colors.primary : colors.border),
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
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                    ),
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

    return Material(
      key: const Key('fitness-exercise-card'),
      color: colors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isDone ? colors.success : colors.border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        key: const Key('fitness-exercise-card-tap'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => ExerciseDetailPage.open(
          context,
          weekday: weekday,
          exercise: exercise,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                  Icon(
                    isDone
                        ? Icons.check_circle_outline
                        : Icons.chevron_right_rounded,
                    color: isDone ? colors.success : colors.onSurfaceMuted,
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
                          bloc.add(
                            FitnessSetUndone(
                              weekday: weekday,
                              exerciseId: exercise.id,
                            ),
                          );
                        } else {
                          bloc.add(
                            FitnessSetCompleted(
                              weekday: weekday,
                              exerciseId: exercise.id,
                            ),
                          );
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
                  const SizedBox(width: AppSpacing.sm),
                  _RestChip(exercise: exercise),
                ],
              ),
            ],
          ),
        ),
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

/// Chip pequeno na linha de set dots que abre o [RestTimerSheet]. A
/// duracao padrao deriva das reps: <=8 (forca) -> 120s, >8 -> 90s.
class _RestChip extends StatelessWidget {
  const _RestChip({required this.exercise});

  final WorkoutExercise exercise;

  static int _restSecondsFor(WorkoutExercise e) => e.reps <= 8 ? 120 : 90;

  static String _formatLabel(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final mm = seconds ~/ 60;
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final seconds = _restSecondsFor(exercise);

    return Material(
      color: colors.surfaceMuted,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: InkWell(
        key: const Key('fitness-rest-chip'),
        onTap: () => _open(context, seconds),
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 14, color: colors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _formatLabel(seconds),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, int seconds) {
    final colors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      // Sheet tem cantos arredondados no topo pra continuar a marca
      // visual do card. `useSafeArea: true` evita colidir com a barra
      // de gestos em Android e o notch em iOS. `isScrollControlled`
      // permite o sheet crescer alem de 50% da viewport — necessario
      // pra acomodar o ring de 220px + textos + botoes em telas
      // pequenas ou no viewport reduzido dos testes.
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) =>
          RestTimerSheet(initialSeconds: seconds, exerciseName: exercise.name),
    );
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

// =============================================================================
// PROGRESSO
// =============================================================================

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  static const int _streakDays = 12;
  static const List<String> _shortDays = [
    'seg',
    'ter',
    'qua',
    'qui',
    'sex',
    'sab',
    'dom',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        final progress = state.weeklyProgress.clamp(0.0, 1.0);
        final pct = (progress * 100).round();
        final volume = state.totalVolumeKg;
        final volumeLabel = volume >= 1000
            ? '${(volume / 1000).toStringAsFixed(1)}t'
            : '${volume.round()} kg';
        final activeDays = state.plan.where((d) => !d.isRestDay).length;
        final avgPerDay = activeDays == 0
            ? 0
            : (state.weeklyCompletedSets / activeDays);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'esta semana'.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$pct%',
                    key: const Key('fitness-progress-percent'),
                    style: textTheme.displaySmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.4,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      '${state.weeklyCompletedSets} / ${state.weeklyTargetSets} sets',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: TweenAnimationBuilder<double>(
                  duration: AppDuration.base,
                  curve: AppCurves.standard,
                  tween: Tween(begin: 0, end: progress),
                  builder: (_, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: colors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _StatBlock(
                      label: 'Sequencia',
                      value: '$_streakDays dias',
                      icon: Icons.local_fire_department_outlined,
                      highlight: true,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatBlock(
                      label: 'Volume',
                      value: volumeLabel,
                      icon: Icons.trending_up,
                      highlight: false,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatBlock(
                      label: 'Sets/dia',
                      value: avgPerDay.toStringAsFixed(1),
                      icon: Icons.show_chart,
                      highlight: false,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'por dia',
                style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final day in state.plan)
                            Expanded(
                              child: _ProgressDayBar(
                                label: _shortDays[day.weekday - 1],
                                completed: state.totalCompletedOn(day.weekday),
                                target: day.totalTargetSets,
                                isRest: day.isRestDay,
                                colors: colors,
                                textTheme: textTheme,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              VolumeHistoryChart(currentVolumeKg: volume),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressDayBar extends StatelessWidget {
  const _ProgressDayBar({
    required this.label,
    required this.completed,
    required this.target,
    required this.isRest,
    required this.colors,
    required this.textTheme,
  });

  final String label;
  final int completed;
  final int target;
  final bool isRest;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final ratio = target == 0 ? 0.0 : (completed / target).clamp(0.0, 1.0);
    const maxBarHeight = 96.0;
    final barHeight = isRest ? 4.0 : (8 + ratio * (maxBarHeight - 8));
    final barColor = isRest
        ? colors.surfaceMuted
        : Color.lerp(
            colors.primary.withValues(alpha: 0.3),
            colors.primary,
            ratio,
          )!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isRest && target > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '$completed',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
            ),
          AnimatedContainer(
            duration: AppDuration.base,
            curve: AppCurves.standard,
            height: barHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
