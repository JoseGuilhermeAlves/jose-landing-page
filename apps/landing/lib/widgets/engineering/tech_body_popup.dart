import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/engineering/tech_brand_colors.dart';
import 'package:landing/widgets/engineering/tech_descriptions.dart';

/// Abre o cartucho de detalhe de uma tech. O barrier escuro isola o modal e o
/// tap fora descarta.
Future<void> showTechBodyPopup(
  BuildContext context, {
  required TechDescription description,
  void Function(String url)? onOpenDocs,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: description.title,
    barrierColor: Colors.black.withValues(alpha: 0.78),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _TechBodyPopup(description: description, onOpenDocs: onOpenDocs);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _TechBodyPopup extends StatelessWidget {
  const _TechBodyPopup({required this.description, required this.onOpenDocs});

  final TechDescription description;
  final void Function(String url)? onOpenDocs;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final docsUrl = description.docsUrl;
    final accent = TechBrandColors.primary(description.title);
    final screenH = MediaQuery.sizeOf(context).height;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 540, maxHeight: screenH * 0.86),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              border: Border.all(
                color: accent.withValues(alpha: 0.6),
                width: 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: 0.22),
                  blurRadius: 32,
                  spreadRadius: -6,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(role: description.role, accent: accent),
                  const SizedBox(height: AppSpacing.lg),
                  Semantics(
                    header: true,
                    label: description.title,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: PixelText(
                        description.title,
                        color: accent,
                        glowColor: accent,
                        pixelSize: 5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    description.tagline,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      _StatChip(
                        label: 'VER',
                        value: description.version,
                        accent: accent,
                      ),
                      _StatChip(
                        label: 'TYPE',
                        value: description.role,
                        accent: accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    description.body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceMuted,
                      height: 1.6,
                    ),
                  ),
                  if (docsUrl != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _ArcadeDocsButton(
                      accent: accent,
                      onPressed: () {
                        Navigator.pop(context);
                        onOpenDocs?.call(docsUrl);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.role, required this.accent});

  final String role;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: accent,
            boxShadow: <BoxShadow>[
              BoxShadow(color: accent.withValues(alpha: 0.7), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            role.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _PixelCloseButton(accent: accent),
      ],
    );
  }
}

/// Botao de fechar arcade — quadradinho neon com "X" em PixelText. Hover acende.
class _PixelCloseButton extends StatefulWidget {
  const _PixelCloseButton({required this.accent});

  final Color accent;

  @override
  State<_PixelCloseButton> createState() => _PixelCloseButtonState();
}

class _PixelCloseButtonState extends State<_PixelCloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lit = _hovered;

    return Semantics(
      button: true,
      label: 'Fechar',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: AnimatedContainer(
            duration: AppDuration.fast,
            curve: Curves.easeOut,
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: lit ? widget.accent : Colors.transparent,
              border: Border.all(color: widget.accent, width: 2),
            ),
            child: PixelText(
              'X',
              color: lit ? colors.background : widget.accent,
              pixelSize: 3,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip de "stat" — rotulo miudo + valor em mono, cantos retos e borda neon.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// CTA arcade pra docs — retangulo neon chunky, PixelText, hover acende.
class _ArcadeDocsButton extends StatefulWidget {
  const _ArcadeDocsButton({required this.accent, required this.onPressed});

  final Color accent;
  final VoidCallback onPressed;

  @override
  State<_ArcadeDocsButton> createState() => _ArcadeDocsButtonState();
}

class _ArcadeDocsButtonState extends State<_ArcadeDocsButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = widget.accent;

    return Semantics(
      button: true,
      label: 'Abrir documentação',
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: _hovered ? accent : Colors.transparent,
              border: Border.all(color: accent, width: 2),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.6),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: PixelText(
              'ABRIR DOCS',
              color: _hovered ? colors.background : accent,
              pixelSize: 3,
            ),
          ),
        ),
      ),
    );
  }
}
