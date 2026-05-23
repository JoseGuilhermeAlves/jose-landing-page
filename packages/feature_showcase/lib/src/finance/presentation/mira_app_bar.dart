import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// AppBar dark customizada do mock Mira — fundo `surface`, sem
/// elevation, sem divider. Mantemos um helper proprio em vez de
/// confiar no `AppBarTheme` global porque o demo as vezes precisa
/// pegar a paleta da marca *atual* via `context.colors`, e nao a
/// herdada do MaterialApp da landing.
class MiraAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MiraAppBar({
    required this.title,
    this.leading,
    this.actions,
    super.key,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppBar(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      iconTheme: IconThemeData(color: colors.onSurface),
      titleSpacing: 0,
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
      actions: actions,
      shape: Border(bottom: BorderSide(color: colors.border)),
    );
  }
}
