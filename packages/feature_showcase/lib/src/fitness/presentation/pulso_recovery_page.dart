import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/data/recovery_catalog.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_copy.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/recovery_snapshot.dart';
import 'package:feature_showcase/src/fitness/domain/sleep_window.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_body_diagram.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_recovery_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dashboard de recovery. Recovery ring hero, breakdown biometrico,
/// body diagram interativo com heatmap muscular, strain dos ultimos
/// 7 dias e janela de sono.
class PulsoRecoveryPage extends StatefulWidget {
  const PulsoRecoveryPage({super.key});

  @override
  State<PulsoRecoveryPage> createState() => _PulsoRecoveryPageState();
}

class _PulsoRecoveryPageState extends State<PulsoRecoveryPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringAnim;
  MuscleGroup? _muscleFocus;

  @override
  void initState() {
    super.initState();
    _ringAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ringAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: BlocBuilder<FitnessBloc, FitnessState>(
          builder: (context, state) {
            final snapshot = state.selectedRecoverySnapshot;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FitnessBloc>().add(const RecoveryRefreshed());
                _ringAnim
                  ..reset()
                  ..forward();
                await Future<void>.delayed(const Duration(milliseconds: 400));
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _Header(),
                  const SizedBox(height: AppSpacing.md),
                  _HistoryStrip(
                    history: state.recoveryHistory,
                    selectedOffset: state.recoveryHistoryOffset,
                    onSelect: (offset) => context.read<FitnessBloc>().add(
                      RecoveryHistorySelected(offset),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: PulsoRecoveryRing(
                      percent: snapshot.recoveryPercent,
                      diameter: 240,
                      animation: _ringAnim,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _BreakdownCard(snapshot: snapshot),
                  const SizedBox(height: AppSpacing.lg),
                  _SleepCard(snapshot: snapshot),
                  const SizedBox(height: AppSpacing.lg),
                  _MuscleHeatmapCard(
                    snapshot: snapshot,
                    focus: _muscleFocus,
                    onPick: (group) => setState(() => _muscleFocus = group),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _StrainHistoryCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PulsoCopy(context.l10n).eyebrowRecovery,
          style: TextStyle(
            color: colors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Como o corpo respondeu ontem.',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _HistoryStrip extends StatelessWidget {
  const _HistoryStrip({
    required this.history,
    required this.selectedOffset,
    required this.onSelect,
  });

  final List<RecoverySnapshot> history;
  final int selectedOffset;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: history.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final offset = -(history.length - 1 - i);
          final snap = history[i];
          final selected = offset == selectedOffset;
          final color = FitnessBrand.recoveryColor(snap.recoveryPercent);
          return GestureDetector(
            onTap: () => onSelect(offset),
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: selected ? colors.surface : colors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: selected ? color : Colors.transparent,
                  width: 1.6,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snap.recoveryPercent.toStringAsFixed(0),
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: FitnessBrand.displayMonoFontFamily,
                    ),
                  ),
                  Text(
                    offset == 0 ? 'HOJE' : 'D$offset',
                    style: TextStyle(
                      color: colors.onSurfaceMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.snapshot});
  final RecoverySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PulsoCopy(context.l10n).eyebrowContributors,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Bio(
            label: 'HRV',
            value: '${snapshot.hrvMs.toStringAsFixed(0)} ms',
            barValue: (snapshot.hrvMs / 80).clamp(0, 1).toDouble(),
            color: colors.primary,
          ),
          _Bio(
            label: 'Freq. cardiaca em repouso',
            value: '${snapshot.restingHeartRate.toStringAsFixed(0)} bpm',
            barValue:
                1 - (snapshot.restingHeartRate / 80).clamp(0, 1).toDouble(),
            color: colors.info,
          ),
          _Bio(
            label: 'Respiratoria',
            value: '${snapshot.respiratoryRate.toStringAsFixed(1)} rpm',
            barValue:
                1 - (snapshot.respiratoryRate / 22).clamp(0, 1).toDouble(),
            color: colors.warning,
          ),
        ],
      ),
    );
  }
}

class _Bio extends StatelessWidget {
  const _Bio({
    required this.label,
    required this.value,
    required this.barValue,
    required this.color,
  });

  final String label;
  final String value;
  final double barValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: FitnessBrand.displayMonoFontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: barValue,
              backgroundColor: colors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  const _SleepCard({required this.snapshot});
  final RecoverySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sleep = snapshot.sleep;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PulsoCopy(context.l10n).eyebrowSleep,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sleep.asleepLabel,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  fontFamily: FitnessBrand.displayMonoFontFamily,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${sleep.efficiencyPercent.toStringAsFixed(0)}% eficiencia',
                  style: TextStyle(
                    color: colors.onSurfaceMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SleepBar(sleep: sleep),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _SleepLegend(
                color: const Color(0xFF7B8FFF),
                label: 'Profundo',
                value: sleep.deepPercent,
              ),
              const SizedBox(width: AppSpacing.md),
              _SleepLegend(
                color: const Color(0xFF5AC8FA),
                label: 'REM',
                value: sleep.remPercent,
              ),
              const SizedBox(width: AppSpacing.md),
              _SleepLegend(
                color: const Color(0xFF2A2A33),
                label: 'Leve',
                value: sleep.lightPercent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SleepBar extends StatelessWidget {
  const _SleepBar({required this.sleep});
  final SleepWindow sleep;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Row(
        children: [
          Expanded(
            flex: sleep.deepPercent.round().clamp(1, 100),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF7B8FFF),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: sleep.remPercent.round().clamp(1, 100),
            child: Container(color: const Color(0xFF5AC8FA)),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: sleep.lightPercent.round().clamp(1, 100),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A33),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepLegend extends StatelessWidget {
  const _SleepLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ${value.toStringAsFixed(0)}%',
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _MuscleHeatmapCard extends StatelessWidget {
  const _MuscleHeatmapCard({
    required this.snapshot,
    required this.focus,
    required this.onPick,
  });

  final RecoverySnapshot snapshot;
  final MuscleGroup? focus;
  final ValueChanged<MuscleGroup> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final score = focus == null
        ? snapshot.muscleRecovery.average
        : snapshot.muscleRecovery.scoreFor(focus!);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PulsoCopy(context.l10n).eyebrowMuscleHeatmap,
                  style: TextStyle(
                    color: colors.onSurfaceMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  focus?.label ?? 'Geral',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: FitnessBrand.recoveryColor(score),
                    fontSize: 42,
                    fontWeight: FontWeight.w300,
                    fontFamily: FitnessBrand.displayMonoFontFamily,
                    letterSpacing: -2,
                  ),
                ),
                Text(
                  PulsoCopy(context.l10n).muscleAdvice(score),
                  style: TextStyle(
                    color: colors.onSurfaceMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: PulsoBodyDiagram(
              recovery: snapshot.muscleRecovery,
              onTap: onPick,
            ),
          ),
        ],
      ),
    );
  }

}

class _StrainHistoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final history = RecoveryCatalog.strainHistory();
    final max = history.reduce((a, b) => a > b ? a : b);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PulsoCopy(context.l10n).eyebrowStrainHistory,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < history.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            history[i].toStringAsFixed(1),
                            style: TextStyle(
                              color: colors.onSurfaceMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: FitnessBrand.displayMonoFontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: (history[i] / max) * 80,
                            decoration: BoxDecoration(
                              color: FitnessBrand.strainColor(history[i]),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            i == history.length - 1
                                ? 'HJ'
                                : 'D-${history.length - 1 - i}',
                            style: TextStyle(
                              color: colors.onSurfaceMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
