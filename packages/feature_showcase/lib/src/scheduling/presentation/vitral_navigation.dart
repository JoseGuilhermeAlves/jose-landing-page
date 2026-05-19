import 'package:feature_showcase/src/scheduling/presentation/scheduling_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helper de navegacao do demo Vitral — empacota a sub-rota com o
/// `SchedulingBloc` do shell. Mesmo motivo dos outros mocks: a
/// sub-rota tem subtree de Element independente e nao herda providers
/// da arvore externa por default.
Widget vitralWithDemoBloc(BuildContext context, Widget child) {
  return BlocProvider.value(
    value: context.read<SchedulingBloc>(),
    child: child,
  );
}
