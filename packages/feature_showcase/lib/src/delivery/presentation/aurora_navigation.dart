import 'package:feature_showcase/src/delivery/presentation/delivery_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helper de navegacao do demo Aurora — empacota a sub-rota com o
/// `DeliveryBloc` do shell. Mesmo motivo do Garoa: a sub-rota tem
/// subtree de Element independente e nao herda providers da arvore
/// externa por default.
Widget auroraWithDemoBloc(BuildContext context, Widget child) {
  return BlocProvider.value(
    value: context.read<DeliveryBloc>(),
    child: child,
  );
}
