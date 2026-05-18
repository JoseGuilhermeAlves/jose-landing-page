import 'package:feature_showcase/src/presentation/realestate/realestate_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helper de navegacao do demo Solar — empacota a sub-rota com o
/// `RealEstateBloc` do shell. Sub-rotas tem subtree de Element
/// independente e nao herdam providers da arvore externa por default;
/// reinjetar via `BlocProvider.value` preserva o state entre pops.
Widget solarWithDemoBloc(BuildContext context, Widget child) {
  return BlocProvider.value(
    value: context.read<RealEstateBloc>(),
    child: child,
  );
}
