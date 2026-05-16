import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/vitral_specialists_catalog.dart';
import 'package:feature_showcase/src/domain/service.dart';
import 'package:feature_showcase/src/presentation/scheduling/scheduling_bloc.dart';
import 'package:feature_showcase/src/presentation/scheduling/scheduling_event.dart';
import 'package:feature_showcase/src/presentation/scheduling/scheduling_state.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_app_bar.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_brand.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_confirmation_page.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Calendario Vitral — escolha de dia + slot pra um servico. Header
/// resume o servico + profissional. Strip horizontal de dias da
/// semana (14 dias) + grid de slots em mono. CTA "Continuar" empurra
/// `VitralConfirmationPage` com servico e slot.
///
/// Estado local: o slot selecionado fica em `_selectedSlot` (nao
/// no bloc) pra permitir review antes da confirmacao. O bloc so
/// recebe `SchedulingSlotBooked` quando o usuario aperta Continuar.
class VitralCalendarPage extends StatefulWidget {
  const VitralCalendarPage({required this.service, super.key});

  final Service service;

  @override
  State<VitralCalendarPage> createState() => _VitralCalendarPageState();
}

class _VitralCalendarPageState extends State<VitralCalendarPage> {
  DateTime? _selectedSlot;

  /// Slot atualmente selecionado pelo usuario. Limpa quando o
  /// usuario troca de dia ou cancela a selecao.
  DateTime? get selectedSlot => _selectedSlot;

  static const _weekdayLabels = [
    'seg',
    'ter',
    'qua',
    'qui',
    'sex',
    'sab',
    'dom',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final specialist =
        VitralSpecialistsCatalog.byId(widget.service.specialistId);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const VitralAppBar(),
      body: SafeArea(
        top: false,
        child: BlocBuilder<SchedulingBloc, SchedulingState>(
          builder: (context, state) {
            final slots = state.slotsFor(state.selectedDate);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'agendamento'.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.accent,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        widget.service.name,
                        style: textTheme.headlineMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _ServiceSummaryRow(
                        service: widget.service,
                        specialistName: specialist?.name,
                        specialistRole: specialist?.role,
                        colors: colors,
                        textTheme: textTheme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _DateStrip(
                  state: state,
                  onPicked: (date) {
                    setState(() => _selectedSlot = null);
                    context
                        .read<SchedulingBloc>()
                        .add(SchedulingDateSelected(date));
                  },
                  colors: colors,
                  textTheme: textTheme,
                  weekdayLabels: _weekdayLabels,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Selecione um horario',
                          style: textTheme.titleSmall?.copyWith(
                            color: colors.onSurfaceMuted,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _SlotsGrid(
                          slots: slots,
                          selectedSlot: _selectedSlot,
                          onPicked: (slot) =>
                              setState(() => _selectedSlot = slot),
                          colors: colors,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
                _ContinueCta(
                  enabled: _selectedSlot != null,
                  onTap: () {
                    if (_selectedSlot == null) return;
                    final slot = _selectedSlot!;
                    // Marca o slot como reservado no bloc agora — UI do
                    // calendario passa a mostrar "Reservado" se voltar.
                    context
                        .read<SchedulingBloc>()
                        .add(SchedulingSlotBooked(slot));
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => vitralWithDemoBloc(
                          context,
                          VitralConfirmationPage(
                            service: widget.service,
                            slot: slot,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceMuted,
            ),
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
    required this.colors,
    required this.textTheme,
  });

  final List<AppointmentSlot> slots;
  final DateTime? selectedSlot;
  final ValueChanged<DateTime> onPicked;
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
    required this.colors,
    required this.textTheme,
  });

  final AppointmentSlot slot;
  final bool selected;
  final ValueChanged<DateTime> onPicked;
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
          labelColor:
              selected ? colors.onPrimary : colors.onSurfaceMuted,
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
        border: Border(
          top: BorderSide(color: colors.border),
        ),
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
