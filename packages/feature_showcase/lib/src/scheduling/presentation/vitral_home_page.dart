import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/shared/presentation/mock_section_label.dart';
import 'package:feature_showcase/src/scheduling/data/vitral_specialists_catalog.dart';
import 'package:feature_showcase/src/scheduling/domain/appointment.dart';
import 'package:feature_showcase/src/scheduling/domain/service_category.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_bloc.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_event.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_state.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_app_bar.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_brand.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_category_illustration.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_clock_painter.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_hero_backdrop.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_navigation.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_service_list_page.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_specialist_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Home da marca Vitral — entry point do demo de agendamento.
/// Composta por:
/// - hero com backdrop animado (grid de horas + cursor varrendo) e
///   relogio analogico real ao lado;
/// - card de proximo agendamento (quando existe);
/// - strip de categorias de servico com ilustracao por categoria;
/// - lista de profissionais em destaque com avatar monograma.
class VitralHomePage extends StatelessWidget {
  const VitralHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: VitralAppBar(
        leading: IconButton(
          key: const Key('vitral-close-demo'),
          tooltip: context.l10n.vitral_closeDemoTooltip,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: MockBodyConstraint(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCard(colors: colors, textTheme: textTheme),
                const SizedBox(height: AppSpacing.xl),
                BlocBuilder<SchedulingBloc, SchedulingState>(
                  builder: (context, state) {
                    final next = state.nextAppointment;
                    if (next == null) {
                      return _NoAppointmentCard(
                        colors: colors,
                        textTheme: textTheme,
                      );
                    }
                    final others = [
                      for (final a in state.confirmedAppointments)
                        if (a.id != next.id) a,
                    ]..sort((a, b) => a.slot.compareTo(b.slot));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NextAppointmentCard(
                          appointment: next,
                          colors: colors,
                          textTheme: textTheme,
                          onCancel: () => _confirmCancelAppointment(
                            context,
                            next.id,
                            next.serviceName,
                          ),
                        ),
                        if (others.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          _OtherAppointmentsList(
                            appointments: others,
                            colors: colors,
                            textTheme: textTheme,
                            onCancel: (id, label) =>
                                _confirmCancelAppointment(context, id, label),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                MockSectionLabel(
                  eyebrow: 'Categorias',
                  title: context.l10n.vitral_categoriesTitle,
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                _CategoriesStrip(colors: colors, textTheme: textTheme),
                const SizedBox(height: AppSpacing.xl),
                MockSectionLabel(
                  eyebrow: 'Profissionais',
                  title: context.l10n.vitral_specialistsTitle,
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(height: AppSpacing.md),
                _SpecialistsList(colors: colors, textTheme: textTheme),
                const SizedBox(height: AppSpacing.xxl),
                _AboutBlock(colors: colors, textTheme: textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HERO
// =============================================================================

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.colors, required this.textTheme});

  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surface, colors.surfaceMuted],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            Positioned.fill(
              child: VitralHeroBackdrop(
                gridColor: colors.primary.withValues(alpha: 0.12),
                cursorColor: colors.accent.withValues(alpha: 0.20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'estudio de servicos · sao paulo',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          VitralBrand.tagline,
                          style: textTheme.displaySmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Consultoria, fotografia, design e marketing. '
                          'Marque a sessao em dois toques.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          key: const Key('vitral-cta-services'),
                          label: 'Ver serviços',
                          icon: Icons.arrow_forward_rounded,
                          size: AppButtonSize.large,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => vitralWithDemoBloc(
                                context,
                                const VitralServiceListPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Relogio analogico na lateral direita do hero.
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.lg),
                    child: VitralClockPainter(hour: 10, minute: 8, size: 96),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PROXIMO AGENDAMENTO
// =============================================================================

/// Confirma e dispara cancelamento de agendamento via dialog. Mantido
/// como funcao top-level pra reuso pelo card principal e pela lista
/// secundaria — ambos passam o id e o label do agendamento.
Future<void> _confirmCancelAppointment(
  BuildContext context,
  String appointmentId,
  String serviceLabel,
) async {
  final bloc = context.read<SchedulingBloc>();
  final colors = context.colors;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cancelar agendamento?'),
      content: Text(
        'O agendamento "$serviceLabel" ($appointmentId) sera removido '
        'e o slot fica livre pra outras reservas.',
        style: TextStyle(color: colors.onSurfaceMuted),
      ),
      actions: [
        TextButton(
          key: const Key('vitral-cancel-dialog-back'),
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Voltar'),
        ),
        TextButton(
          key: const Key('vitral-cancel-dialog-confirm'),
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(foregroundColor: colors.error),
          child: const Text('Cancelar agendamento'),
        ),
      ],
    ),
  );
  if (ok ?? false) {
    bloc.add(SchedulingAppointmentCancelled(appointmentId));
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({
    required this.appointment,
    required this.colors,
    required this.textTheme,
    required this.onCancel,
  });

  final Appointment appointment;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final VoidCallback onCancel;

  static const _weekdayNames = [
    '',
    'seg',
    'ter',
    'qua',
    'qui',
    'sex',
    'sab',
    'dom',
  ];

  String _formatDate(DateTime d) {
    final weekday = _weekdayNames[d.weekday];
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$weekday $day/$month';
  }

  String _formatTime(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('vitral-next-appointment-card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'proximo agendamento',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(appointment.slot),
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  fontFamily: VitralBrand.monoFontFamily,
                ),
              ),
              IconButton(
                key: const Key('vitral-cancel-next-button'),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                tooltip: 'Cancelar agendamento',
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: colors.onSurfaceMuted,
                ),
                onPressed: onCancel,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            appointment.serviceName,
            style: textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'com ${appointment.specialistName}',
            style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 14,
                color: colors.onSurfaceMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${_formatTime(appointment.slot)} - ${_formatTime(appointment.endsAt)}',
                key: const Key('vitral-next-appointment-time'),
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurface,
                  fontFamily: VitralBrand.monoFontFamily,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.confirmation_number_outlined,
                size: 14,
                color: colors.onSurfaceMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                appointment.id,
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  fontFamily: VitralBrand.monoFontFamily,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Lista compacta dos demais agendamentos confirmados (alem do
/// "proximo"). Cada item mostra dia + horario + servico + delete icon
/// e ocupa altura minima — visualmente subordinada ao card principal.
class _OtherAppointmentsList extends StatelessWidget {
  const _OtherAppointmentsList({
    required this.appointments,
    required this.colors,
    required this.textTheme,
    required this.onCancel,
  });

  final List<Appointment> appointments;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final void Function(String id, String serviceLabel) onCancel;

  static const _weekdayNames = [
    '',
    'seg',
    'ter',
    'qua',
    'qui',
    'sex',
    'sab',
    'dom',
  ];

  String _formatDate(DateTime d) {
    final weekday = _weekdayNames[d.weekday];
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$weekday $day/$month';
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('vitral-other-appointments'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              'tambem na sua agenda'.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 1.4,
              ),
            ),
          ),
          for (var i = 0; i < appointments.length; i++) ...[
            if (i > 0) Divider(color: colors.border, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      _formatDate(appointments[i].slot),
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                        fontFamily: VitralBrand.monoFontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 56,
                    child: Text(
                      _formatTime(appointments[i].slot),
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurface,
                        fontFamily: VitralBrand.monoFontFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      appointments[i].serviceName,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    key: Key('vitral-other-cancel-${appointments[i].id}'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    tooltip: 'Cancelar',
                    icon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: colors.onSurfaceMuted,
                    ),
                    onPressed: () => onCancel(
                      appointments[i].id,
                      appointments[i].serviceName,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoAppointmentCard extends StatelessWidget {
  const _NoAppointmentCard({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: colors.onSurfaceMuted,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sem agendamentos por enquanto',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Escolha um servico pra abrir a agenda.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
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

// =============================================================================
// CATEGORIAS
// =============================================================================

class _CategoriesStrip extends StatelessWidget {
  const _CategoriesStrip({required this.colors, required this.textTheme});

  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          for (var i = 0; i < ServiceCategory.values.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            _CategoryCard(
              category: ServiceCategory.values[i],
              colors: colors,
              textTheme: textTheme,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.colors,
    required this.textTheme,
  });

  final ServiceCategory category;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        key: Key('vitral-category-${category.name}'),
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => vitralWithDemoBloc(
              context,
              VitralServiceListPage(initialCategory: category),
            ),
          ),
        ),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.6,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: VitralCategoryIllustration(
                    category: category,
                    foregroundColor: colors.primary,
                    accentColor: colors.accent,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                category.label,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category.description,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 0,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PROFISSIONAIS
// =============================================================================

class _SpecialistsList extends StatelessWidget {
  const _SpecialistsList({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final specialists = VitralSpecialistsCatalog.all.take(4).toList();
    return Column(
      children: [
        for (var i = 0; i < specialists.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          VitralSpecialistCard(specialist: specialists[i]),
        ],
      ],
    );
  }
}

// =============================================================================
// SOBRE
// =============================================================================

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sobre o Vitral',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Reunimos profissionais que cobram por hora — estrategistas, '
            'fotografos, designers e especialistas em ads. Cada agenda '
            'fica visivel antes da reserva.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

