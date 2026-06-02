part of 'vitral_calendar_page.dart';

class _ServiceSummaryRow extends StatelessWidget {
  const _ServiceSummaryRow({
    required this.service,
    required this.specialistName,
    required this.specialistRole,
    required this.colors,
    required this.textTheme,
  });

  final Service service;
  final String? specialistName;
  final String? specialistRole;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (specialistName != null)
          Text(
            'com $specialistName',
            style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceMuted),
          ),
        _MiniChip(
          label: service.formattedDuration,
          icon: Icons.schedule_outlined,
          colors: colors,
          textTheme: textTheme,
        ),
        _MiniChip(
          label: service.formattedPrice,
          icon: Icons.payments_outlined,
          colors: colors,
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.label,
    required this.icon,
    required this.colors,
    required this.textTheme,
  });

  final String label;
  final IconData icon;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.onSurfaceMuted),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurface,
              fontFamily: VitralBrand.monoFontFamily,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.state,
    required this.onPicked,
    required this.colors,
    required this.textTheme,
    required this.weekdayLabels,
  });

  final SchedulingState state;
  final ValueChanged<DateTime> onPicked;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final List<String> weekdayLabels;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final dates = state.availableDates;
    return SizedBox(
      height: 88,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            for (var i = 0; i < dates.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              _DayChip(
                date: dates[i],
                selected: _sameDay(dates[i], state.selectedDate),
                weekday: weekdayLabels[dates[i].weekday - 1],
                onTap: () => onPicked(dates[i]),
                colors: colors,
                textTheme: textTheme,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.selected,
    required this.weekday,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  final DateTime date;
  final bool selected;
  final String weekday;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('scheduling-day-chip'),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        width: 64,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? colors.primary : colors.border),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weekday,
              style: textTheme.labelSmall?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurfaceMuted,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date.day.toString().padLeft(2, '0'),
              style: textTheme.titleLarge?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurface,
                fontFamily: VitralBrand.monoFontFamily,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  const _SlotsGrid({
    required this.slots,
    required this.selectedSlot,
    required this.onPicked,
    required this.onCancel,
    required this.colors,
    required this.textTheme,
  });

  final List<AppointmentSlot> slots;
  final DateTime? selectedSlot;
  final ValueChanged<DateTime> onPicked;
  final ValueChanged<DateTime> onCancel;
  final AppColorScheme colors;
  final TextTheme textTheme;

  int _columnsFor(Breakpoint bp) => switch (bp) {
    Breakpoint.mobile => 3,
    Breakpoint.tablet => 4,
    Breakpoint.desktop || Breakpoint.wide => 6,
  };

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(context.breakpoint);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.sm;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final slot in slots)
              SizedBox(
                width: tileWidth,
                child: _SlotTile(
                  slot: slot,
                  selected: selectedSlot == slot.start,
                  onPicked: onPicked,
                  onCancel: onCancel,
                  colors: colors,
                  textTheme: textTheme,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.selected,
    required this.onPicked,
    required this.onCancel,
    required this.colors,
    required this.textTheme,
  });

  final AppointmentSlot slot;
  final bool selected;
  final ValueChanged<DateTime> onPicked;
  final ValueChanged<DateTime> onCancel;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final palette = switch (slot.status) {
      SlotStatus.free => (
        background: selected ? colors.primary : colors.surface,
        border: selected ? colors.primary : colors.border,
        text: selected ? colors.onPrimary : colors.onSurface,
        label: selected ? 'Escolhido' : 'Disponivel',
        labelColor: selected ? colors.onPrimary : colors.onSurfaceMuted,
      ),
      SlotStatus.booked => (
        background: colors.primary.withValues(alpha: 0.18),
        border: colors.primary,
        text: colors.onSurface,
        label: 'Reservado',
        labelColor: colors.primary,
      ),
      SlotStatus.unavailable => (
        background: colors.surfaceMuted,
        border: colors.border,
        text: colors.onSurfaceMuted,
        label: 'Indisponivel',
        labelColor: colors.onSurfaceMuted,
      ),
    };

    final disabled = slot.status != SlotStatus.free;

    final isBooked = slot.status == SlotStatus.booked;

    return AnimatedContainer(
      key: const Key('scheduling-slot-tile'),
      duration: AppDuration.fast,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: palette.border),
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: disabled ? null : () => onPicked(slot.start),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(slot.start),
                      style: textTheme.titleMedium?.copyWith(
                        color: palette.text,
                        fontFamily: VitralBrand.monoFontFamily,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      palette.label,
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.labelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botao "X" so aparece em slots reservados pelo usuario —
          // dispara `SchedulingSlotCancelled` no bloc.
          if (isBooked)
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                key: const Key('scheduling-slot-cancel-button'),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                tooltip: 'Cancelar reserva',
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colors.primary,
                ),
                onPressed: () => onCancel(slot.start),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _ContinueCta extends StatelessWidget {
  const _ContinueCta({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: AppButton(
        key: const Key('vitral-calendar-continue'),
        label: 'Continuar',
        icon: Icons.arrow_forward_rounded,
        size: AppButtonSize.large,
        expand: true,
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}
