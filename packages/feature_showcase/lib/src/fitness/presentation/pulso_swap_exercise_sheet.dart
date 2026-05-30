import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/data/exercises_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Modal de troca de exercicio. Lista alternativas validas (mesma
/// cadeia muscular) declaradas no catalogo. Tap aplica swap e fecha.
class PulsoSwapExerciseSheet extends StatelessWidget {
  const PulsoSwapExerciseSheet({required this.originalExerciseId, super.key});

  final String originalExerciseId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final alternates = ExercisesCatalog.alternatesFor(originalExerciseId);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            alignment: Alignment.center,
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            context.l10n.pulso_swapExerciseTitle,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            context.l10n.pulso_swapExerciseSubtitle,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (alternates.isEmpty)
            Text(
              context.l10n.pulso_swapExerciseEmpty,
              style: TextStyle(color: colors.onSurfaceMuted),
            )
          else
            for (final ex in alternates)
              _AlternateTile(
                exercise: ex,
                onPick: () {
                  context.read<FitnessBloc>().add(
                    ExerciseSwapped(
                      originalExerciseId: originalExerciseId,
                      replacementExerciseId: ex.id,
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
        ],
      ),
    );
  }
}

class _AlternateTile extends StatelessWidget {
  const _AlternateTile({required this.exercise, required this.onPick});
  final PlannedExercise exercise;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onPick,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exercise.muscleGroups.map((m) => m.label).join(' · '),
                      style: TextStyle(
                        color: colors.onSurfaceMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${exercise.targetSets}x${exercise.targetReps}',
                style: TextStyle(
                  color: colors.onSurfaceMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
