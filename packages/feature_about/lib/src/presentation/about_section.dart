import 'package:design_system/design_system.dart';
import 'package:feature_about/src/data/domains_catalog.dart';
import 'package:feature_about/src/presentation/domains_grid.dart';
import 'package:feature_about/src/presentation/stack_badges.dart';
import 'package:flutter/material.dart';

/// Secao "Sobre" — bio + grade de dominios em que atuou + nota de
/// escopo + stack badges (PROJECT.md §4.4).
///
/// **Sem timeline cronologica** e **sem nomear** empresas/produtos —
/// detalhe nominal fica no LinkedIn. Aqui descrevemos por dominio
/// (varejo B2B, fintech, etc.) e separamos honestamente o que foi
/// feito ponta a ponta do que foi em time de produto.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _Avatar(initials: 'JG', colors: colors, textTheme: textTheme),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'José Guilherme Alves',
                  style: (isMobile
                          ? textTheme.headlineMedium
                          : textTheme.headlineLarge)
                      ?.copyWith(color: colors.onSurface),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Desenvolvedor mobile/web ha 7+ anos. Comecei construindo '
          'apps de operacao varejista de ponta a ponta, depois fui '
          'pra times de produto em dominios maiores — incluindo o '
          'que faco hoje, em produto fintech em escala.',
          style: textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.6,
          ),
        ),
      ],
    );

    final scopeNote = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sobre escopo, sem inflar:',
            style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Apps de varejo B2B foram construidos por mim ponta a ponta '
            '— produto, arquitetura, codigo e suporte direto a operacao. '
            'Nos demais dominios atuo em time de produto, com escopo '
            'de feature, arquitetura ou stewardship conforme o '
            'contexto. Detalhe nominal de empresas e produtos fica '
            'no LinkedIn.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        intro,
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Onde ja atuei',
          style: textTheme.headlineSmall?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: AppSpacing.lg),
        const DomainsGrid(domains: DomainsCatalog.all),
        const SizedBox(height: AppSpacing.lg),
        scopeNote,
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Stack',
          style: textTheme.headlineSmall?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: AppSpacing.md),
        const StackBadges(stack: StackCatalog.all),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.colors,
    required this.textTheme,
  });

  final String initials;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    // Avatar com gradiente — substituir por foto real quando o Jose
    // enviar.
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.accent],
        ),
        border: Border.all(color: colors.border, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: textTheme.titleLarge?.copyWith(
          color: colors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
