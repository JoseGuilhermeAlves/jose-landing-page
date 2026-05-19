import 'package:feature_showcase/src/delivery/data/delivery_orders_catalog.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_brand.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_home_page.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Demo de delivery — mock multi-tela da marca ficticia "Aurora"
/// (hortifruti/emporio com entrega no dia, paleta verde/creme/ocre).
/// Substitui o demo single-screen anterior por uma experiencia
/// completa: home da marca + pedido ativo + lojas → detalhe com mapa
/// animado + historico.
///
/// Theme override aplica a `AuroraBrand.palette` localmente — todos os
/// widgets internos que leem `context.colors` recebem a paleta da
/// marca sem propagacao manual. Display em serif (sem dep externa),
/// body fica em sans.
class DeliveryDemo extends StatelessWidget {
  const DeliveryDemo({this.ticker, super.key});

  /// Stream de ticks (mantido por compatibilidade com o demo legado).
  /// Em producao, o widget host normalmente passa um
  /// `Stream.periodic(Duration(seconds: 2))`. Em testes, um
  /// `StreamController` controla cada tick.
  final Stream<void>? ticker;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AuroraBrand.buildTheme(context),
      child: BlocProvider(
        create: (_) => DeliveryBloc(
          initialOrders: DeliveryOrdersCatalog.all,
          ticker: ticker,
        ),
        child: const AuroraHomePage(),
      ),
    );
  }
}
