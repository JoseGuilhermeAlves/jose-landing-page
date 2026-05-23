import 'package:design_system/src/responsive/breakpoint.dart';
import 'package:design_system/src/spacing/app_spacing.dart';
import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/tokens/app_gradients.dart';
import 'package:design_system/src/widgets/eyebrow_badge.dart';
import 'package:design_system/src/widgets/gradient_text.dart';
import 'package:flutter/material.dart';

/// Cabecalho padrao de secao: eyebrow (chip) -> headline grande
/// (com palavra-chave em gradiente, opcional) -> subtitle muted.
///
/// Padroniza o ritmo vertical das secoes da landing — se cada feature
/// inventar seu cabecalho, o scan visual quebra.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.eyebrow,
    required this.title,
    this.titleAccent,
    this.subtitle,
    this.alignment = CrossAxisAlignment.start,
    this.subtitleMaxWidth = 720,
    super.key,
  });

  final String eyebrow;
  final String title;

  /// Quando informado, renderiza em linha proxima abaixo do [title]
  /// com fill em gradiente brand (primary -> accent). Use pra destacar
  /// 1-3 palavras — paragrafos perdem contraste em gradiente.
  final String? titleAccent;
  final String? subtitle;
  final CrossAxisAlignment alignment;
  final double subtitleMaxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    final headlineStyle =
        (isMobile ? textTheme.headlineMedium : textTheme.displaySmall)
            ?.copyWith(
              color: colors.onSurface,
              height: 1.1,
              letterSpacing: -0.6,
            );

    final textAlign = switch (alignment) {
      CrossAxisAlignment.center => TextAlign.center,
      CrossAxisAlignment.end => TextAlign.end,
      _ => TextAlign.start,
    };

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        EyebrowBadge(label: eyebrow),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          header: true,
          child: Column(
            crossAxisAlignment: alignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: headlineStyle, textAlign: textAlign),
              if (titleAccent != null)
                GradientText(
                  text: titleAccent!,
                  gradient: AppGradients.brand(colors),
                  style: headlineStyle,
                  textAlign: textAlign,
                ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: subtitleMaxWidth),
            child: Text(
              subtitle!,
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceMuted,
                height: 1.55,
              ),
              textAlign: textAlign,
            ),
          ),
        ],
      ],
    );
  }
}
