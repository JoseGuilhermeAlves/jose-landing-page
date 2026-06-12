import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mantém o locale ativo da landing.
///
/// Nasce resolvendo o locale do sistema contra os locales suportados
/// (fallback pt). O override manual do switcher continua via [changeLocale].
class LocaleCubit extends Cubit<Locale> {
  /// [systemLocale] permite injetar o locale do sistema em testes; quando
  /// omitido, lê `PlatformDispatcher.instance.locale` (seguro sem binding).
  LocaleCubit({Locale? systemLocale})
    : super(resolveLocale(systemLocale ?? PlatformDispatcher.instance.locale));

  static const Locale _fallback = Locale('pt');

  /// Resolve o locale do sistema contra `AppLocalizations.supportedLocales`
  /// comparando por languageCode (os 9 suportados são language-only).
  /// Sem correspondência, cai em pt — não no primeiro da lista gerada.
  static Locale resolveLocale(Locale system) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == system.languageCode) return supported;
    }
    return _fallback;
  }

  void changeLocale(Locale locale) => emit(locale);
}
