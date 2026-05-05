import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/presentation/scheduling/scheduling_bloc.dart';
import 'package:feature_showcase/src/presentation/scheduling/scheduling_event.dart';
import 'package:feature_showcase/src/presentation/scheduling/scheduling_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela do mock de agendamento. Strip horizontal de 14 dias + grid
/// de 18 slots (9h–17:30) pra data selecionada. Tap em slot livre
/// reserva; tap em reservado cancela; indisponiveis nao reagem.
class SchedulingDemo extends StatelessWidget {
  const SchedulingDemo({
    required this.today,
    this.preBookedSlots,
    super.key,
  });

  /// Hoje como ancora pro range. Em produto real,
  /// `today: DateTime.now()`.
  final DateTime today;

  /// Override do mock pre-bookado. Quando null, usa a regra
  /// deterministica do bloc.
  final Set<DateTime>? preBookedSlots;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => SchedulingBloc(
        today: today,
        preBookedSlots: preBookedSlots,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          title: Text('Agenda demo', style: textTheme.titleLarge),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        _DateStrip(),
        Expanded(child: _SlotsGrid()),
      ],
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip();

  static const List<String> _weekdayLabels = [
    'seg', 'ter', 'qua', 'qui', 'sex', 'sab', 'dom',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<SchedulingBloc, SchedulingState>(
      builder: (context, state) {
        final dates = state.availableDates;
        // Strip pequena (14 itens) — SingleChildScrollView + Row eager
        // garante que tester veja todos sem scrollar; ListView.builder
        // iria lazy-render so os visiveis na viewport.
        return SizedBox(
          height: 96,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                for (var i = 0; i < dates.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  _DayChip(
                    date: dates[i],
                    selected: _sameDay(dates[i], state.selectedDate),
                    weekday: _weekdayLabels[dates[i].weekday - 1],
                    colors: colors,
                    textTheme: textTheme,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.selected,
    required this.weekday,
    required this.colors,
    required this.textTheme,
  });

  final DateTime date;
  final bool selected;
  final String weekday;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('scheduling-day-chip'),
      onTap: () =>
          context.read<SchedulingBloc>().add(SchedulingDateSelected(date)),
      child: AnimatedContainer(
        duration: AppDuration.fast,
        width: 64,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weekday,
              style: textTheme.labelSmall?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date.day.toString().padLeft(2, '0'),
              style: textTheme.titleLarge?.copyWith(
                color: selected ? colors.onPrimary : colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  const _SlotsGrid();

  int _columnsFor(Breakpoint bp) => switch (bp) {
        Breakpoint.mobile => 2,
        Breakpoint.tablet => 3,
        Breakpoint.desktop || Breakpoint.wide => 4,
      };

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(context.breakpoint);

    return BlocBuilder<SchedulingBloc, SchedulingState>(
      builder: (context, state) {
        final slots = state.slotsFor(state.selectedDate);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: LayoutBuilder(
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
                      child: _SlotTile(slot: slot),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({required this.slot});

  final AppointmentSlot slot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final bloc = context.read<SchedulingBloc>();

    final palette = switch (slot.status) {
      SlotStatus.free => (
          background: colors.surface,
          border: colors.border,
          text: colors.onSurface,
          label: 'Disponivel',
          labelColor: colors.onSurfaceMuted,
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

    final disabled = slot.status == SlotStatus.unavailable;

    return AnimatedContainer(
      key: const Key('scheduling-slot-tile'),
      duration: AppDuration.fast,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: palette.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: disabled
              ? null
              : () {
                  if (slot.status == SlotStatus.booked) {
                    bloc.add(SchedulingSlotCancelled(slot.start));
                  } else {
                    bloc.add(SchedulingSlotBooked(slot.start));
                  }
                },
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
                  style: textTheme.titleMedium?.copyWith(color: palette.text),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  palette.label,
                  style: textTheme.labelSmall?.copyWith(color: palette.labelColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
