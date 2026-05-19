import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/ecommerce/presentation/cart_bloc.dart';
import 'package:feature_showcase/src/ecommerce/presentation/cart_state.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_brand.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// AppBar reutilizada pelas telas Garoa — brand title a esquerda, botao
/// de carrinho com contador a direita. Aceita `leading` customizado: a
/// home passa um close-x (pra fechar o demo), as demais paginas deixam
/// o `null` pra ter o back arrow automatico do Material.
class GaroaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GaroaAppBar({this.leading, super.key});

  final Widget? leading;

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
      actions: const [_CartButton(), SizedBox(width: AppSpacing.xs)],
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
            'G',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onPrimary,
              fontFamily: GaroaBrand.displayFontFamily,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          GaroaBrand.name,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontFamily: GaroaBrand.displayFontFamily,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                key: const Key('ecommerce-cart-button'),
                tooltip: 'Abrir carrinho',
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: colors.onSurface,
                ),
                onPressed: () => openGaroaCart(context),
              ),
              // Badge so renderiza quando ha itens. Os widget tests
              // verificam a ausencia do badge pra "carrinho vazio".
              if (state.totalQuantity > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${state.totalQuantity}',
                      key: const Key('ecommerce-cart-count'),
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
