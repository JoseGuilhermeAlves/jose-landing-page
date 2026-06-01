part of 'pulso_session_logger_page.dart';

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
                _BarStat(label: PulsoCopy(context.l10n).labelSets, value: '$totalSets'),
                _BarStat(
                  label: PulsoCopy(context.l10n).labelVolume,
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
            child: Text(
              PulsoCopy(context.l10n).finishWorkout,
              style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.4),
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
    required this.timer,
    required this.onAdjust,
    required this.onSkip,
  });

  final RestTimer timer;
  final ValueChanged<int> onAdjust;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mm = (timer.remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (timer.remaining % 60).toString().padLeft(2, '0');
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
            value: timer.progress,
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
