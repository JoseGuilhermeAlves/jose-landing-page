import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/scheduling/domain/specialist.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_brand.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_navigation.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_specialist_avatar.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_specialist_page.dart';
import 'package:flutter/material.dart';

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
              VitralSpecialistPage(specialist: specialist),
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
