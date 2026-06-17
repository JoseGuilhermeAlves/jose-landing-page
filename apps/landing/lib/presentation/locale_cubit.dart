import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Mantém o locale ativo da landing.
///
/// Nasce em **português** — idioma primário da landing (portfólio BR), não
/// o do navegador do visitante. O switcher troca via [changeLocale].
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(_initial);

  static const Locale _initial = Locale('pt');

  void changeLocale(Locale locale) => emit(locale);
}
