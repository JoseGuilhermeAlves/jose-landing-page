import 'package:feature_showcase/src/presentation/ecommerce/cart_bloc.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_brand.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Demo de e-commerce — mock multi-tela da marca ficticia "Garoa"
/// (cafe-livraria, paleta cafe-escuro/creme/musgo, opcoes em pt-br
/// caseira). Substitui o demo single-screen anterior por uma
/// experiencia completa: home da marca → catalogo com filtros →
/// detalhe do produto com variantes → carrinho com checkout → resumo
/// de pedido.
///
/// Theme override aplica a `GaroaBrand.palette` localmente — todos os
/// widgets internos que leem `context.colors` recebem a paleta da
/// marca sem propagacao manual. Tipografia muda apenas nos display
/// headlines (serif) — body fica em sans pra legibilidade.
class EcommerceDemo extends StatelessWidget {
  const EcommerceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: GaroaBrand.buildTheme(context),
      child: BlocProvider(
        create: (_) => CartBloc(),
        child: const GaroaHomePage(),
      ),
    );
  }
}
