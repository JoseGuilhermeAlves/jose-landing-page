import 'package:design_system/design_system.dart';
import 'package:feature_hero/src/presentation/black_hole_portrait.dart';
import 'package:feature_hero/src/presentation/hero_cosmos.dart';
import 'package:flutter/material.dart';

/// Hero da landing Arcade — o "title screen" do fliperama. Nome em fonte
/// bitmap [PixelText] com glow magenta sobre o backdrop CRT (grid Outrun
/// + starfield, desenhado pelo shell). Headline e pitch em fonte legivel;
/// dois botoes arcade chunky e um par de stats estilo "high score".
///
/// Sem contagem de apps — o que importa e o que sei fazer, nao quantos.
/// Os CTAs rolam dentro da pagina (funil interno); WhatsApp/email moram
/// na secao Contact.
class ArcadeHero extends StatelessWidget {
  const ArcadeHero({
    this.onContactPressed,
    this.onSeeProjectsPressed,
    super.key,
  });

  final VoidCallback? onContactPressed;
  final VoidCallback? onSeeProjectsPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    // Tamanho do pixel do nome — o nome e o elemento-estrela do title screen.
    final namePixel = (isMobile ? 4 : 7).toDouble();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Planetas espalhados atras de tudo (cosmos do hero).
        const Positioned.fill(child: HeroCosmos()),
        _heroContent(context, colors, textTheme, isMobile, namePixel),
      ],
    );
  }

  Widget _heroContent(
    BuildContext context,
    AppColorScheme colors,
    TextTheme textTheme,
    bool isMobile,
    double namePixel,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive(mobile: AppSpacing.lg, desktop: 0),
      ),
      // Centra verticalmente quando cabe; rola se a viewport for curta
      // (laptops baixos) em vez de estourar o RenderFlex.
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Flex(
                    direction: isMobile ? Axis.vertical : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mobile: buraco negro acima do texto.
                      if (isMobile) ...[
                        BlackHolePortrait(
                          diskHot: colors.primary,
                          diskCool: colors.accent,
                          size: 320,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Eyebrow: insira-moeda vibe, ciano.
                            Text(
                              context.l10n.hero_eyebrow.toUpperCase(),
                              style: textTheme.labelMedium?.copyWith(
                                color: colors.accent,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Nome em fonte pixel, duas linhas, glow magenta — o titulo.
                            Semantics(
                              header: true,
                              label: 'Jose Guilherme Alves',
                              child: PixelText(
                                'JOSE\nGUILHERME ALVES',
                                color: colors.primary,
                                glowColor: colors.primary,
                                glowBlur: 10,
                                pixelSize: namePixel,
                                lineSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Headline em fonte legivel (display) — pitch curto.
                            Text(
                              '${context.l10n.hero_headline1} '
                              '${context.l10n.hero_headline2}',
                              style:
                                  (isMobile
                                          ? textTheme.headlineSmall
                                          : textTheme.headlineMedium)
                                      ?.copyWith(
                                        color: colors.onSurface,
                                        height: 1.2,
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              context.l10n.hero_scopeLine,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colors.onSurfaceMuted,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // CTAs arcade.
                            Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: AppSpacing.md,
                              children: [
                                _ArcadeButton(
                                  label: context.l10n.hero_ctaContact,
                                  color: colors.primary,
                                  filled: true,
                                  onPressed: onContactPressed,
                                ),
                                _ArcadeButton(
                                  label: context.l10n.hero_ctaProjects,
                                  color: colors.accent,
                                  onPressed: onSeeProjectsPressed,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // Stats "high score" — anos + zero assets (tudo Canvas).
                            Wrap(
                              spacing: AppSpacing.huge,
                              runSpacing: AppSpacing.lg,
                              children: [
                                _ArcadeStat(
                                  value: context.l10n.hero_trustYearsValue,
                                  label: context.l10n.hero_trustYearsLabel,
                                  color: colors.primary,
                                ),
                                _ArcadeStat(
                                  value: context.l10n.hero_trustCanvasValue,
                                  label: context.l10n.hero_trustCanvasLabel,
                                  color: colors.accent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Desktop: buraco negro a direita do texto.
                      if (!isMobile) ...[
                        const SizedBox(width: AppSpacing.xl),
                        BlackHolePortrait(
                          diskHot: colors.primary,
                          diskCool: colors.accent,
                          size: 460,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botao retangular estilo fliperama: cantos retos, borda neon de 2px,
/// preenchido (CTA primario) ou contornado. Hover acende o glow e inverte.
class _ArcadeButton extends StatefulWidget {
  const _ArcadeButton({
    required this.label,
    required this.color,
    this.filled = false,
    this.onPressed,
  });

  final String label;
  final Color color;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  State<_ArcadeButton> createState() => _ArcadeButtonState();
}

class _ArcadeButtonState extends State<_ArcadeButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // No hover, o botao "acende": preenche e ganha glow.
    final lit = _hovered || widget.filled;
    final bg = lit ? widget.color : Colors.transparent;
    final fg = lit ? colors.background : widget.color;

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: AppDuration.fast,
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: widget.color, width: 2),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.6),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: PixelText(widget.label, color: fg, pixelSize: 3),
          ),
        ),
      ),
    );
  }
}

/// Stat estilo "high score": numero grande em pixel + label miudo.
class _ArcadeStat extends StatelessWidget {
  const _ArcadeStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PixelText(value, color: color, glowColor: color, pixelSize: 5),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 1.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
