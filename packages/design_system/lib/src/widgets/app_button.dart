import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/tokens/app_duration.dart';
import 'package:design_system/src/tokens/app_radius.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, ghost }

enum AppButtonSize { medium, large }

/// Botao base do design system. Variantes:
/// - [AppButtonVariant.primary]   — CTA principal (Hero, contato)
/// - [AppButtonVariant.secondary] — acao alternativa (Ver projetos)
/// - [AppButtonVariant.ghost]     — links em texto / nav discreta
class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovering = false;

  bool get _disabled => widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);

    final (Color background, Color foreground, Color? border) = switch (widget.variant) {
      AppButtonVariant.primary => (
          _hovering && !_disabled ? colors.primaryHover : colors.primary,
          colors.onPrimary,
          null,
        ),
      AppButtonVariant.secondary => (
          _hovering && !_disabled ? colors.surfaceMuted : colors.surface,
          colors.onSurface,
          colors.border,
        ),
      AppButtonVariant.ghost => (
          _hovering && !_disabled ? colors.surfaceMuted : Colors.transparent,
          colors.onSurface,
          null,
        ),
    };

    final padding = switch (widget.size) {
      AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    };

    final textStyle = switch (widget.size) {
      AppButtonSize.medium => theme.textTheme.labelMedium,
      AppButtonSize.large => theme.textTheme.labelLarge,
    };

    final button = AnimatedContainer(
      duration: AppDuration.fast,
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: _disabled ? colors.surfaceMuted : background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: 18,
              color: _disabled ? colors.onSurfaceMuted : foreground,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            widget.label,
            style: textStyle?.copyWith(
              color: _disabled ? colors.onSurfaceMuted : foreground,
            ),
          ),
        ],
      ),
    );

    return MouseRegion(
      cursor: _disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Semantics(
          button: true,
          enabled: !_disabled,
          label: widget.label,
          child: button,
        ),
      ),
    );
  }
}
