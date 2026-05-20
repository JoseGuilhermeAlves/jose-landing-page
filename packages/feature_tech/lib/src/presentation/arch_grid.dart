import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_tech/src/domain/arch_decision.dart';
import 'package:flutter/material.dart';

/// Grid das decisoes arquiteturais. Cada card mostra icone + titulo +
/// body curto e revela uma borda em gradient brand quando o mouse
/// entra — usa `AnimatedBorderPainter` do pacote animations.
class ArchGrid extends StatelessWidget {
  const ArchGrid({required this.decisions, super.key});

  final List<ArchDecision> decisions;

  int _columnsFor(Breakpoint bp) => switch (bp) {
        Breakpoint.mobile => 1,
        Breakpoint.tablet => 2,
        Breakpoint.desktop || Breakpoint.wide => 3,
      };

  @override
  Widget build(BuildContext context) {
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
            for (final d in decisions)
              SizedBox(
                width: cardWidth,
                child: ArchCard(decision: d),
              ),
          ],
        );
      },
    );
  }
}

/// Card individual de decisao. Border base estatica + border accent
/// animada via `AnimatedBorderPainter` no hover (0 -> perimetro completo
/// em 420ms).
class ArchCard extends StatefulWidget {
  const ArchCard({required this.decision, super.key});

  final ArchDecision decision;

  @override
  State<ArchCard> createState() => _ArchCardState();
}

class _ArchCardState extends State<ArchCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            foregroundPainter: AnimatedBorderPainter(
              progress: _controller.value,
              color: colors.primary,
              borderRadius: AppRadius.lg,
              strokeWidth: 1.8,
            ),
            child: child,
          );
        },
        child: Container(
          key: Key('arch-card-${widget.decision.id}'),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
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
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  widget.decision.icon,
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.decision.title,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.decision.body,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
