import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/tokens/app_radius.dart';
import 'package:flutter/material.dart';

/// Card base — superficie elevada visual (sem elevacao Material real, dark
/// theme prefere borda em vez de sombra).
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );

    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}
