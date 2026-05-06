import 'package:design_system/design_system.dart';
import 'package:feature_labs/labs_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rodape da home. Curto e discreto — a secao de contato ja tem todos
/// os canais. Aqui ficam: copyright, link discreto pra `/labs` (vitrine
/// tecnica, nao indexada no menu principal — PROJECT.md §4.6), tag
/// "Made with Flutter".
class HomeFooter extends StatelessWidget {
  const HomeFooter({
    required this.startYear,
    required this.name,
    super.key,
  });

  final int startYear;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    final copy = '© $startYear $name';

    final labsLink = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        key: const Key('footer-labs-link'),
        onTap: () => context.go(LabsRoutePaths.index),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '/labs',
              style: textTheme.labelMedium?.copyWith(
                color: colors.primary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '· para devs',
              style: textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );

    final madeWith = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.flutter_dash,
          size: 14,
          color: colors.onSurfaceMuted,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Feito em Flutter',
          style: textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceMuted,
          ),
        ),
      ],
    );

    final children = [
      Text(
        copy,
        style: textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceMuted,
        ),
      ),
      labsLink,
      madeWith,
    ];

    final content = isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                children[i],
              ],
            ],
          )
        : Row(
            children: [
              children[0],
              const Spacer(),
              children[1],
              const SizedBox(width: AppSpacing.lg),
              children[2],
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
