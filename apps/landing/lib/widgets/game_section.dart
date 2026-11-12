import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/features/poco/poco_widgets.dart';

/// Secao "Poço" da home — **teaser** do projeto autoral de jogo. Mostra o
/// GIF de gameplay, o pitch em duas frases, tres destaques curtos e leva
/// pra landing gamificada (`/poco`), onde mora tudo: trailer, features,
/// herois, galeria, controles e downloads.
///
/// Redesign 2026-11: antes a secao carregava trailer + downloads + patch
/// note inteiros na home; agora a home so apresenta e a pagina do jogo
/// aprofunda.
class GameSection extends StatelessWidget {
  const GameSection({
    required this.demoVersion,
    required this.onExplore,
    required this.onDownload,
    super.key,
  });

  final String demoVersion;
  final VoidCallback onExplore;
  final VoidCallback onDownload;

  /// Captura atual do jogo (v0.27.0) — o GIF antigo estava desatualizado.
  static const String _gifAsset = 'assets/images/poco/battle-strike.jpg';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final colors = context.colors;
    final l10n = context.l10n;
    final isMobile = context.isMobile;

    final media = Semantics(
      button: true,
      label: l10n.game_ctaExplore,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onExplore,
          child: NeonFrame(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _gifAsset,
                  fit: BoxFit.cover,
                  semanticLabel: l10n.poco_shotBattleStrike,
                ),
                Positioned(
                  left: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    color: Colors.black.withValues(alpha: 0.7),
                    child: PocoLogo(pixelSize: isMobile ? 3 : 4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final facts = [l10n.poco_f2Title, l10n.poco_f3Title, l10n.poco_f5Title];

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.game_body,
          style: tt.bodyLarge?.copyWith(color: colors.onSurface, height: 1.6),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final f in facts)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Container(width: 6, height: 6, color: colors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    f,
                    style: tt.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            NeonButton(
              label: l10n.game_ctaExplore,
              filled: true,
              icon: Icons.arrow_forward_rounded,
              onPressed: onExplore,
            ),
            NeonButton(
              label: l10n.game_ctaDownload,
              color: colors.accent,
              icon: Icons.download_rounded,
              onPressed: onDownload,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.game_metaLine(demoVersion),
          style: tt.bodySmall?.copyWith(color: colors.onSurfaceMuted),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeonSectionHeading(
          index: '04',
          eyebrow: l10n.game_eyebrow,
          title: l10n.game_title,
          titleAccent: l10n.game_titleAccent,
          subtitle: l10n.game_subtitle,
        ),
        SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xxl),
        if (isMobile) ...[
          media,
          const SizedBox(height: AppSpacing.lg),
          copy,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: media),
              const SizedBox(width: AppSpacing.xl),
              Expanded(flex: 5, child: copy),
            ],
          ),
      ],
    );
  }
}
