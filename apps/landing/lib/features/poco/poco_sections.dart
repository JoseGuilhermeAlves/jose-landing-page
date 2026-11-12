import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/features/poco/poco_widgets.dart';

/// Secoes da landing gamificada do Poço, na ordem da pagina.

/// Trailer num monitor neon + gancho da partida.
class PocoTrailerSection extends StatelessWidget {
  const PocoTrailerSection({
    required this.trailerUrl,
    required this.posterAsset,
    super.key,
  });

  final String trailerUrl;
  final String posterAsset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StageHeading(
          stage: 1,
          eyebrow: l10n.game_eyebrow,
          title: l10n.game_trailerTitle,
          body: l10n.game_body,
        ),
        const SizedBox(height: AppSpacing.xl),
        PocoTrailerPlayer(videoUrl: trailerUrl, posterAsset: posterAsset),
      ],
    );
  }
}

/// Seis destaques em paineis HUD — cada um com indice e um pequeno icone.
class PocoFeaturesSection extends StatelessWidget {
  const PocoFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final features = [
      (Icons.groups_2_outlined, l10n.poco_f1Title, l10n.poco_f1Body),
      (Icons.bolt_rounded, l10n.poco_f2Title, l10n.poco_f2Body),
      (Icons.account_tree_outlined, l10n.poco_f3Title, l10n.poco_f3Body),
      (Icons.visibility_outlined, l10n.poco_f4Title, l10n.poco_f4Body),
      (Icons.public_rounded, l10n.poco_f5Title, l10n.poco_f5Body),
      (Icons.graphic_eq_rounded, l10n.poco_f6Title, l10n.poco_f6Body),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StageHeading(
          stage: 2,
          eyebrow: l10n.poco_featuresEyebrow,
          title: l10n.poco_featuresTitle,
        ),
        const SizedBox(height: AppSpacing.xl),
        _ResponsiveGrid(
          minTileWidth: 300,
          children: [
            for (var i = 0; i < features.length; i++)
              _FeatureTile(
                index: i + 1,
                icon: features[i].$1,
                title: features[i].$2,
                body: features[i].$3,
              ),
          ],
        ),
      ],
    );
  }
}

class _FeatureTile extends StatefulWidget {
  const _FeatureTile({
    required this.index,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int index;
  final IconData icon;
  final String title;
  final String body;

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final tint = widget.index.isOdd ? colors.accent : colors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: HudPanel(
        color: tint,
        lit: _hovered,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: tint, size: 22),
                const Spacer(),
                PixelText(
                  widget.index.toString().padLeft(2, '0'),
                  color: colors.onSurfaceMuted.withValues(alpha: 0.6),
                  pixelSize: 2,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.title,
              style: tt.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.body,
              style: tt.bodyMedium?.copyWith(
                color: colors.onSurfaceMuted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Party select": nove slots de classe, como a tela de selecao do jogo.
class PocoHeroesSection extends StatelessWidget {
  const PocoHeroesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final classes = [
      l10n.poco_classWarrior,
      l10n.poco_classMage,
      l10n.poco_classRogue,
      l10n.poco_classCleric,
      l10n.poco_classBloodKnight,
      l10n.poco_classNecromancer,
      l10n.poco_classDruid,
      l10n.poco_classStormHerald,
      l10n.poco_classArtificer,
    ];

    final isMobile = context.isMobile;
    final heading = StageHeading(
      stage: 3,
      eyebrow: l10n.poco_heroesEyebrow,
      title: l10n.poco_heroesTitle,
      body: l10n.poco_heroesBody,
    );
    final grid = _ResponsiveGrid(
      minTileWidth: 150,
      spacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < classes.length; i++)
          _ClassSlot(slot: i + 1, name: classes[i]),
      ],
    );
    final shot = _Shot(
      asset: 'assets/images/poco/party-select.jpg',
      caption: l10n.poco_shotParty,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: AppSpacing.xl),
          grid,
          const SizedBox(height: AppSpacing.xl),
          shot,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading,
        const SizedBox(height: AppSpacing.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: grid),
            const SizedBox(width: AppSpacing.xl),
            Expanded(flex: 6, child: shot),
          ],
        ),
      ],
    );
  }
}

class _ClassSlot extends StatefulWidget {
  const _ClassSlot({required this.slot, required this.name});

  final int slot;
  final String name;

  @override
  State<_ClassSlot> createState() => _ClassSlotState();
}

class _ClassSlotState extends State<_ClassSlot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final lit = _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppDuration.fast,
        height: 76,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: lit
              ? colors.primary.withValues(alpha: 0.14)
              : colors.surface.withValues(alpha: 0.7),
          border: Border.all(
            color: lit ? colors.primary : colors.border,
            width: lit ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PixelText(
                  'P${widget.slot}',
                  color: lit
                      ? colors.primary
                      : colors.onSurfaceMuted.withValues(alpha: 0.6),
                  pixelSize: 1.5,
                ),
                const Spacer(),
                if (lit) PixelText('>', color: colors.primary, pixelSize: 2),
              ],
            ),
            const Spacer(),
            Text(
              widget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: tt.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Galeria de capturas: grade 16:9; clique amplia num dialogo.
class PocoGallerySection extends StatelessWidget {
  const PocoGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shots = [
      ('title', l10n.poco_shotTitle),
      ('dungeon-map', l10n.poco_shotDungeon),
      ('level-up-draft', l10n.poco_shotLevelUp),
      ('battle-meteor', l10n.poco_shotMeteor),
      ('battle-blizzard', l10n.poco_shotBlizzard),
      ('battle-storm', l10n.poco_shotStorm),
      ('boss', l10n.poco_shotBoss),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StageHeading(
          stage: 4,
          eyebrow: l10n.poco_galleryEyebrow,
          title: l10n.poco_galleryTitle,
        ),
        const SizedBox(height: AppSpacing.xl),
        // Primeira captura (combate) em destaque, demais em grade.
        _Shot(
          asset: 'assets/images/poco/${shots[3].$1}.jpg',
          caption: shots[3].$2,
        ),
        const SizedBox(height: AppSpacing.lg),
        _ResponsiveGrid(
          minTileWidth: 260,
          children: [
            for (final s in [...shots.take(3), ...shots.skip(4)])
              _Shot(asset: 'assets/images/poco/${s.$1}.jpg', caption: s.$2),
          ],
        ),
      ],
    );
  }
}

class _Shot extends StatefulWidget {
  const _Shot({required this.asset, required this.caption});

  final String asset;
  final String caption;

  @override
  State<_Shot> createState() => _ShotState();
}

class _ShotState extends State<_Shot> {
  bool _hovered = false;

  void _open(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeonFrame(
                    child: Image.asset(widget.asset, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.caption,
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: ctx.colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      image: true,
      label: widget.caption,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => _open(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              NeonFrame(
                color: _hovered ? colors.primary : colors.accent,
                child: AnimatedScale(
                  duration: AppDuration.base,
                  curve: Curves.easeOut,
                  scale: _hovered ? 1.03 : 1,
                  child: Image.asset(widget.asset, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.caption,
                style: tt.bodySmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tabela de controles com "keycaps".
class PocoControlsSection extends StatelessWidget {
  const PocoControlsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    final rows = [
      (l10n.poco_ctrlMove, ['←↑↓→', 'WASD'], ['D-pad', 'L']),
      (l10n.poco_ctrlConfirm, ['Enter', 'Z'], ['A']),
      (l10n.poco_ctrlBack, ['Esc', 'X'], ['B']),
      (l10n.poco_ctrlDash, ['Shift'], ['RB', 'LB']),
      (l10n.poco_ctrlParty, ['Tab'], ['Start']),
      (l10n.poco_ctrlReroll, ['R', 'B'], ['X', 'Y']),
    ];
    // Toque no Android espelha o gamepad com rotulos proprios.
    const touch = ['d-pad', 'A', 'B', 'RUN', 'MENU', 'X / Y'];

    Widget keys(List<String> ks) => Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [for (final k in ks) _Keycap(k)],
    );

    final header = tt.labelSmall?.copyWith(
      color: colors.accent,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StageHeading(
          stage: 5,
          eyebrow: l10n.poco_controlsEyebrow,
          title: l10n.poco_controlsTitle,
        ),
        const SizedBox(height: AppSpacing.xl),
        HudPanel(
          padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
          child: Table(
            columnWidths: isMobile
                ? const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  }
                : const {
                    0: FlexColumnWidth(1.4),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                  },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  Text(l10n.poco_ctrlAction.toUpperCase(), style: header),
                  Text(l10n.poco_ctrlKeyboard.toUpperCase(), style: header),
                  Text(l10n.poco_ctrlGamepad.toUpperCase(), style: header),
                  if (!isMobile)
                    Text(l10n.poco_ctrlTouch.toUpperCase(), style: header),
                ],
              ),
              for (var i = 0; i < rows.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colors.border)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        rows[i].$1,
                        style: tt.bodyMedium?.copyWith(color: colors.onSurface),
                      ),
                    ),
                    keys(rows[i].$2),
                    keys(rows[i].$3),
                    if (!isMobile) keys([touch[i]]),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Keycap extends StatelessWidget {
  const _Keycap(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.border),
          left: BorderSide(color: colors.border),
          right: BorderSide(color: colors.border),
          bottom: BorderSide(
            color: colors.onSurfaceMuted.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Ficha tecnica (estilo metadados de loja) + bloco de download com uma
/// linha por plataforma, nota da versao e instrucoes de instalacao.
class PocoDownloadSection extends StatelessWidget {
  const PocoDownloadSection({
    required this.version,
    required this.windowsUrl,
    required this.androidUrl,
    required this.onOpenUri,
    super.key,
  });

  final String version;
  final String windowsUrl;
  final String androidUrl;
  final ValueChanged<Uri> onOpenUri;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    final info = [
      (l10n.poco_infoStatus, l10n.poco_infoStatusValue),
      (l10n.poco_infoVersion, version),
      (l10n.poco_infoPlatforms, 'Windows, Android'),
      (l10n.poco_infoGenre, l10n.poco_infoGenreValue),
      (l10n.poco_infoEngine, 'Godot 4 · C# (.NET 8)'),
      (l10n.poco_infoTests, l10n.poco_infoTestsValue),
    ];

    final infoPanel = HudPanel(
      color: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.poco_infoEyebrow.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final row in info)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      row.$1,
                      style: tt.bodySmall?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2,
                      style: tt.bodySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.game_factStackTitle,
            style: tt.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.game_factStackBody,
            style: tt.bodySmall?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    final downloads = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.game_demoBody,
          style: tt.bodyLarge?.copyWith(color: colors.onSurface, height: 1.55),
        ),
        const SizedBox(height: AppSpacing.lg),
        _DownloadRow(
          icon: Icons.desktop_windows_outlined,
          label: l10n.game_ctaWindows,
          version: version,
          onPressed: () => onOpenUri(Uri.base.resolve(windowsUrl)),
          action: l10n.poco_ctaDownload,
        ),
        const SizedBox(height: AppSpacing.sm),
        _DownloadRow(
          icon: Icons.android_rounded,
          label: l10n.game_ctaAndroid,
          version: version,
          onPressed: () => onOpenUri(Uri.base.resolve(androidUrl)),
          action: l10n.poco_ctaDownload,
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.07),
            border: Border(left: BorderSide(color: colors.accent, width: 3)),
          ),
          child: Text(
            l10n.game_demoUpdate(version),
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurface,
              height: 1.55,
            ),
          ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StageHeading(
          stage: 6,
          eyebrow: l10n.poco_downloadEyebrow,
          title: l10n.poco_downloadTitle,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (isMobile) ...[
          downloads,
          const SizedBox(height: AppSpacing.xl),
          infoPanel,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: downloads),
              const SizedBox(width: AppSpacing.xl),
              Expanded(flex: 5, child: infoPanel),
            ],
          ),
      ],
    );
  }
}

class _DownloadRow extends StatelessWidget {
  const _DownloadRow({
    required this.icon,
    required this.label,
    required this.version,
    required this.onPressed,
    required this.action,
  });

  final IconData icon;
  final String label;
  final String version;
  final VoidCallback onPressed;
  final String action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return HudPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.accent, size: 26),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: tt.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  version,
                  style: tt.bodySmall?.copyWith(color: colors.onSurfaceMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          NeonButton(
            label: action,
            filled: true,
            dense: true,
            icon: Icons.download_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

/// Rodape: feedback por email, autoria e retorno pra zeguidev.
class PocoFooter extends StatelessWidget {
  const PocoFooter({
    required this.email,
    required this.onOpenUri,
    required this.onBack,
    super.key,
  });

  final String email;
  final ValueChanged<Uri> onOpenUri;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        children: [
          BlinkingPixelText('THANKS FOR PLAYING', color: colors.primary),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            children: [
              Text(
                l10n.poco_feedback,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onOpenUri(
                    Uri(scheme: 'mailto', path: email, query: 'subject=Poço'),
                  ),
                  child: Text(
                    email,
                    style: tt.bodyMedium?.copyWith(
                      color: colors.accent,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          NeonButton(
            label: l10n.poco_back,
            color: colors.accent,
            onPressed: onBack,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.poco_madeBy,
            style: tt.bodySmall?.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

/// Grade responsiva simples: numero de colunas pela largura disponivel,
/// linhas com altura intrinseca (tiles da mesma linha alinhados).
class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
    required this.children,
    required this.minTileWidth,
    this.spacing = AppSpacing.lg,
  });

  final List<Widget> children;
  final double minTileWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = ((c.maxWidth + spacing) / (minTileWidth + spacing))
            .floor()
            .clamp(1, 4);
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += cols) {
          final slice = children.sublist(
            i,
            (i + cols).clamp(0, children.length),
          );
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < cols; j++) ...[
                    if (j > 0) SizedBox(width: spacing),
                    Expanded(
                      child: j < slice.length
                          ? slice[j]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              rows[i],
            ],
          ],
        );
      },
    );
  }
}
