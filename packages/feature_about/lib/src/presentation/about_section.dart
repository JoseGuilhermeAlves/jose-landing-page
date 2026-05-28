import 'package:design_system/design_system.dart';
import 'package:feature_about/src/data/domains_catalog.dart';
import 'package:feature_about/src/presentation/domains_grid.dart';
import 'package:feature_about/src/presentation/stack_badges.dart';
import 'package:flutter/material.dart';

/// Secao "Sobre" — eyebrow + headline em gradiente, card com avatar +
/// nome + bio, grade de dominios em que atuou, nota de escopo e
/// stack badges (PROJECT.md §4.4).
///
/// **Sem timeline cronologica** e **sem nomear** empresas/produtos —
/// detalhe nominal fica no LinkedIn. Aqui descrevemos por dominio
/// (varejo B2B, fintech, etc.) e separamos honestamente o que foi
/// feito ponta a ponta do que foi em time de produto.
class AboutSection extends StatelessWidget {
  const AboutSection({this.photo, super.key});

  /// Foto do perfil — quando nula, mostra iniciais em gradiente.
  final ImageProvider? photo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

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
            'No varejo B2B atuei como front end mobile inteiro — '
            'design, arquitetura, codigo e suporte direto a operacao, '
            'em time pequeno, durante 5 anos. Nos demais dominios entro '
            'como mobile dev em time de produto, com escopo de feature '
            'ou arquitetura mobile conforme o contexto. Backend nao '
            'compoe meu escopo de atuacao: integro com APIs ja '
            'existentes, nao construo. Detalhe nominal de empresas e '
            'produtos fica no LinkedIn.',
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
        const SectionHeader(
          eyebrow: 'Sobre',
          title: 'Quem te',
          titleAccent: 'atende.',
          subtitle:
              'Front end mobile com Flutter ha 7+ anos. Foco em '
              'entregar app robusto, com escopo claro e expectativa '
              'alinhada desde o kickoff.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        _BioCard(photo: photo),
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

/// Card "minha bio". Avatar + nome em destaque + paragrafo. Substituir
/// o avatar de iniciais por foto real quando o Jose enviar.
class _BioCard extends StatelessWidget {
  const _BioCard({this.photo});

  final ImageProvider? photo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    final avatar = _Avatar(photo: photo, colors: colors);

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'José Guilherme Alves',
          style: textTheme.titleLarge?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Front end mobile · Flutter Developer · Brasil',
          style: textTheme.labelMedium?.copyWith(
            color: colors.primary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'A carreira comecou em apps mobile de operacao varejista — '
          'front end Flutter do design ao deploy, em time pequeno, '
          'durante 5 anos. Em seguida, atuacao em times de produto em '
          'dominios maiores: setor publico, plataforma interna, '
          'operacao em campo e, atualmente, fintech em escala. Sempre '
          'no front end mobile, com Flutter web quando o produto '
          'demandou. Foco constante em arquitetura, performance e '
          'consistencia de UX em devices reais.',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.6,
          ),
        ),
      ],
    );

    final inner = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(height: AppSpacing.lg),
              textBlock,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: AppSpacing.xl),
              Expanded(child: textBlock),
            ],
          );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: inner,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.colors, this.photo});

  final ImageProvider? photo;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    // Sem foto: BrandMark assume papel de avatar (ja traz gradiente + glow).
    if (photo == null) {
      return BrandMark(
        size: 96,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      );
    }
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.4),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image(image: photo!, width: 96, height: 96, fit: BoxFit.cover),
    );
  }
}
