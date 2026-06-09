import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/scheduling/data/vitral_specialists_catalog.dart';
import 'package:feature_showcase/src/scheduling/domain/appointment.dart';
import 'package:feature_showcase/src/scheduling/domain/service.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_bloc.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_event.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_app_bar.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_brand.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_confirmation_badge.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'vitral_confirmation_widgets.dart';

/// Tela de confirmacao do agendamento Vitral — recebe Service + slot,
/// monta um `Appointment` e mostra resumo completo (servico, profis-
/// sional, data/hora, duracao, preco, endereco mock). CTA "Confirmar
/// agendamento" dispara `SchedulingAppointmentConfirmed` no bloc e
/// volta pra home (popUntil isFirst).
class VitralConfirmationPage extends StatelessWidget {
  const VitralConfirmationPage({
    required this.service,
    required this.slot,
    super.key,
  });

  final Service service;
  final DateTime slot;

  static const String _addressLine = 'Rua Aurora, 217 · 4o andar · Centro · SP';

  /// Contador global pra ids sequenciais de pedido nesta sessao. Foge
  /// dos getters do state pra manter o id determinado *antes* da
  /// confirmacao — assim a UI pode exibir o id na pagina antes de
  /// efetivamente persistir.
  static int _orderCounter = 0;

  /// Reset entre testes — espelha o padrao do CartBloc.
  static void resetOrderCounter() => _orderCounter = 0;

  Appointment _buildAppointment() {
    final specialist = VitralSpecialistsCatalog.byId(service.specialistId);
    _orderCounter += 1;
    final id = 'VIT-${_orderCounter.toString().padLeft(4, '0')}';
    return Appointment(
      id: id,
      serviceId: service.id,
      serviceName: service.name,
      specialistId: service.specialistId,
      specialistName: specialist?.name ?? 'Especialista',
      slot: slot,
      durationMinutes: service.durationMinutes,
      priceCents: service.priceCents,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final specialist = VitralSpecialistsCatalog.byId(service.specialistId);
    final endsAt = slot.add(Duration(minutes: service.durationMinutes));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const VitralAppBar(),
      body: MockBodyConstraint(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: VitralConfirmationBadge(
                    fillColor: colors.primary,
                    checkColor: colors.onPrimary,
                    ringColor: colors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'tudo certo'.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.accent,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Confirmar agendamento?',
                  key: const Key('vitral-confirmation-title'),
                  style: context
                      .responsive(
                        mobile: textTheme.headlineMedium,
                        desktop: textTheme.displaySmall,
                      )
                      ?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Revise os dados antes de fechar. Você recebe o lembrete '
                  'por e-mail na véspera.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _DetailsCard(
                  service: service,
                  specialistName: specialist?.name,
                  specialistRole: specialist?.role,
                  slot: slot,
                  endsAt: endsAt,
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                _AddressCard(
                  line: _addressLine,
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  key: const Key('vitral-confirmation-confirm'),
                  label: 'Confirmar agendamento',
                  icon: Icons.check_rounded,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: () {
                    final appt = _buildAppointment();
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    context.read<SchedulingBloc>().add(
                      SchedulingAppointmentConfirmed(appt),
                    );
                    navigator.popUntil((r) => r.isFirst);
                    messenger.showSnackBar(
                      SnackBar(
                        key: const Key('vitral-confirmation-snackbar'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: colors.primary,
                        content: Text(
                          'Agendamento ${appt.id} confirmado. '
                          'Lembrete por e-mail na vespera.',
                          style: TextStyle(color: colors.onPrimary),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
