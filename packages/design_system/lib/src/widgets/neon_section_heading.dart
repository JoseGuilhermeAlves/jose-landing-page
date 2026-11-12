import 'package:design_system/src/responsive/breakpoint.dart';
import 'package:design_system/src/spacing/app_spacing.dart';
import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/typography/pixel_text.dart';
import 'package:flutter/material.dart';

/// Cabecalho padrao das secoes da home. Hierarquia unica e previsivel:
///
/// `01 ── EYEBROW` (indice em pixel + filete neon + rotulo em caixa alta)
/// **Titulo** com acento em magenta (sans, display)
/// Subtitulo em texto suave, largura de leitura limitada.
///
/// A fonte pixel fica restrita ao indice — um toque de identidade sem
/// sacrificar a leitura dos titulos.
class NeonSectionHeading extends StatelessWidget {
  const NeonSectionHeading({
    required this.index,
    required this.eyebrow,
    required this.title,
    this.titleAccent,
    this.subtitle,
    this.subtitleMaxWidth = 640,
    super.key,
  });

  /// Numero da secao, ex. `01`.
  final String index;
  final String eyebrow;
  final String title;
  final String? titleAccent;
  final String? subtitle;
  final double subtitleMaxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    final titleStyle = (isMobile ? tt.headlineLarge : tt.displaySmall)
        ?.copyWith(color: colors.onSurface, height: 1.15, letterSpacing: -0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelText(index, color: colors.primary, pixelSize: 2),
            const SizedBox(width: AppSpacing.sm),
            Container(width: 28, height: 1.5, color: colors.primary),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                eyebrow.toUpperCase(),
                style: tt.labelMedium?.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              style: titleStyle,
              children: [
                TextSpan(text: title),
                if (titleAccent != null) ...[
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: titleAccent,
                    style: TextStyle(color: colors.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: subtitleMaxWidth),
            child: Text(
              subtitle!,
              style: (isMobile ? tt.bodyMedium : tt.bodyLarge)?.copyWith(
                color: colors.onSurfaceMuted,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
