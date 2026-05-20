import 'package:feature_showcase/src/scheduling/presentation/scheduling_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helper de navegacao do demo Vitral — empacota a sub-rota com o
/// `SchedulingBloc` do shell **e** com o `Theme` corrente. Sub-rotas
/// abertas via `Navigator.push` constroem o builder sob o overlay do
/// Navigator raiz, acima do `Theme` da marca na Element tree — sem
/// re-wrappar, `Theme.of(context)` resolve contra o dark da landing.
Widget vitralWithDemoBloc(BuildContext context, Widget child) {
  return Theme(
    data: Theme.of(context),
    child: BlocProvider.value(
      value: context.read<SchedulingBloc>(),
      child: child,
    ),
  );
}
