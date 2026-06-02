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

part 'pulso_recovery_cards.dart';

/// Dashboard de recovery. Recovery ring hero, breakdown biometrico,
/// body diagram interativo com heatmap muscular, strain dos ultimos
/// 7 dias e janela de sono.
///
/// Os cards (header, history strip, breakdown, sono, heatmap muscular,
/// strain history) vivem na part irma `pulso_recovery_cards.dart`.
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
            final isMobile = context.isMobile;
            final cardGap = isMobile ? AppSpacing.md : AppSpacing.lg;
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
                  SizedBox(height: cardGap),
                  Center(
                    child: PulsoRecoveryRing(
                      percent: snapshot.recoveryPercent,
                      diameter: isMobile ? 184 : 240,
                      animation: _ringAnim,
                    ),
                  ),
                  SizedBox(height: cardGap),
                  _BreakdownCard(snapshot: snapshot),
                  SizedBox(height: cardGap),
                  _SleepCard(snapshot: snapshot),
                  SizedBox(height: cardGap),
                  _MuscleHeatmapCard(
                    snapshot: snapshot,
                    focus: _muscleFocus,
                    onPick: (group) => setState(() => _muscleFocus = group),
                  ),
                  SizedBox(height: cardGap),
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
