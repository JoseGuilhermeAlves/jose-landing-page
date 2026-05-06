import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/domain/showcase_template.dart';
import 'package:flutter/material.dart';

/// Grid responsivo de [ShowcaseCard]. 1/2/3 col por breakpoint.
class ShowcaseGrid extends StatelessWidget {
  const ShowcaseGrid({
    required this.templates,
    required this.onTemplateTapped,
    super.key,
  });

  final List<ShowcaseTemplate> templates;
  final ValueChanged<ShowcaseTemplate> onTemplateTapped;

  int _columnsFor(Breakpoint bp) => switch (bp) {
        Breakpoint.mobile => 1,
        Breakpoint.tablet => 2,
        Breakpoint.desktop || Breakpoint.wide => 3,
      };

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) return const SizedBox.shrink();

    final columns = _columnsFor(context.breakpoint);

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.md;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in templates)
              SizedBox(
                width: cardWidth,
                child: ShowcaseCard(
                  template: t,
                  onTap: () => onTemplateTapped(t),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Card de um template do showcase. Hover lift + glow shadow + icone
/// em gradient — segue o mesmo padrao visual do `ServiceCard`.
class ShowcaseCard extends StatefulWidget {
  const ShowcaseCard({
    required this.template,
    required this.onTap,
    super.key,
  });

  final ShowcaseTemplate template;
  final VoidCallback onTap;

  @override
  State<ShowcaseCard> createState() => _ShowcaseCardState();
}

class _ShowcaseCardState extends State<ShowcaseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDuration.base,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setHovered({required bool hovered}) {
    if (hovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final disabled = !widget.template.hasDemo;

    final card = AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final t = disabled ? 0.0 : _controller.value;
        return Transform.translate(
          offset: Offset(0, -4 * t),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: t > 0
                    ? Color.lerp(colors.border, colors.primary, t * 0.6)!
                    : colors.border,
              ),
              boxShadow: t > 0
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.22 * t),
                        blurRadius: 28,
                        spreadRadius: -6,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: AppGradients.brandSoft(colors),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    widget.template.icon,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      widget.template.label,
                      style: textTheme.titleLarge?.copyWith(
                        color: disabled
                            ? colors.onSurfaceMuted
                            : colors.onSurface,
                      ),
                    ),
                    if (disabled) _ComingSoonBadge(colors: colors),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.template.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),
                if (!disabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        'Abrir demo',
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.template.label,
      onTap: disabled ? null : widget.onTap,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: disabled ? null : (_) => _setHovered(hovered: true),
        onExit: disabled ? null : (_) => _setHovered(hovered: false),
        child: GestureDetector(
          key: Key('showcase-card-${widget.template.id}'),
          onTap: disabled ? null : widget.onTap,
          child: card,
        ),
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        'em breve',
        style: textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
