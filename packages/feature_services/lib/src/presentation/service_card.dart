import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_services/src/domain/service.dart';
import 'package:flutter/material.dart';

/// Card de um servico individual. Em hover desenha uma borda animada
/// progressivamente (PROJECT.md §4.2) usando o [AnimatedBorderPainter].
class ServiceCard extends StatefulWidget {
  const ServiceCard({
    required this.service,
    this.onPressed,
    super.key,
  });

  final Service service;
  final VoidCallback? onPressed;

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  static const Duration _animDuration = Duration(milliseconds: 480);
  static const double _radius = AppRadius.lg;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _animDuration,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _hovered = false;

  void _setHovered({required bool hovered}) {
    if (_hovered == hovered) return;
    _hovered = hovered;
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

    final card = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          foregroundPainter: AnimatedBorderPainter(
            progress: _controller.value,
            color: colors.primary,
            borderRadius: _radius,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    widget.service.icon,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.service.title,
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.service.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return MouseRegion(
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onHover: (_) => _setHovered(hovered: true),
      onExit: (_) => _setHovered(hovered: false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Semantics(
          button: widget.onPressed != null,
          enabled: widget.onPressed != null,
          label: widget.service.title,
          onTap: widget.onPressed,
          excludeSemantics: true,
          child: card,
        ),
      ),
    );
  }
}
