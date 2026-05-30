import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Rodape da home. Curto e discreto — a secao de contato ja tem todos
/// os canais. Aqui ficam: copyright e tag "Feito em Flutter".
class HomeFooter extends StatelessWidget {
  const HomeFooter({required this.startYear, required this.name, super.key});

  final int startYear;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    final copy = '© $startYear $name';

    final madeWith = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flutter_dash, size: 14, color: colors.onSurfaceMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(
          context.l10n.footer_madeWith,
          style: textTheme.labelMedium?.copyWith(color: colors.onSurfaceMuted),
        ),
      ],
    );

    final content = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy,
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              madeWith,
            ],
          )
        : Row(
            children: [
              Text(
                copy,
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
              const Spacer(),
              madeWith,
            ],
          );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.huge,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: content,
    );
  }
}
