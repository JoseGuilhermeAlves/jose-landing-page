part of 'vitral_specialist_page.dart';

// =============================================================================
// HEADER
// =============================================================================

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.specialist,
    required this.colors,
    required this.textTheme,
  });

  final Specialist specialist;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('vitral-specialist-header'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surface, colors.surfaceMuted],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VitralSpecialistHeadshot(
            specialist: specialist,
            size: 88,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialist.name,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  specialist.role,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.accent,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: colors.accent),
                    const SizedBox(width: 4),
                    Text(
                      specialist.rating.toStringAsFixed(1),
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurface,
                        fontFamily: VitralBrand.monoFontFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${specialist.reviewCount} avaliacoes',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final c in specialist.categories)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          c.label,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                  ],
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
// BIO
// =============================================================================

class _BioBlock extends StatelessWidget {
  const _BioBlock({
    required this.specialist,
    required this.colors,
    required this.textTheme,
  });

  final Specialist specialist;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sobre'.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          specialist.bio,
          style: textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PORTFOLIO
// =============================================================================

/// Strip horizontal de "trabalhos recentes" — tiles ilustrados pela
/// categoria do profissional via `VitralCategoryIllustration`. Substitui
/// fotos de portfolio por silhuetas geometricas coerentes com a marca
/// (sem stock photo aleatoria no que e so apoio visual).
class _PortfolioStrip extends StatelessWidget {
  const _PortfolioStrip({
    required this.specialist,
    required this.colors,
    required this.textTheme,
  });

  final Specialist specialist;
  final AppColorScheme colors;
  final TextTheme textTheme;

  /// Rotulos curtos por categoria pra dar contexto a cada tile.
  static const Map<ServiceCategory, List<String>> _labels = {
    ServiceCategory.consulting: ['Roadmap MVP', 'Workshop squad', 'Discovery'],
    ServiceCategory.photography: ['Catalogo', 'Lookbook', 'Retrato'],
    ServiceCategory.design: ['Design system', 'Tela mobile', 'Identidade'],
    ServiceCategory.marketing: ['Trafego pago', 'Go-to-market', 'Criativos'],
  };

  @override
  Widget build(BuildContext context) {
    final category = specialist.primaryCategory;
    final labels = _labels[category] ?? const ['Projeto', 'Projeto', 'Projeto'];
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 2),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          return Container(
            key: Key('vitral-portfolio-tile-$i'),
            width: 156,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  labels[i],
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// SERVICOS DO PROFISSIONAL
// =============================================================================

class _SpecialistServiceCard extends StatelessWidget {
  const _SpecialistServiceCard({
    required this.service,
    required this.colors,
    required this.textTheme,
  });

  final Service service;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        key: Key('vitral-specialist-service-${service.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => vitralWithDemoBloc(
              context,
              VitralCalendarPage(service: service),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
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
                          Icons.schedule_outlined,
                          size: 12,
                          color: colors.onSurfaceMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.formattedDuration,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceMuted,
                            fontFamily: VitralBrand.monoFontFamily,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    service.formattedPrice,
                    style: textTheme.titleSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceMuted,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// AVALIACOES
// =============================================================================

class _ReviewsBlock extends StatelessWidget {
  const _ReviewsBlock({
    required this.specialist,
    required this.reviews,
    required this.colors,
    required this.textTheme,
  });

  final Specialist specialist;
  final List<SpecialistReview> reviews;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < reviews.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _ReviewTile(
            review: reviews[i],
            colors: colors,
            textTheme: textTheme,
          ),
        ],
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.colors,
    required this.textTheme,
  });

  final SpecialistReview review;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('vitral-review-${review.id}'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VitralSpecialistAvatar(
                monogram: review.authorMonogram,
                size: 36,
                backgroundColor: colors.surfaceMuted,
                foregroundColor: colors.onSurface,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      review.relativeDate,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                        fontFamily: VitralBrand.monoFontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var s = 0; s < 5; s++)
                    Icon(
                      s < review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: s < review.rating
                          ? colors.accent
                          : colors.onSurfaceMuted,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            review.comment,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurface,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CTA AGENDAR
// =============================================================================

class _AgendarCta extends StatelessWidget {
  const _AgendarCta({
    required this.specialist,
    required this.services,
    required this.colors,
  });

  final Specialist specialist;
  final List<Service> services;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final hasServices = services.isNotEmpty;
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
        key: const Key('vitral-specialist-agendar'),
        label: 'Agendar com ${specialist.name}',
        icon: Icons.event_available_rounded,
        size: AppButtonSize.large,
        expand: true,
        onPressed: hasServices
            ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => vitralWithDemoBloc(
                    context,
                    VitralCalendarPage(service: services.first),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
