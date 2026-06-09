import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/data/exercises_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/exercise_load_history_chart.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_barbell_loader.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_tempo_bars.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_copy.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_swap_exercise_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pulso_exercise_detail_widgets.dart';

/// Detalhe do exercicio — usado pra inspecionar tempo de execucao,
/// carga prescrita e historico de carga. Pushable pelo session
/// logger e pela program preview.
class PulsoExerciseDetailPage extends StatelessWidget {
  const PulsoExerciseDetailPage({required this.exerciseId, super.key});

  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        final effectiveId = state.effectiveExerciseId(exerciseId);
        final exercise = ExercisesCatalog.byId(effectiveId);
        if (exercise == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Exercício')),
            body: const Center(child: Text('Exercício não encontrado.')),
          );
        }
        final prescribed = state.prescribedWeightFor(exerciseId);
        final colors = context.colors;
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            elevation: 0,
            iconTheme: IconThemeData(color: colors.onSurface),
            title: Text(
              exercise.name,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Trocar',
                icon: Icon(Icons.swap_horiz_rounded, color: colors.accent),
                onPressed: () => _openSwap(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _MuscleChips(exercise: exercise),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: PulsoCopy(context.l10n).eyebrowPrescribedLoad),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.border),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.lg,
                  horizontal: AppSpacing.md,
                ),
                child: PulsoBarbellLoader(totalKg: prescribed),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: PulsoCopy(context.l10n).eyebrowExecutionTempo),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.border),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${exercise.targetSets} x ${exercise.targetReps} reps · '
                      'descanso ${exercise.restSeconds}s',
                      style: TextStyle(
                        color: colors.onSurfaceMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: FitnessBrand.displayMonoFontFamily,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PulsoTempoBars(tempoSeconds: exercise.tempoSeconds),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionLabel(label: PulsoCopy(context.l10n).eyebrowLoadHistory),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.border),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ExerciseLoadHistoryChart(
                  points: _buildHistory(exercise, state),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
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
        child: PulsoSwapExerciseSheet(originalExerciseId: exerciseId),
      ),
    );
  }

  /// Gera 8 pontos historicos seguindo a curva de intensidade do
  /// mesociclo do state. Carga = sugestao * multiplicador da semana;
  /// RPE oscila entre 7 e 9.5; reps usa targetReps com leve variacao.
  List<LoadHistoryPoint> _buildHistory(
    PlannedExercise exercise,
    FitnessState state,
  ) {
    final out = <LoadHistoryPoint>[];
    final weeks = state.program.weeks;
    for (var i = 0; i < weeks.length; i++) {
      final w = weeks[i];
      final weight = (exercise.suggestedWeightKg * w.intensityMultiplier)
          .roundToDouble();
      final rpeBase = w.isDeload ? 6.5 : 7.5 + (i / weeks.length) * 1.5;
      final rpe = (rpeBase + math.sin(i.toDouble()) * 0.3).clamp(5, 10);
      out.add(
        LoadHistoryPoint(
          weekLabel: 'S${w.index}',
          weightKg: weight,
          repsTopSet: exercise.targetReps,
          rpe: rpe.toDouble(),
        ),
      );
    }
    return out;
  }
}
