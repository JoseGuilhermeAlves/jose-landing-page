import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/data/exercises_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/domain/set_entry.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_set_complete_burst.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_exercise_detail_page.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_swap_exercise_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela coracao do mock — loga sets em ritmo de treino real. Cada
/// exercicio tem N linhas de set com weight/reps/RPE editaveis e um
/// botao de complete que dispara strain + burst. Sticky bottom mostra
/// rest timer ativo ou CTA pra finalizar a sessao.
class PulsoSessionLoggerPage extends StatefulWidget {
  const PulsoSessionLoggerPage({super.key});

  @override
  State<PulsoSessionLoggerPage> createState() => _PulsoSessionLoggerPageState();
}

class _PulsoSessionLoggerPageState extends State<PulsoSessionLoggerPage> {
  _RestTimerState? _restTimer;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startRest(int seconds) {
    _ticker?.cancel();
    setState(() {
      _restTimer = _RestTimerState(total: seconds, remaining: seconds);
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final current = _restTimer;
      if (current == null) return;
      final next = current.remaining - 1;
      if (next <= 0) {
        _ticker?.cancel();
        setState(() => _restTimer = null);
      } else {
        setState(() => _restTimer = current.copyWith(remaining: next));
      }
    });
  }

  void _adjustRest(int delta) {
    final current = _restTimer;
    if (current == null) return;
    setState(
      () => _restTimer = current.copyWith(
        remaining: (current.remaining + delta).clamp(0, 600),
        total: current.total + (delta > 0 ? delta : 0),
      ),
    );
    if (delta < 0) {
      context.read<FitnessBloc>().add(RestExtended(delta));
    } else {
      context.read<FitnessBloc>().add(RestExtended(delta));
    }
  }

  void _skipRest() {
    _ticker?.cancel();
    setState(() => _restTimer = null);
    context.read<FitnessBloc>().add(const RestSkipped());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        final session = state.activeSession;
        final template = state.todaysTemplate;
        if (session == null || template == null) {
          return const Scaffold(
            body: Center(child: Text('Sessao nao iniciada.')),
          );
        }
        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: _LoggerAppBar(template: template, state: state),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 92),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: template.exercises.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final original = template.exercises[i];
                final effectiveId = state.effectiveExerciseId(original.id);
                final effective = effectiveId == original.id
                    ? original
                    : (ExercisesCatalog.byId(effectiveId) ?? original);
                return _ExerciseCard(
                  exercise: effective,
                  originalId: original.id,
                  prescribedWeight: state.prescribedWeightFor(original.id),
                  state: state,
                  onSetComplete: () => _startRest(effective.restSeconds),
                );
              },
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: _restTimer != null
                ? _RestTimerBanner(
                    state: _restTimer!,
                    onAdjust: _adjustRest,
                    onSkip: _skipRest,
                  )
                : _FinishSessionBar(
                    totalSets: session.completedSetsCount,
                    totalVolumeKg: session.totalVolumeKg,
                    onFinish: () => _finishSession(context),
                  ),
          ),
        );
      },
    );
  }

  void _finishSession(BuildContext context) {
    context.read<FitnessBloc>().add(SessionFinished(now: DateTime.now()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sessao finalizada. Strain registrado.')),
    );
    Navigator.of(context).pop();
  }
}

class _RestTimerState {
  const _RestTimerState({required this.total, required this.remaining});
  final int total;
  final int remaining;
  double get progress => total == 0 ? 0 : 1 - (remaining / total);
  _RestTimerState copyWith({int? total, int? remaining}) => _RestTimerState(
    total: total ?? this.total,
    remaining: remaining ?? this.remaining,
  );
}

class _LoggerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LoggerAppBar({required this.template, required this.state});
  final SessionTemplate template;
  final FitnessState state;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final week = state.program.currentWeek;
    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      surfaceTintColor: colors.background,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: colors.onSurface),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.label,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Semana ${state.program.currentWeekIndex} · ${week?.label ?? "—"}',
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Center(
            child: _Pill(
              label: '${state.exercisesCompleted}/${template.exercises.length}',
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: FitnessBrand.displayMonoFontFamily,
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.originalId,
    required this.prescribedWeight,
    required this.state,
    required this.onSetComplete,
  });

  final PlannedExercise exercise;
  final String originalId;
  final double prescribedWeight;
  final FitnessState state;
  final VoidCallback onSetComplete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sets = state.setsFor(exercise.id);
    final completed = state.completedSetsFor(exercise.id);
    final allDone = completed >= exercise.targetSets;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: allDone
              ? colors.primary.withValues(alpha: 0.45)
              : colors.border,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openDetail(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${exercise.targetSets} x ${exercise.targetReps} '
                        '· prescr. ${prescribedWeight.toStringAsFixed(0)} kg',
                        style: TextStyle(
                          color: colors.onSurfaceMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: FitnessBrand.displayMonoFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Trocar exercicio',
                icon: Icon(Icons.swap_horiz_rounded, color: colors.accent),
                onPressed: () => _openSwap(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < exercise.targetSets; i++)
            _SetRow(
              setIndex: i + 1,
              prescribedWeight: prescribedWeight,
              prescribedReps: exercise.targetReps,
              existing: _findSet(sets, i + 1),
              exerciseId: exercise.id,
              onComplete: onSetComplete,
            ),
        ],
      ),
    );
  }

  SetEntry? _findSet(List<SetEntry> sets, int index) {
    for (final s in sets) {
      if (s.index == index) return s;
    }
    return null;
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<FitnessBloc>(),
          child: PulsoExerciseDetailPage(exerciseId: exercise.id),
        ),
      ),
    );
  }

  void _openSwap(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<FitnessBloc>(),
        child: PulsoSwapExerciseSheet(originalExerciseId: originalId),
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  const _SetRow({
    required this.setIndex,
    required this.prescribedWeight,
    required this.prescribedReps,
    required this.existing,
    required this.exerciseId,
    required this.onComplete,
  });

  final int setIndex;
  final double prescribedWeight;
  final int prescribedReps;
  final SetEntry? existing;
  final String exerciseId;
  final VoidCallback onComplete;

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late double _weight;
  late int _reps;
  late double _rpe;
  bool _showBurst = false;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  @override
  void didUpdateWidget(covariant _SetRow old) {
    super.didUpdateWidget(old);
    if (old.existing != widget.existing ||
        old.prescribedWeight != widget.prescribedWeight) {
      _hydrate();
    }
  }

  void _hydrate() {
    _weight = widget.existing?.weightKg ?? widget.prescribedWeight;
    _reps = widget.existing?.reps ?? widget.prescribedReps;
    _rpe = widget.existing?.rpe ?? 7;
  }

  void _toggleComplete() {
    final wasComplete = widget.existing?.completed ?? false;
    context.read<FitnessBloc>().add(
      SetLogged(
        exerciseId: widget.exerciseId,
        setIndex: widget.setIndex,
        weightKg: _weight,
        reps: _reps,
        rpe: _rpe,
        completed: !wasComplete,
      ),
    );
    if (!wasComplete) {
      setState(() => _showBurst = true);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isComplete = widget.existing?.completed ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isComplete
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isComplete
                ? colors.primary.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 10,
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(
              children: [
                _SetIndex(index: widget.setIndex, completed: isComplete),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Stepper(
                    label: 'kg',
                    value: _weight,
                    onChange: (v) => setState(() => _weight = v),
                    step: 2.5,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _Stepper(
                    label: 'reps',
                    value: _reps.toDouble(),
                    onChange: (v) => setState(() => _reps = v.round()),
                    step: 1,
                    integerOnly: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: _RpeSelector(
                    rpe: _rpe,
                    onChange: (v) => setState(() => _rpe = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _CheckButton(completed: isComplete, onPressed: _toggleComplete),
              ],
            ),
            if (_showBurst)
              Positioned(
                right: 0,
                child: PulsoSetCompleteBurst(
                  color: colors.primary,
                  diameter: 56,
                  onCompleted: () =>
                      mounted ? setState(() => _showBurst = false) : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SetIndex extends StatelessWidget {
  const _SetIndex({required this.index, required this.completed});
  final int index;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? colors.primary : colors.background,
        border: Border.all(color: completed ? colors.primary : colors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: TextStyle(
          color: completed ? colors.onPrimary : colors.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFamily: FitnessBrand.displayMonoFontFamily,
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChange,
    required this.step,
    this.integerOnly = false,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChange;
  final double step;
  final bool integerOnly;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = integerOnly
        ? value.round().toString()
        : (value.truncateToDouble() == value
              ? value.toStringAsFixed(0)
              : value.toStringAsFixed(1));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SmallIconButton(
              icon: Icons.remove,
              onPressed: () => onChange((value - step).clamp(0, 9999)),
            ),
            SizedBox(
              width: 38,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: FitnessBrand.displayMonoFontFamily,
                ),
              ),
            ),
            _SmallIconButton(
              icon: Icons.add,
              onPressed: () => onChange(value + step),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 22,
      height: 22,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 14,
        icon: Icon(icon, color: colors.onSurfaceMuted),
        onPressed: onPressed,
      ),
    );
  }
}

class _RpeSelector extends StatelessWidget {
  const _RpeSelector({required this.rpe, required this.onChange});
  final double rpe;
  final ValueChanged<double> onChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = rpe < 7
        ? colors.info
        : rpe < 8.5
        ? colors.warning
        : colors.error;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'RPE',
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SmallIconButton(
              icon: Icons.remove,
              onPressed: () => onChange((rpe - 0.5).clamp(1, 10)),
            ),
            SizedBox(
              width: 30,
              child: Text(
                rpe.toStringAsFixed(rpe.truncateToDouble() == rpe ? 0 : 1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFamily: FitnessBrand.displayMonoFontFamily,
                ),
              ),
            ),
            _SmallIconButton(
              icon: Icons.add,
              onPressed: () => onChange((rpe + 0.5).clamp(1, 10)),
            ),
          ],
        ),
      ],
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.completed, required this.onPressed});
  final bool completed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: completed ? colors.primary : Colors.transparent,
          border: Border.all(
            color: completed ? colors.primary : colors.border,
            width: 2,
          ),
        ),
        child: Icon(
          completed ? Icons.check_rounded : Icons.check,
          color: completed
              ? colors.onPrimary
              : colors.onSurfaceMuted.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }
}

class _FinishSessionBar extends StatelessWidget {
  const _FinishSessionBar({
    required this.totalSets,
    required this.totalVolumeKg,
    required this.onFinish,
  });

  final int totalSets;
  final double totalVolumeKg;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BarStat(label: 'SETS', value: '$totalSets'),
                _BarStat(
                  label: 'VOLUME',
                  value: '${(totalVolumeKg / 1000).toStringAsFixed(1)}t',
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: onFinish,
            child: const Text(
              'Finalizar',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarStat extends StatelessWidget {
  const _BarStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: FitnessBrand.displayMonoFontFamily,
          ),
        ),
      ],
    );
  }
}

class _RestTimerBanner extends StatelessWidget {
  const _RestTimerBanner({
    required this.state,
    required this.onAdjust,
    required this.onSkip,
  });

  final _RestTimerState state;
  final ValueChanged<int> onAdjust;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mm = (state.remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (state.remaining % 60).toString().padLeft(2, '0');
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: colors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation(colors.primary),
            minHeight: 3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.timer_outlined, color: colors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$mm:$ss',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: FitnessBrand.displayMonoFontFamily,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => onAdjust(-15),
                child: const Text('-15s'),
              ),
              TextButton(
                onPressed: () => onAdjust(15),
                child: const Text('+15s'),
              ),
              TextButton(onPressed: onSkip, child: const Text('Pular')),
            ],
          ),
        ],
      ),
    );
  }
}
