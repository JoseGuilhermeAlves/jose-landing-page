import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/scheduling/data/vitral_specialists_catalog.dart';
import 'package:feature_showcase/src/scheduling/domain/service.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_bloc.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_event.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_state.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_app_bar.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_brand.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_confirmation_page.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_navigation.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'vitral_calendar_widgets.dart';

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
    final specialist = VitralSpecialistsCatalog.byId(
      widget.service.specialistId,
    );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const VitralAppBar(),
      body: MockBodyConstraint(
        child: SafeArea(
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
                      context.read<SchedulingBloc>().add(
                        SchedulingDateSelected(date),
                      );
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
                            onCancel: (slot) {
                              if (_selectedSlot == slot) {
                                setState(() => _selectedSlot = null);
                              }
                              context.read<SchedulingBloc>().add(
                                SchedulingSlotCancelled(slot),
                              );
                            },
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
                      context.read<SchedulingBloc>().add(
                        SchedulingSlotBooked(slot),
                      );
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
      ),
    );
  }
}
