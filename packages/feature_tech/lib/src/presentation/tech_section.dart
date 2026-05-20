import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_tech/src/data/arch_decisions_catalog.dart';
import 'package:feature_tech/src/data/painters_catalog.dart';
import 'package:feature_tech/src/data/stack_catalog.dart';
import 'package:feature_tech/src/presentation/arch_grid.dart';
import 'package:feature_tech/src/presentation/painters_strip.dart';
import 'package:feature_tech/src/presentation/stack_by_category.dart';
import 'package:flutter/material.dart';

/// Secao "Arquitetura & Stack" da landing.
///
/// Composta por:
/// - SectionHeader padrao (eyebrow + titulo com gradient + subtitle);
/// - strip de estatisticas do projeto (4 contagens);
/// - grade das 7 decisoes arquiteturais com border animada no hover;
/// - clusters do stack agrupados por categoria;
/// - painters em destaque do projeto;
/// - CTA opcional pro repositorio (quando [githubUrl] for fornecida).
///
/// Conteudo migrado da home do `/labs` (que permanece como vitrine
/// interativa pura dos painters).
class TechSection extends StatelessWidget {
  const TechSection({
    this.githubUrl,
    this.onOpenGithub,
    super.key,
  });

  /// URL do repositorio. Quando fornecida, [onOpenGithub] e chamado
  /// no tap do botao. Sem URL, o CTA some.
  final String? githubUrl;

  /// Hook injetavel pra abrir a URL — facilita teste sem `url_launcher`.
  final void Function(String url)? onOpenGithub;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeaderWithConstellation(),
        const SizedBox(height: AppSpacing.xl),
        const _StatStrip(),
        const SizedBox(height: AppSpacing.xxl),
        _Subhead(
          label: 'Decisoes que orbitam',
          hint: 'O que vale ler antes de explorar o monorepo.',
          textTheme: textTheme,
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.lg),
        const ArchGrid(decisions: ArchDecisionsCatalog.all),
        const SizedBox(height: AppSpacing.xxl),
        _Subhead(
          label: 'Stack que sustenta',
          hint: 'Libs principais, agrupadas por papel. Versoes alinhadas '
              'com o pubspec.',
          textTheme: textTheme,
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.lg),
        StackByCategory(itemsByCategory: StackCatalog.byCategory),
        const SizedBox(height: AppSpacing.xxl),
        _Subhead(
          label: 'Constelacoes de pixels',
          hint: 'Painters de maior densidade tecnica. Quem quiser brincar '
              'com sliders ao vivo, abre o /labs.',
          textTheme: textTheme,
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.lg),
        const PaintersStrip(painters: PaintersCatalog.all),
        if (githubUrl != null) ...[
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            key: const Key('tech-github-button'),
            label: 'Ver repositorio no GitHub',
            variant: AppButtonVariant.secondary,
            icon: Icons.open_in_new,
            onPressed: () => onOpenGithub?.call(githubUrl!),
          ),
        ],
      ],
    );
  }
}

/// Cabecalho da secao com `ConstellationField` como ornamento decorativo
/// no canto superior direito (apenas desktop). A constelacao anima
/// twinkle das estrelas em loop curto — referencia visual direta ao
/// titulo "Da particula a constelacao". `IgnorePointer` + `Opacity`
/// garante que nao interfira em hit-test nem competiu com o conteudo.
class _SectionHeaderWithConstellation extends StatelessWidget {
  const _SectionHeaderWithConstellation();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isHandheld = context.isHandheld;

    const header = SectionHeader(
      eyebrow: 'Engenharia',
      title: 'Da particula',
      titleAccent: 'a constelacao.',
      subtitle:
          'Como as camadas do monorepo conversam, que libs as sustentam '
          'e quais painters elevam a experiencia alem do comum. Sem '
          'buzzword — escolhas deliberadas, codigo robusto.',
    );

    // Em handheld a constelacao nao cabe no fluxo de layout e disputaria
    // espaco com o subtitle — entrega so o header puro.
    if (isHandheld) return header;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Constelacao ornamental — alinhada ao canto superior direito,
        // larga o suficiente pra desenhar uma constelacao reconhecivel
        // mas curta o bastante pra nao invadir o headline.
        Positioned(
          top: -8,
          right: -8,
          width: 360,
          height: 200,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.55,
              child: ConstellationField(
                duration: const Duration(seconds: 7),
                starColor: colors.onSurface,
                linkColor: colors.primary.withValues(alpha: 0.35),
                starRadius: 1.8,
                flareLength: 5,
              ),
            ),
          ),
        ),
        header,
      ],
    );
  }
}

/// Subheader interno da secao — dot pulsante + label + hint muted.
/// Estilo consistente nas 3 subdivisoes (Decisoes, Stack, Painters).
class _Subhead extends StatelessWidget {
  const _Subhead({
    required this.label,
    required this.hint,
    required this.textTheme,
    required this.colors,
  });

  final String label;
  final String hint;
  final TextTheme textTheme;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            hint,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Faixa horizontal com 3 estatisticas do projeto sobre backdrop cosmos
/// sutil. Cada celula tem numero grande em gradient brand + label muted
/// abaixo. Visual inspirado em dashboards (Linear/Vercel) com tema
/// cosmico — `CosmosField` reduzido (so nebulosas, sem planetas nem
/// cometa) anima atras da gradient brandSoft, cycle longo (60s) pra nao
/// roubar atencao do conteudo.
class _StatStrip extends StatelessWidget {
  const _StatStrip();

  static const List<(String, String)> _stats = [
    ('11', 'pacotes no monorepo'),
    ('5', 'mocks navegaveis'),
    ('9', 'painters em destaque'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isHandheld = context.isHandheld;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: isHandheld
          ? Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.lg,
              children: [
                for (final s in _stats)
                  _StatCell(value: s.$1, label: s.$2),
              ],
            )
          : Row(
              children: [
                for (var i = 0; i < _stats.length; i++) ...[
                  if (i > 0) ...[
                    Container(
                      width: 1,
                      height: 44,
                      color: colors.border.withValues(alpha: 0.6),
                    ),
                  ],
                  Expanded(
                    child: _StatCell(
                      value: _stats[i].$1,
                      label: _stats[i].$2,
                      center: true,
                    ),
                  ),
                ],
              ],
            ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.10),
            blurRadius: 28,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            // Backdrop cosmos — so nebulosas vibrantes em alpha baixo,
            // sem planetas/cometa/shooting stars pra nao competir com os
            // numeros. Cycle de 60s — quase imperceptivel.
            const Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.55,
                  child: CosmosField(
                    duration: Duration(seconds: 60),
                    planets: [],
                    nebulas: [
                      CosmosNebula(
                        canvasAnchor: Offset(0.18, 0.4),
                        radiusPixels: 90,
                        color: Color(0xFF0AC4FF),
                        density: 0.5,
                        seed: 1,
                      ),
                      CosmosNebula(
                        canvasAnchor: Offset(0.55, 0.65),
                        radiusPixels: 110,
                        color: Color(0xFF9D3FFF),
                        seed: 4,
                      ),
                      CosmosNebula(
                        canvasAnchor: Offset(0.86, 0.32),
                        radiusPixels: 80,
                        color: Color(0xFFE020F2),
                        density: 0.48,
                        seed: 7,
                      ),
                    ],
                    comet: null,
                    shootingStars: [],
                    pixelStars: [
                      Offset(0.08, 0.18),
                      Offset(0.22, 0.62),
                      Offset(0.34, 0.28),
                      Offset(0.48, 0.78),
                      Offset(0.62, 0.20),
                      Offset(0.74, 0.55),
                      Offset(0.88, 0.74),
                      Offset(0.95, 0.18),
                    ],
                  ),
                ),
              ),
            ),
            // Gradient brandSoft sobreposto pra tingir a cena de brand e
            // garantir contraste do texto displaySmall em gradient.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.brandSoft(colors),
                  ),
                ),
              ),
            ),
            content,
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.center = false,
  });

  final String value;
  final String label;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        GradientText(
          text: value,
          gradient: AppGradients.brand(colors),
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            height: 1,
          ),
          textAlign: center ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceMuted,
            letterSpacing: 0.6,
          ),
          textAlign: center ? TextAlign.center : TextAlign.start,
        ),
      ],
    );
  }
}
