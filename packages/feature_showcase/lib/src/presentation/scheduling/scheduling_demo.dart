import 'package:feature_showcase/src/presentation/scheduling/scheduling_bloc.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_brand.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Demo de agendamento — mock multi-tela da marca ficticia "Vitral"
/// (estudio de servicos por hora, paleta indigo/pao/cinza). Substitui
/// o demo single-screen anterior por uma experiencia completa: home
/// da marca → catalogo de servicos → calendario interativo →
/// confirmacao com resumo.
///
/// Theme override aplica a `VitralBrand.palette` localmente — todos
/// os widgets internos que leem `context.colors` recebem a paleta
/// da marca sem propagacao manual. Tipografia: sans em todos os
/// niveis; monospace pontual nos timestamps e codigos (fontFamily
/// inline via `VitralBrand.monoFontFamily`).
class SchedulingDemo extends StatelessWidget {
  const SchedulingDemo({
    required this.today,
    this.preBookedSlots,
    super.key,
  });

  /// Hoje como ancora pro range. Em produto real,
  /// `today: DateTime.now()`.
  final DateTime today;

  /// Override do mock pre-bookado. Quando null, usa a regra
  /// deterministica do bloc.
  final Set<DateTime>? preBookedSlots;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: VitralBrand.buildTheme(context),
      child: BlocProvider(
        create: (_) => SchedulingBloc(
          today: today,
          preBookedSlots: preBookedSlots,
        ),
        child: const VitralHomePage(),
      ),
    );
  }
}
