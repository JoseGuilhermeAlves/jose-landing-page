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

  /// Mapeia o loop 0..1 do controller pra um sweep triangular 0..1..0
  /// (desenha e apaga) — substitui o calculo que antes vivia dentro do
  /// builder de um AnimatedBuilder.
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _border = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
    _sweep = _border.drive(
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
      ]),
    );
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
    final l10n = context.l10n;

    // Estrutura escaneavel (publico recrutador/tech lead): lead em
    // destaque + 5 linhas-fato (dominio em peso forte, corpo curto) +
    // fecho de escopo em corpo menor. Substitui o paragrafo unico de
    // ~110 palavras que ninguem escaneava.
    final facts = <(String, String)>[
      (l10n.about_factRetailTitle, l10n.about_factRetailBody),
      (l10n.about_factFieldTitle, l10n.about_factFieldBody),
      (l10n.about_factPublicTitle, l10n.about_factPublicBody),
      (l10n.about_factToolsTitle, l10n.about_factToolsBody),
      (l10n.about_factFintechTitle, l10n.about_factFintechBody),
    ];

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
                  l10n.about_bioName,
                  style: tt.titleLarge?.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.about_bioTitle,
                  style: tt.labelMedium?.copyWith(
                    color: colors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.about_bioLead,
                  style: tt.titleMedium?.copyWith(
                    color: colors.onSurface,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (var i = 0; i < facts.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _FactRow(title: facts[i].$1, body: facts[i].$2),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.about_bioClose,
                  style: tt.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          // Borda animada por cima — pinta um trace gradient sweepando
          // o perimetro num loop continuo. O painter ouve a animation
          // direto via `repaint:` — sem AnimatedBuilder reconstruindo a
          // subarvore a cada frame.
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: AnimatedBorderPainter(
                  animation: _sweep,
                  color: colors.primary.withValues(alpha: 0.85),
                  strokeWidth: 1.6,
                  borderRadius: AppRadius.lg,
                ),
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

/// Linha-fato da bio: dominio em peso forte seguido do corpo curto na
/// mesma linha (RichText) — cada fato escaneavel em uma leitura.
class _FactRow extends StatelessWidget {
  const _FactRow({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$title — ',
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.55,
            ),
          ),
          TextSpan(
            text: body,
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
