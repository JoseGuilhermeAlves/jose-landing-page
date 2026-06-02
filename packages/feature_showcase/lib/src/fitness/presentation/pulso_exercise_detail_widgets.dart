part of 'pulso_exercise_detail_page.dart';

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      label,
      style: TextStyle(
        color: colors.onSurfaceMuted,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
      ),
    );
  }
}

class _MuscleChips extends StatelessWidget {
  const _MuscleChips({required this.exercise});
  final PlannedExercise exercise;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < exercise.muscleGroups.length; i++)
          Container(
            decoration: BoxDecoration(
              color: i == 0
                  ? colors.primary.withValues(alpha: 0.16)
                  : colors.surfaceMuted,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: i == 0
                    ? colors.primary.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            child: Text(
              exercise.muscleGroups[i].label,
              style: TextStyle(
                color: i == 0 ? colors.primary : colors.onSurface,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
      ],
    );
  }
}
