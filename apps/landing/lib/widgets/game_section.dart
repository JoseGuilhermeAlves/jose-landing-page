import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Secao "Poço" — projeto autoral de jogo em desenvolvimento. Mesma
/// gramatica da `AboutSection` (eyebrow pixel, titulo com acento magenta,
/// prosa + rows estilo changelog), com o GIF de gameplay emoldurado em
/// neon, o chamado pra artistas parceiros e os downloads da demo.
///
/// Os binarios (~115 MB e ~149 MB) passam do limite de 100 MB por arquivo
/// do GitHub Pages, por isso sao servidos de uma GitHub Release — a
/// `HomePage` injeta as URLs via `AppConfig`.
class GameSection extends StatelessWidget {
  const GameSection({
    required this.windowsDemoUrl,
    required this.androidDemoUrl,
    required this.email,
    required this.onOpenUri,
    super.key,
  });

  final String windowsDemoUrl;
  final String androidDemoUrl;
  final String email;
  final ValueChanged<Uri> onOpenUri;

  static const String _gifAsset = 'assets/images/poco_meteor.gif';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = context.colors;
    final l10n = context.l10n;
    final isMobile = context.isMobile;
    final blockGap = context.responsive(
      mobile: AppSpacing.lg,
      desktop: AppSpacing.xxl,
    );

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.game_subtitle,
          style: tt.bodyLarge?.copyWith(
            color: colors.onSurface,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.game_body,
          style: tt.bodyMedium?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.55,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PixelText(l10n.game_eyebrow, color: colors.accent, pixelSize: 3),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              style: tt.headlineLarge?.copyWith(color: colors.onSurface),
              children: [
                TextSpan(text: '${l10n.game_title} '),
                TextSpan(
                  text: l10n.game_titleAccent,
                  style: TextStyle(color: colors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isMobile) ...[
          const _GameplayFrame(asset: _gifAsset),
          const SizedBox(height: AppSpacing.lg),
          intro,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 6,
                child: _GameplayFrame(asset: _gifAsset),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(flex: 5, child: intro),
            ],
          ),
        SizedBox(height: blockGap),
        _FactRow(
          stage: '01',
          title: l10n.game_factCombatTitle,
          body: l10n.game_factCombatBody,
        ),
        _FactRow(
          stage: '02',
          title: l10n.game_factBuildTitle,
          body: l10n.game_factBuildBody,
        ),
        _FactRow(
          stage: '03',
          title: l10n.game_factStackTitle,
          body: l10n.game_factStackBody,
        ),
        SizedBox(height: blockGap),
        Text(
          l10n.game_partnerTitle,
          style: tt.headlineSmall?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.game_partnerBody,
          style: tt.bodyMedium?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ArcadeButton(
          label: l10n.game_ctaPartner,
          color: colors.primary,
          filled: true,
          onPressed: () => onOpenUri(
            Uri(
              scheme: 'mailto',
              path: email,
              query: 'subject=${Uri.encodeComponent(l10n.game_partnerSubject)}',
            ),
          ),
        ),
        SizedBox(height: blockGap),
        Text(
          l10n.game_demoTitle,
          style: tt.headlineSmall?.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.game_demoBody,
          style: tt.bodyMedium?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _ArcadeButton(
              label: l10n.game_ctaWindows,
              color: colors.accent,
              onPressed: () => onOpenUri(Uri.base.resolve(windowsDemoUrl)),
            ),
            _ArcadeButton(
              label: l10n.game_ctaAndroid,
              color: colors.accent,
              onPressed: () => onOpenUri(Uri.base.resolve(androidDemoUrl)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.game_demoNote,
          style: tt.bodySmall?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// Botao retangular estilo fliperama — mesmo vocabulario do `_ArcadeButton`
/// do hero: cantos retos, borda neon de 2px, label em [PixelText],
/// preenchido (CTA primario) ou contornado. Hover acende o glow e inverte.
/// No mobile o pixel encolhe pra labels longas (downloads) caberem.
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
    final lit = _hovered || widget.filled;
    final bg = lit ? widget.color : Colors.transparent;
    final fg = lit ? colors.background : widget.color;

    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: AppDuration.fast,
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: context.isMobile ? AppSpacing.lg : AppSpacing.xl,
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
            child: PixelText(
              widget.label,
              color: fg,
              pixelSize: context.isMobile ? 2 : 3,
            ),
          ),
        ),
      ),
    );
  }
}

/// GIF de gameplay em moldura neon de cantos retos (vocabulario arcade).
/// `FilterQuality.none` preserva o pixel-art ao escalar.
class _GameplayFrame extends StatelessWidget {
  const _GameplayFrame({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: -6,
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.none,
          gaplessPlayback: true,
          semanticLabel: context.l10n.game_gifAlt,
        ),
      ),
    );
  }
}

/// Row estilo changelog — espelha `_DomainRow` da `AboutSection`.
class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.stage,
    required this.title,
    required this.body,
  });

  final String stage;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = context.colors;
    final isMobile = context.isMobile;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        PixelText(stage, color: colors.primary, pixelSize: 3),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: tt.titleMedium?.copyWith(
            color: colors.onSurface,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final paragraph = Text(
      body,
      style: tt.bodyMedium?.copyWith(color: colors.onSurfaceMuted, height: 1.5),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                heading,
                const SizedBox(height: AppSpacing.sm),
                paragraph,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 260, child: heading),
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: paragraph),
              ],
            ),
    );
  }
}
