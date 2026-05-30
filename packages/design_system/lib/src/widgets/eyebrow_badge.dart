import 'package:design_system/src/spacing/app_spacing.dart';
import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/tokens/app_radius.dart';
import 'package:flutter/material.dart';

/// Chip pequeno em uppercase usado como pre-headline de secao —
/// padrao adotado por Linear, Vercel, Stripe. Inclui um dot pulsante
/// (default) ou um icone, e renderiza o label em letterspacing largo.
///
/// Use uma vez por secao logo antes do headline grande pra dar
/// "ancoragem" visual e melhorar scan em scroll rapido.
class EyebrowBadge extends StatelessWidget {
  const EyebrowBadge({
    required this.label,
    this.icon,
    this.showDot = true,
    this.accentColor,
    super.key,
  });

  final String label;

  /// Quando informado e [showDot] e false, substitui o dot.
  final IconData? icon;

  /// Mostra um pequeno disco com glow no inicio. Quando false e
  /// [icon] tambem null, o badge fica so com o texto.
  final bool showDot;

  /// Cor de destaque customizada. Quando null, usa [AppColorScheme.primary].
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final color = accentColor ?? colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            _GlowDot(color: color),
            const SizedBox(width: AppSpacing.sm),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: color,
                letterSpacing: 0.8,
              ),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowDot extends StatelessWidget {
  const _GlowDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
        ],
      ),
    );
  }
}
