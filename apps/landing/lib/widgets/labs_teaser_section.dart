import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_labs/labs_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Teaser do `/labs` na home. Promove a vitrine tecnica para o meio
/// do scroll em vez de deixa-la apenas no rodape — mantem o eyebrow
/// "Para devs" como gate explicito para que cliente leigo pule sem
/// friccao.
///
/// Compoe-se de:
/// - cabecalho padrao (`SectionHeader`) com lado tecnico declarado;
/// - lista dos 7 playgrounds em chips compactos (canonica do
///   feature_labs, redeclarada aqui pra nao quebrar deferred loading);
/// - CTA primario que navega para `LabsRoutePaths.index`;
/// - preview lateral animado com `MorphingShapePainter` em loop —
///   amostra do tipo de conteudo disponivel na vitrine.
class LabsTeaserSection extends StatefulWidget {
  const LabsTeaserSection({super.key});

  @override
  State<LabsTeaserSection> createState() => _LabsTeaserSectionState();
}

class _LabsTeaserSectionState extends State<LabsTeaserSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _morphController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  /// Playgrounds disponiveis. Espelho da `PlaygroundsCatalog` em
  /// `feature_labs` — declarados aqui pra nao puxar o bundle deferido
  /// pro main. Se o catalog mudar, atualizar aqui tambem.
  static const List<(String, IconData)> _playgrounds = [
    ('Particle field', Icons.scatter_plot_outlined),
    ('Timeline animada', Icons.timeline_outlined),
    ('Borda animada', Icons.crop_square_outlined),
    ('Spinner customizado', Icons.refresh_outlined),
    ('Forma morphando', Icons.auto_awesome_outlined),
    ('Ripple no hover', Icons.touch_app_outlined),
    ('Onda divisora', Icons.waves_outlined),
  ];

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = context.isMobile;

    final copyBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(
          eyebrow: 'Para devs',
          title: 'Custom Painters,',
          titleAccent: 'ao vivo.',
          subtitle:
              'Sete playgrounds interativos com sliders, decisoes '
              'arquiteturais documentadas e o monorepo do projeto. '
              'Conteudo tecnico, pensado para devs e recrutadores.',
        ),
        const SizedBox(height: AppSpacing.xl),
        const _PlaygroundChips(playgrounds: _playgrounds),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          key: const Key('labs-teaser-cta'),
          label: 'Explorar /labs',
          icon: Icons.arrow_forward,
          size: AppButtonSize.large,
          onPressed: () => context.go(LabsRoutePaths.index),
        ),
      ],
    );

    final previewBlock = _MorphingPreview(controller: _morphController);

    final inner = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copyBlock,
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(height: 240, child: previewBlock),
            ],
          )
        : Row(
            children: [
              Expanded(flex: 3, child: copyBlock),
              const SizedBox(width: AppSpacing.huge),
              Expanded(
                flex: 2,
                child: SizedBox(height: 320, child: previewBlock),
              ),
            ],
          );

    return Container(
      key: const Key('labs-teaser-section'),
      padding: EdgeInsets.all(isMobile ? AppSpacing.xl : AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: AppGradients.brandSoft(colors),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.primary.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.18),
            blurRadius: 48,
            spreadRadius: -16,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: inner,
    );
  }
}

class _PlaygroundChips extends StatelessWidget {
  const _PlaygroundChips({required this.playgrounds});

  final List<(String, IconData)> playgrounds;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (label, icon) in playgrounds)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.6),
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: colors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Preview animado: `MorphingShapePainter` em loop dentro de um quadro
/// com glow radial. Pintura leve (gradient solido) — nao pesa o frame
/// budget da home.
class _MorphingPreview extends StatelessWidget {
  const _MorphingPreview({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.glow(colors.primary, opacity: 0.32),
                color: colors.surface,
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, _) => CustomPaint(
                painter: MorphingShapePainter(
                  progress: controller.value,
                  color: colors.primary.withValues(alpha: 0.85),
                  sampleCount: 96,
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Text(
              'MorphingShapePainter',
              style: textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
