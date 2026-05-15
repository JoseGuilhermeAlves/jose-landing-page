import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/domain/order_summary.dart';
import 'package:feature_showcase/src/presentation/ecommerce/cart_bloc.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_cart_sheet.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_order_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helpers de navegacao internos do demo Garoa. Centralizados aqui pra
/// que home/catalogo/detalhe nao repliquem a logica de empurrar rotas
/// preservando o `CartBloc` do shell.
///
/// **Por que precisa de helper:** quando empurramos uma sub-rota com
/// `Navigator.of(context).push`, o novo `Element` recebe um subtree
/// independente do shell e **nao herda** os `Provider`s externos por
/// padrao. Solucao: re-injetar o `CartBloc` (que vive no shell) via
/// `BlocProvider.value` no builder da nova rota.

/// Empacota [child] com o `CartBloc` corrente — usado pelas paginas
/// quando empurram a proxima tela.
Widget garoaWithDemoBloc(BuildContext context, Widget child) {
  return BlocProvider.value(
    value: context.read<CartBloc>(),
    child: child,
  );
}

/// Abre o carrinho como modal bottom sheet com o tema Garoa
/// preservado. Quando o usuario finaliza o pedido, o sheet retorna
/// o [OrderSummary] e este helper empurra a [GaroaOrderSummaryPage].
Future<void> openGaroaCart(BuildContext context) async {
  final cartBloc = context.read<CartBloc>();
  final colors = context.colors;
  final navigator = Navigator.of(context);

  final order = await showModalBottomSheet<OrderSummary>(
    context: context,
    backgroundColor: colors.surface,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => BlocProvider.value(
      value: cartBloc,
      child: const GaroaCartSheet(),
    ),
  );

  if (order != null) {
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cartBloc,
          child: GaroaOrderSummaryPage(order: order),
        ),
      ),
    );
  }
}
