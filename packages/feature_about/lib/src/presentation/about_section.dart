import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_about/src/data/domains_catalog.dart';
import 'package:feature_about/src/presentation/delivery_block.dart';
import 'package:feature_about/src/presentation/domain_constellation.dart';
import 'package:feature_about/src/presentation/painters/jga_monogram_painter.dart';
import 'package:flutter/material.dart';

/// Secao "Sobre" — eyebrow + headline em gradiente + bio card com
/// borda animada e monograma JGA no canto + constelacao interativa
/// de dominios (planetas + balao popup) + bloco "Como eu entrego"
/// com 3 cards narrativos.
///
/// **Sem timeline cronologica, sem nomear empresas/produtos** —
/// detalhe nominal fica no LinkedIn. Estudo de carreira renderizado
/// como **mapa estelar**: cada dominio e um planeta unico (paleta +
/// pattern + ring opcional pro retail end-to-end), arestas indicam
/// metodologia compartilhada. Tap em um planeta abre um balao
/// inline com label + blurb. O bloco "Como eu entrego" detalha
/// entrega, craft e colaboracao em paragrafos longos com glifos
/// vetoriais no canto.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = context.colors;
    final blockGap = context.responsive(
      mobile: AppSpacing.lg,
      desktop: AppSpacing.xxl,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: context.l10n.about_eyebrow,
          title: context.l10n.about_title,
          titleAccent: context.l10n.about_titleAccent,
          subtitle: context.l10n.about_subtitle,
        ),
        SizedBox(height: blockGap),
        const _BioCard(),
        SizedBox(height: blockGap),
        // Wrap em vez de Row — no mobile o hint nao cabe ao lado do label
        // headlineSmall e estourava; aqui ele quebra pra linha de baixo.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Text(
              context.l10n.about_domainsMapLabel,
              style: tt.headlineSmall?.copyWith(color: colors.onSurface),
            ),
            Text(
              context.l10n.about_domainsHint,
              style: tt.labelMedium?.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        DomainConstellation(domains: DomainsCatalog.all(context.l10n)),
        SizedBox(height: blockGap),
        Text(
          context.l10n.about_deliveryTitle,
          style: tt.headlineSmall?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: AppSpacing.lg),
        const DeliveryBlock(),
      ],
    );
  }
}

/// Card "minha bio". Borda animada percorre o perimetro num loop
/// lento; monograma JGA desenhado em Path fica no canto inferior
/// direito a ~40% de alpha como artefato pessoal substituto do
/// avatar removido.
class _BioCard extends StatefulWidget {
  const _BioCard();

  @override
  State<_BioCard> createState() => _BioCardState();
}

class _BioCardState extends State<_BioCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _border;

  @override
  void initState() {
    super.initState();
    _border = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _border.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return RepaintBoundary(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.about_bioName,
                  style: tt.titleLarge?.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.about_bioTitle,
                  style: tt.labelMedium?.copyWith(
                    color: colors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.about_bioParagraph,
                  style: tt.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          // Borda animada por cima — pinta um trace gradient sweepando
          // o perimetro num loop continuo.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _border,
                builder: (_, _) {
                  // Sweep on/off: 0..1 desenha, 1..0 apaga.
                  final raw = _border.value * 2;
                  final progress = raw < 1 ? raw : 2 - raw;
                  return CustomPaint(
                    painter: AnimatedBorderPainter(
                      progress: progress,
                      color: colors.primary.withValues(alpha: 0.85),
                      strokeWidth: 1.6,
                      borderRadius: AppRadius.lg,
                    ),
                  );
                },
              ),
            ),
          ),
          // Monograma JGA no canto inferior direito.
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            width: 64,
            height: 64,
            child: IgnorePointer(
              child: CustomPaint(
                painter: JgaMonogramPainter(
                  color: colors.primary.withValues(alpha: 0.4),
                  strokeWidth: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
