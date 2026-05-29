import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_about/src/data/domains_catalog.dart';
import 'package:feature_about/src/presentation/domain_constellation.dart';
import 'package:feature_about/src/presentation/manifesto_strip.dart';
import 'package:feature_about/src/presentation/painters/jga_monogram_painter.dart';
import 'package:flutter/material.dart';

/// Secao "Sobre" — eyebrow + headline em gradiente + bio card com
/// borda animada e monograma JGA no canto + constelacao interativa
/// de dominios + manifesto strip em mono.
///
/// **Sem timeline cronologica, sem nomear empresas/produtos** —
/// detalhe nominal fica no LinkedIn. Estudo de carreira renderizado
/// como **mapa estelar**: cada dominio e um no luminoso, metodologia
/// compartilhada vira aresta. O escopo "front end mobile, integro
/// APIs nao construo" sai do card de disclaimer e vira manifesto em
/// 4 linhas mono.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = context.colors;
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
        const _BioCard(),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Text(
              'Mapa de dominios',
              style: tt.headlineSmall?.copyWith(color: colors.onSurface),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '· toque um no',
              style: tt.labelMedium?.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const DomainConstellation(domains: DomainsCatalog.all),
        const SizedBox(height: AppSpacing.xxl),
        const ManifestoStrip(),
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
                  'José Guilherme Alves',
                  style: tt.titleLarge?.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Front end mobile · Flutter Developer · Brasil',
                  style: tt.labelMedium?.copyWith(
                    color: colors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'A carreira comecou em apps mobile de operacao varejista '
                  '— front end Flutter do design ao deploy, em time pequeno, '
                  'durante 5 anos. Em seguida, atuacao em times de produto '
                  'em dominios maiores: setor publico, plataforma interna, '
                  'operacao em campo e, atualmente, fintech em escala. '
                  'Sempre no front end mobile, com Flutter web quando o '
                  'produto demandou. Foco constante em arquitetura, '
                  'performance e consistencia de UX em devices reais.',
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
