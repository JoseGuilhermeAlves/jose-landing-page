import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Rotulo de secao compartilhado pelos mocks: eyebrow em uppercase +
/// titulo. Cada marca passa sua fonte de display e peso pra preservar
/// identidade propria sem reimplementar o widget em cada pagina.
class MockSectionLabel extends StatelessWidget {
  const MockSectionLabel({
    required this.eyebrow,
    required this.title,
    required this.colors,
    required this.textTheme,
    this.titleFontFamily,
    this.titleFontWeight = FontWeight.w700,
    super.key,
  });

  final String eyebrow;
  final String title;
  final AppColorScheme colors;
  final TextTheme textTheme;

  /// Fonte de display da marca. Null usa a fonte padrao do tema.
  final String? titleFontFamily;
  final FontWeight titleFontWeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontFamily: titleFontFamily,
            fontWeight: titleFontWeight,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
