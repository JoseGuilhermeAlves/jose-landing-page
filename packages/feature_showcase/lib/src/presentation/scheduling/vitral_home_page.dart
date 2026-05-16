import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/vitral_specialists_catalog.dart';
import 'package:feature_showcase/src/domain/appointment.dart';
import 'package:feature_showcase/src/domain/service_category.dart';
import 'package:feature_showcase/src/domain/specialist.dart';
import 'package:feature_showcase/src/presentation/scheduling/scheduling_bloc.dart';
import 'package:feature_showcase/src/presentation/scheduling/scheduling_state.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_app_bar.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_brand.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_category_illustration.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_clock_painter.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_hero_backdrop.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_navigation.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_service_list_page.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_specialist_avatar.dart';
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
          tooltip: 'Fechar demo',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
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
                  return _NextAppointmentCard(
                    appointment: next,
                    colors: colors,
                    textTheme: textTheme,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(
                eyebrow: 'Categorias',
                title: 'O que voce precisa hoje',
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.md),
              _CategoriesStrip(colors: colors, textTheme: textTheme),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(
                eyebrow: 'Profissionais',
                title: 'Quem esta na agenda',
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
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
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
                          label: 'Ver servicos',
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
                    child: VitralClockPainter(
                      hour: 10,
                      minute: 8,
                      size: 96,
                    ),
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

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({
    required this.appointment,
    required this.colors,
    required this.textTheme,
  });

  final Appointment appointment;
  final AppColorScheme colors;
  final TextTheme textTheme;

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
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
            ),
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
          Icon(Icons.calendar_today_outlined, color: colors.onSurfaceMuted, size: 28),
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

/// Card de profissional reutilizado pela home e (futuramente) pela
/// lista de servicos. Avatar monograma + nome + role + bio + rating.
class VitralSpecialistCard extends StatelessWidget {
  const VitralSpecialistCard({required this.specialist, super.key});

  final Specialist specialist;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        key: Key('vitral-specialist-card-${specialist.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => vitralWithDemoBloc(
              context,
              VitralServiceListPage(
                initialCategory: specialist.primaryCategory,
              ),
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              VitralSpecialistAvatar(
                monogram: specialist.monogram,
                size: 56,
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialist.name,
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specialist.role,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.accent,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      specialist.bio,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          specialist.rating.toStringAsFixed(1),
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSurface,
                            fontFamily: VitralBrand.monoFontFamily,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '(${specialist.reviewCount})',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.eyebrow,
    required this.title,
    required this.colors,
    required this.textTheme,
  });

  final String eyebrow;
  final String title;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
