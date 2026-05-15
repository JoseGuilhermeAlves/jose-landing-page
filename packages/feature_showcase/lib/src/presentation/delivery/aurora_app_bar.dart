import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/presentation/delivery/aurora_brand.dart';
import 'package:flutter/material.dart';

/// AppBar reutilizada pelas telas Aurora — brand title a esquerda,
/// opcional `actions` a direita. Aceita `leading` customizado: a home
/// passa um close-x (pra fechar o demo), as demais paginas deixam null
/// pra ter o back arrow automatico.
class AuroraAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuroraAppBar({this.leading, this.actions, super.key});

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
        // Mini glifo de marca — quadrado verde com inicial em serif.
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(
            'A',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onPrimary,
              fontFamily: AuroraBrand.displayFontFamily,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          AuroraBrand.name,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontFamily: AuroraBrand.displayFontFamily,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
