part of 'pulso_today_page.dart';

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.weekday});
  final int weekday;

  static const _weekdayLabels = [
    'Segunda',
    'Terca',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sabado',
    'Domingo',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: colors.primary.withValues(alpha: 0.12),
              border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Text(
              'P',
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PulsoCopy(context.l10n).brandName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  _weekdayLabels[(weekday - 1).clamp(0, 6)],
                  style: TextStyle(
                    color: colors.onSurfaceMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Espaco reservado pro botao de fechar do shell — evita que o
          // titulo encoste no overlay do Stack pai.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  const _RecoveryCard({required this.percent});
  final double percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      child: Column(
        children: [
          PulsoRecoveryRing(percent: percent, diameter: 220),
          const SizedBox(height: AppSpacing.md),
          Text(
            PulsoCopy(context.l10n).recoveryAdvice(percent),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StrainAndProgramRow extends StatelessWidget {
  const _StrainAndProgramRow({required this.state, required this.template});
  final FitnessState state;
  final SessionTemplate? template;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strain = state.strainToday;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.border),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: PulsoStrainDial(
                  value: strain.accumulated,
                  target: strain.target,
                  diameter: 160,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: colors.border),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricLine(
                    label: 'PROGRAMA',
                    value: state.program.name,
                    monospace: false,
                  ),
                  _MetricLine(
                    label: 'SEMANA',
                    value:
                        '${state.program.currentWeekIndex} / ${state.program.durationWeeks}',
                  ),
                  _MetricLine(
                    label: 'FOCO',
                    value: state.program.currentWeek?.label ?? '—',
                  ),
                  _MetricLine(
                    label: 'STRAIN ALVO',
                    value: strain.target.toStringAsFixed(1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({
    required this.label,
    required this.value,
    this.monospace = true,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: monospace ? FitnessBrand.displayMonoFontFamily : null,
          ),
        ),
      ],
    );
  }
}

class _BiometricsCard extends StatelessWidget {
  const _BiometricsCard({required this.snapshot});
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
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: _Biometric(
              label: 'HRV',
              value: snapshot.hrvMs.toStringAsFixed(0),
              unit: 'ms',
            ),
          ),
          _Divider(color: colors.border),
          Expanded(
            child: _Biometric(
              label: 'RHR',
              value: snapshot.restingHeartRate.toStringAsFixed(0),
              unit: 'bpm',
            ),
          ),
          _Divider(color: colors.border),
          Expanded(
            child: _Biometric(
              label: 'SONO',
              value: snapshot.sleep.asleepLabel,
              unit: '',
            ),
          ),
        ],
      ),
    );
  }
}

class _Biometric extends StatelessWidget {
  const _Biometric({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                fontFamily: FitnessBrand.displayMonoFontFamily,
              ),
            ),
            if (unit.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: colors.onSurfaceMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 38, color: color);
  }
}

class _SessionCtaCard extends StatelessWidget {
  const _SessionCtaCard({required this.template, required this.weekday});
  final SessionTemplate template;
  final int weekday;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final muscles = template.focusMuscles.map((m) => m.label).join(' · ');
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.18),
            colors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.primary.withValues(alpha: 0.36)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            PulsoCopy(context.l10n).eyebrowTodayWorkout,
            style: TextStyle(
              color: colors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            template.label,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            muscles,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _TagChip(
                icon: Icons.timer_outlined,
                text: '${template.estimatedMinutes} min',
              ),
              const SizedBox(width: AppSpacing.xs),
              _TagChip(
                icon: Icons.format_list_bulleted_rounded,
                text: '${template.exercises.length} ex.',
              ),
              const SizedBox(width: AppSpacing.xs),
              _TagChip(
                icon: Icons.bolt_outlined,
                text: '${template.totalTargetSets} sets',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () => _startSession(context),
              child: Text(
                PulsoCopy(context.l10n).startWorkout,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startSession(BuildContext context) {
    final bloc = context.read<FitnessBloc>();
    bloc.add(SessionStarted(weekday: weekday, now: DateTime.now()));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const PulsoSessionLoggerPage(),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.onSurfaceMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDayCard extends StatelessWidget {
  const _RestDayCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.bedtime_outlined, color: colors.accent, size: 36),
          const SizedBox(height: AppSpacing.sm),
          Text(
            PulsoCopy(context.l10n).restDayTitle,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            PulsoCopy(context.l10n).restDayBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
