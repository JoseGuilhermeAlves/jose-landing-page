import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/domain/workout_exercise.dart';
import 'package:feature_showcase/src/fitness/presentation/exercise_load_history_chart.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/muscle_taxonomy.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_body_diagram.dart';
import 'package:feature_showcase/src/fitness/presentation/rest_timer_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela de detalhe de um exercicio do plano, aberta com push a partir
/// do card da aba Semana. Mostra: sumario com sets/reps/carga, progresso
/// do dia (set dots maiores + rest CTA), historico de carga das 8
/// semanas anteriores (painter dedicado), grupos musculares (reusa o
/// diagrama corporal) e notas tecnicas inferidas do nome do exercicio.
///
/// Stateless — todo o estado mora no `FitnessBloc` que ja esta no
/// scope; este push esta dentro do `BlocProvider` do `FitnessDemo`.
class ExerciseDetailPage extends StatelessWidget {
  const ExerciseDetailPage({
    required this.weekday,
    required this.exercise,
    super.key,
  });

  /// Dia do plano em que esse exercicio aparece (1..7).
  final int weekday;

  final WorkoutExercise exercise;

  /// Helper estatico — empurra essa page com o tema da marca e o
  /// bloc do scope atual ja propagados. Necessario porque o push abre
  /// um novo route que escapa do `BlocProvider` quando o demo esta
  /// dentro de outro Navigator (`fullscreenDialog: true`). Capturamos
  /// o bloc no scope antes do push e re-fornecemos via `.value`.
  static Future<void> open(
    BuildContext context, {
    required int weekday,
    required WorkoutExercise exercise,
  }) {
    final theme = Theme.of(context);
    final bloc = context.read<FitnessBloc>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Theme(
          data: theme,
          child: BlocProvider.value(
            value: bloc,
            child: ExerciseDetailPage(
              weekday: weekday,
              exercise: exercise,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final muscles = MuscleTaxonomy.forExercise(exercise);
    final notes = _technicalNotesFor(exercise);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: colors.background,
        elevation: 0,
        leading: IconButton(
          key: const Key('exercise-detail-back'),
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          exercise.name,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: BlocBuilder<FitnessBloc, FitnessState>(
        builder: (context, state) {
          final completed = state.completedFor(
            weekday: weekday,
            exerciseId: exercise.id,
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCard(
                  exercise: exercise,
                  completed: completed,
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(
                  text: 'Progresso de hoje',
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                _TodaySetsCard(
                  weekday: weekday,
                  exercise: exercise,
                  completed: completed,
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionLabel(
                  text: 'Carga — últimas 8 semanas',
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colors.border),
                  ),
                  child: ExerciseLoadHistoryChart(
                    currentWeightKg: exercise.weightKg <= 0
                        ? 1
                        : exercise.weightKg,
                    seed: exercise.id.hashCode,
                  ),
                ),
                if (muscles.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _SectionLabel(
                    text: 'Músculos trabalhados',
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _MusclesCard(
                    muscles: muscles,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _SectionLabel(
                    text: 'Notas técnicas',
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _NotesCard(
                    notes: notes,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Notas tecnicas mockadas — heuristica simples por palavra-chave.
  /// Em produto real viriam atreladas ao exercicio (CMS / curadoria).
  static List<String> _technicalNotesFor(WorkoutExercise ex) {
    final n = ex.name.toLowerCase();
    if (n.contains('supino')) {
      return const [
        'Mantenha as escápulas retraídas e os pés firmes no chão.',
        'Desça a barra até tocar o peitoral, evitando quicar.',
        'Cotovelos a ~45° do tronco — não abrir 90°.',
      ];
    }
    if (n.contains('agachamento') || n.contains('leg press')) {
      return const [
        'Joelhos alinhados com a ponta dos pés — evite valgo.',
        'Quadril descendo paralelo ou abaixo da linha do joelho.',
        'Core ativado, peito aberto durante toda a fase.',
      ];
    }
    if (n.contains('puxada') || n.contains('remada')) {
      return const [
        'Iniciar pelo movimento das escápulas, não pelos braços.',
        'Cotovelos descem em linha vertical no plano da barra.',
        'Evite "balanço" — controle excêntrico cuidadoso.',
      ];
    }
    if (n.contains('rosca')) {
      return const [
        'Cotovelos fixos próximos ao tronco durante toda a série.',
        'Subida explosiva, descida controlada (~2s).',
        'Evite balanço do quadril compensando carga.',
      ];
    }
    if (n.contains('desenvolv') || n.contains('lateral')) {
      return const [
        'Ombros longe das orelhas — escápulas estabilizadas.',
        'Cotovelos ligeiramente à frente da linha do tronco.',
        'Empurrar como se afastasse algo do teto, sem trancar cotovelo.',
      ];
    }
    if (n.contains('prancha') || n.contains('abdominal') || n.contains('core')) {
      return const [
        'Alinhe cabeça, quadril e calcanhar numa linha contínua.',
        'Glúteos contraídos — evite "afundar" o quadril.',
        'Respire lento e regular durante a sustentação.',
      ];
    }
    if (n.contains('panturrilha')) {
      return const [
        'Subida completa até a ponta dos pés, sem rebote.',
        'Pausa de ~1s no topo amplifica o estímulo.',
        'Manter joelhos travados (em pé) ou flexionados (sentado).',
      ];
    }
    if (n.contains('burpee') || n.contains('kettlebell') || n.contains('remo')) {
      return const [
        'Cadência constante — não comprometa a forma pela velocidade.',
        'Core firme em toda transição, evitando perda de coluna neutra.',
        'Respiração ritmada com o movimento — exale na subida.',
      ];
    }
    return const [];
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.exercise,
    required this.completed,
    required this.colors,
    required this.textTheme,
  });

  final WorkoutExercise exercise;
  final int completed;
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
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              value: '${exercise.targetSets}',
              label: 'sets',
              colors: colors,
              textTheme: textTheme,
            ),
          ),
          _SummaryDivider(colors: colors),
          Expanded(
            child: _SummaryMetric(
              value: exercise.reps == 1 ? '—' : '${exercise.reps}',
              label: 'reps',
              colors: colors,
              textTheme: textTheme,
            ),
          ),
          _SummaryDivider(colors: colors),
          Expanded(
            child: _SummaryMetric(
              value: exercise.weightKg <= 0
                  ? 'peso\ncorporal'
                  : '${_formatWeight(exercise.weightKg)} kg',
              label: 'carga',
              colors: colors,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatWeight(double kg) {
    if (kg == kg.roundToDouble()) return kg.toInt().toString();
    return kg.toStringAsFixed(1);
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
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
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.05,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceMuted,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
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
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: colors.border,
    );
  }
}

class _TodaySetsCard extends StatelessWidget {
  const _TodaySetsCard({
    required this.weekday,
    required this.exercise,
    required this.completed,
    required this.colors,
    required this.textTheme,
  });

  final int weekday;
  final WorkoutExercise exercise;
  final int completed;
  final AppColorScheme colors;
  final TextTheme textTheme;

  static int _restSecondsFor(WorkoutExercise e) => e.reps <= 8 ? 120 : 90;

  static String _formatRest(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final mm = seconds ~/ 60;
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FitnessBloc>();
    final isDone = completed >= exercise.targetSets;
    final restSeconds = _restSecondsFor(exercise);

    return Container(
      key: const Key('exercise-detail-today-card'),
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
              Text(
                '$completed / ${exercise.targetSets}',
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'sets concluídos',
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ),
              const Spacer(),
              if (isDone)
                Icon(
                  Icons.check_circle_outline,
                  color: colors.success,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < exercise.targetSets; i++)
                _SetTile(
                  index: i,
                  filled: i < completed,
                  colors: colors,
                  textTheme: textTheme,
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
          ),
          const SizedBox(height: AppSpacing.md),
          Material(
            color: colors.surfaceMuted,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: colors.border),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: InkWell(
              key: const Key('exercise-detail-rest-chip'),
              borderRadius: BorderRadius.circular(AppRadius.full),
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: colors.surface,
                  useSafeArea: true,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                  ),
                  builder: (_) => RestTimerSheet(
                    initialSeconds: restSeconds,
                    exerciseName: exercise.name,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: colors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Descanso ${_formatRest(restSeconds)}',
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
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

class _SetTile extends StatelessWidget {
  const _SetTile({
    required this.index,
    required this.filled,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  final int index;
  final bool filled;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('exercise-detail-set-tile'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: filled ? colors.primary : colors.border,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: filled
            ? Icon(Icons.check, size: 22, color: colors.onPrimary)
            : Text(
                '${index + 1}',
                style: textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _MusclesCard extends StatelessWidget {
  const _MusclesCard({
    required this.muscles,
    required this.colors,
    required this.textTheme,
  });

  final Set<MuscleGroup> muscles;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulsoBodyDiagram(active: muscles, height: 150),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foco principal',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Grupos ativados por este movimento:',
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.32),
                          ),
                        ),
                        child: Text(
                          MuscleTaxonomy.label(m),
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
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

class _NotesCard extends StatelessWidget {
  const _NotesCard({
    required this.notes,
    required this.colors,
    required this.textTheme,
  });

  final List<String> notes;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < notes.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    notes[i],
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
