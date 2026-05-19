import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/ecommerce/presentation/cart_bloc.dart';
import 'package:feature_showcase/src/ecommerce/presentation/cart_event.dart';
import 'package:feature_showcase/src/ecommerce/presentation/cart_state.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_brand.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_product_illustration.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Modal bottom sheet do carrinho Garoa — substitui o `_CartSheet`
/// generico anterior. Mantem a mesma `Key('ecommerce-cart-sheet')` pros
/// testes legados, mas com layout, ilustracao por painter e CTA de
/// checkout integrado ao [CartBloc].
///
/// Fluxo de checkout: o usuario aperta "Finalizar pedido", o sheet
/// dispara [CartCheckoutRequested] no bloc. Um [BlocListener] interno
/// observa a transicao `lastOrder == null -> nao-null` e fecha o sheet
/// retornando o `OrderSummary` pra rota de chamada — que entao empurra
/// a `GaroaOrderSummaryPage` com o resumo do pedido.
class GaroaCartSheet extends StatelessWidget {
  const GaroaCartSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<CartBloc, CartState>(
      // Observamos a transicao para um pedido novo — `previous` precisa
      // ser nulo ou diferente do atual, e `current` precisa ser nao
      // nulo. Sem isso, abrir o sheet apos um pedido anterior dispara
      // o pop automaticamente.
      listenWhen: (prev, curr) =>
          curr.lastOrder != null && curr.lastOrder != prev.lastOrder,
      listener: (context, state) {
        Navigator.of(context).pop(state.lastOrder);
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final shippingCents = state.totalCents >= 15000 ? 0.0 : 1500.0;
          final isEmpty = state.items.isEmpty;
          return SafeArea(
            top: false,
            child: Padding(
              key: const Key('ecommerce-cart-sheet'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SheetGrabber(colors: colors),
                  const SizedBox(height: AppSpacing.md),
                  _Header(
                    state: state,
                    onClear: isEmpty
                        ? null
                        : () => context
                            .read<CartBloc>()
                            .add(const CartCleared()),
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (isEmpty)
                    _EmptyState(colors: colors, textTheme: textTheme)
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.items.length,
                        separatorBuilder: (_, _) => Divider(
                          height: AppSpacing.lg,
                          color: colors.border,
                        ),
                        itemBuilder: (_, i) =>
                            _CartLineRow(line: state.items[i]),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  _Totals(
                    state: state,
                    shippingCents: shippingCents,
                    colors: colors,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    key: const Key('garoa-checkout-button'),
                    label: 'Finalizar pedido',
                    icon: Icons.check_rounded,
                    size: AppButtonSize.large,
                    expand: true,
                    onPressed: isEmpty
                        ? null
                        : () => context
                            .read<CartBloc>()
                            .add(const CartCheckoutRequested()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.state,
    required this.onClear,
    required this.colors,
    required this.textTheme,
  });

  final CartState state;
  final VoidCallback? onClear;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CARRINHO',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                state.items.isEmpty
                    ? 'Sem produtos ainda'
                    : '${state.totalQuantity} ${state.totalQuantity == 1 ? 'item' : 'itens'}',
                style: textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontFamily: GaroaBrand.displayFontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: Text(
              'Limpar',
              style: textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceMuted,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: colors.onSurfaceMuted,
            size: 36,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'O carrinho esta vazio.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
        ],
      ),
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
        SizedBox(
          width: 56,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: GaroaProductIllustration(
              category: line.product.category,
              foregroundColor: colors.primary,
              accentColor: colors.accent,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.product.name,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontFamily: GaroaBrand.displayFontFamily,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                formatBrl(line.subtotalCents),
                style: textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _QtyStepper(line: line, bloc: bloc, colors: colors, textTheme: textTheme),
      ],
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.line,
    required this.bloc,
    required this.colors,
    required this.textTheme,
  });

  final CartLine line;
  final CartBloc bloc;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Reduzir',
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            color: colors.onSurfaceMuted,
            onPressed: () => bloc.add(CartRemoveProduct(line.product.id)),
            icon: const Icon(Icons.remove_rounded),
          ),
          Text(
            '${line.quantity}',
            style: textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: 'Aumentar',
            iconSize: 16,
            visualDensity: VisualDensity.compact,
            color: colors.primary,
            onPressed: () => bloc.add(CartAddProduct(line.product)),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({
    required this.state,
    required this.shippingCents,
    required this.colors,
    required this.textTheme,
  });

  final CartState state;
  final double shippingCents;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final subtotal = state.totalCents;
    final total = subtotal + shippingCents;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          _Row(
            label: 'Subtotal',
            value: formatBrl(subtotal),
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label: 'Frete',
            value: shippingCents == 0
                ? 'Gratis'
                : formatBrl(shippingCents),
            colors: colors,
            textTheme: textTheme,
            valueColor:
                shippingCents == 0 ? colors.accent : colors.onSurfaceMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            label: 'Total',
            value: formatBrl(total),
            colors: colors,
            textTheme: textTheme,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.colors,
    required this.textTheme,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: (bold ? textTheme.titleMedium : textTheme.bodyMedium)?.copyWith(
            color: bold ? colors.onSurface : colors.onSurfaceMuted,
            fontWeight: bold ? FontWeight.w700 : null,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: (bold ? textTheme.titleLarge : textTheme.bodyMedium)?.copyWith(
            color: valueColor ?? (bold ? colors.primary : colors.onSurface),
            fontFamily: bold ? GaroaBrand.displayFontFamily : null,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
