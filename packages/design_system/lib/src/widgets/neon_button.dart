import 'package:design_system/src/responsive/breakpoint.dart';
import 'package:design_system/src/spacing/app_spacing.dart';
import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/tokens/app_duration.dart';
import 'package:design_system/src/typography/pixel_text.dart';
import 'package:flutter/material.dart';

/// Botao do vocabulario neon da landing: cantos retos, borda fina na cor do
/// botao, preenchido (CTA primario) ou contornado. Hover acende um glow
/// discreto e preenche o contornado.
///
/// Label em sans legivel (caixa alta, tracking aberto) por padrao. [pixel]
/// troca pra fonte bitmap — reservado a contextos assumidamente "jogo"
/// (pagina do Poço), onde a estetica de fliperama e o proprio assunto.
class NeonButton extends StatefulWidget {
  const NeonButton({
    required this.label,
    required this.onPressed,
    this.color,
    this.filled = false,
    this.icon,
    this.pixel = false,
    this.dense = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Cor do neon. Default: `colors.primary`.
  final Color? color;
  final bool filled;

  /// Icone opcional depois do label (ex.: seta, download).
  final IconData? icon;

  /// Label em [PixelText] (so na pagina gamificada).
  final bool pixel;

  /// Padding reduzido (linhas de download, toolbars).
  final bool dense;

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = widget.color ?? colors.primary;
    final lit = _hovered || widget.filled;
    final fg = lit ? colors.background : color;
    final isMobile = context.isMobile;

    final Widget label = widget.pixel
        ? PixelText(widget.label, color: fg, pixelSize: isMobile ? 2 : 3)
        : Text(
            widget.label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              height: 1.2,
            ),
          );

    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: widget.onPressed == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: AppDuration.fast,
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: widget.dense ? AppSpacing.md : AppSpacing.lg,
              vertical: widget.dense ? AppSpacing.sm : AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: lit ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.5),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: label),
                if (widget.icon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(widget.icon, size: 16, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
