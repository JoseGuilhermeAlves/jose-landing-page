import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/products_catalog.dart';
import 'package:feature_showcase/src/domain/product.dart';
import 'package:feature_showcase/src/presentation/ecommerce/cart_bloc.dart';
import 'package:feature_showcase/src/presentation/ecommerce/cart_event.dart';
import 'package:feature_showcase/src/presentation/ecommerce/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela completa do mock E-commerce — grade de produtos + botao de
/// carrinho que abre bottom sheet. Estado em [CartBloc] proprio
/// (escopo desta sub-feature, nao polui o app shell).
class EcommerceDemo extends StatelessWidget {
  const EcommerceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => CartBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              title: Text('Loja demo', style: textTheme.titleLarge),
              actions: [_CartButton(onPressed: () => _openCart(context))],
            ),
            body: const _ProductGrid(),
          );
        },
      ),
    );
  }

  void _openCart(BuildContext context) {
    final colors = context.colors;
    final bloc = context.read<CartBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const _CartSheet(),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid();

  int _columnsFor(Breakpoint bp) => switch (bp) {
        Breakpoint.mobile => 2,
        Breakpoint.tablet => 3,
        Breakpoint.desktop || Breakpoint.wide => 4,
      };

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(context.breakpoint);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppSpacing.md;
          final cardWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;
          return SingleChildScrollView(
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final p in ProductsCatalog.all)
                  SizedBox(
                    width: cardWidth,
                    child: _ProductCard(product: p),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      key: const Key('ecommerce-product-card'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: Text(
                product.emoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            product.name,
            style: textTheme.titleSmall?.copyWith(color: colors.onSurface),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            product.formattedPrice,
            style: textTheme.titleMedium?.copyWith(color: colors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            key: const Key('ecommerce-add-button'),
            label: 'Adicionar',
            icon: Icons.add,
            onPressed: () =>
                context.read<CartBloc>().add(CartAddProduct(product)),
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: TextButton.icon(
            key: const Key('ecommerce-cart-button'),
            onPressed: onPressed,
            icon: Icon(Icons.shopping_cart_outlined, color: colors.onSurface),
            label: Text(
              '${state.totalQuantity}',
              key: const Key('ecommerce-cart-count'),
              style: textTheme.titleSmall?.copyWith(color: colors.onSurface),
            ),
          ),
        );
      },
    );
  }
}

class _CartSheet extends StatelessWidget {
  const _CartSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: Padding(
            key: const Key('ecommerce-cart-sheet'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'Seu carrinho',
                      style: textTheme.titleLarge
                          ?.copyWith(color: colors.onSurface),
                    ),
                    const Spacer(),
                    if (state.items.isNotEmpty)
                      TextButton(
                        onPressed: () =>
                            context.read<CartBloc>().add(const CartCleared()),
                        child: Text(
                          'Limpar',
                          style: TextStyle(color: colors.onSurfaceMuted),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Text(
                      'Vazio por enquanto.',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceMuted),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) => _CartLineRow(line: state.items[i]),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Text(
                      'Total',
                      style: textTheme.titleMedium
                          ?.copyWith(color: colors.onSurfaceMuted),
                    ),
                    const Spacer(),
                    Text(
                      state.formattedTotal,
                      style: textTheme.titleLarge
                          ?.copyWith(color: colors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartLineRow extends StatelessWidget {
  const _CartLineRow({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final bloc = context.read<CartBloc>();

    return Row(
      children: [
        Text(line.product.emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.product.name,
                style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                line.product.formattedPrice,
                style: textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceMuted),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove),
          color: colors.onSurfaceMuted,
          onPressed: () => bloc.add(CartRemoveProduct(line.product.id)),
        ),
        Text(
          '${line.quantity}',
          style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          color: colors.primary,
          onPressed: () => bloc.add(CartAddProduct(line.product)),
        ),
      ],
    );
  }
}
