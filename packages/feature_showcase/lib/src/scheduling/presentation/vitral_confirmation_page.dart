import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/scheduling/data/vitral_specialists_catalog.dart';
import 'package:feature_showcase/src/scheduling/domain/appointment.dart';
import 'package:feature_showcase/src/scheduling/domain/service.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_bloc.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_event.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_app_bar.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_brand.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_confirmation_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                  style: textTheme.displaySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Revise os dados antes de fechar. Voce recebe o lembrete '
                  'por e-mail na vespera.',
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

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.service,
    required this.specialistName,
    required this.specialistRole,
    required this.slot,
    required this.endsAt,
    required this.colors,
    required this.textTheme,
  });

  final Service service;
  final String? specialistName;
  final String? specialistRole;
  final DateTime slot;
  final DateTime endsAt;
  final AppColorScheme colors;
  final TextTheme textTheme;

  static const _weekdayNames = [
    '',
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
  ];

  static const _months = [
    '',
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  String _formatDate(DateTime d) {
    return '${_weekdayNames[d.weekday]}, '
        '${d.day.toString().padLeft(2, '0')} ${_months[d.month]}';
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(
            label: 'Servico',
            value: service.name,
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (specialistName != null) ...[
            _Row(
              label: 'Com',
              value: specialistName!,
              caption: specialistRole,
              colors: colors,
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _Row(
            label: 'Data',
            value: _formatDate(slot),
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            label: 'Horario',
            value: '${_formatTime(slot)} - ${_formatTime(endsAt)}',
            mono: true,
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            label: 'Duracao',
            value: service.formattedDuration,
            mono: true,
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Total',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                service.formattedPrice,
                key: const Key('vitral-confirmation-total'),
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.colors,
    required this.textTheme,
    this.caption,
    this.mono = false,
  });

  final String label;
  final String value;
  final String? caption;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontFamily: mono ? VitralBrand.monoFontFamily : null,
                  fontWeight: FontWeight.w600,
                  letterSpacing: mono ? 0.4 : null,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.line,
    required this.colors,
    required this.textTheme,
  });

  final String line;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: colors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Onde',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
