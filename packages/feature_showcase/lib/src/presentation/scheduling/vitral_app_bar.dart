import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_brand.dart';
import 'package:flutter/material.dart';

/// AppBar reutilizada pelas telas Vitral — brand title a esquerda,
/// `actions` opcional. Home passa close-x; demais paginas usam back
/// arrow automatico.
class VitralAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VitralAppBar({this.leading, this.actions, super.key});

  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppBar(
      backgroundColor: colors.background,
      surfaceTintColor: colors.background,
      elevation: 0,
      leading: leading,
      title: const _BrandTitle(),
      actions: actions,
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(
            'V',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          VitralBrand.name,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
