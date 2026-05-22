import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Inicializacao centralizada do app. Cuida de:
/// - capturar erros do framework Flutter (FlutterError.onError);
/// - capturar erros assincronos da plataforma
///   (PlatformDispatcher.instance.onError);
/// - rodar [runApp] dentro de [runZonedGuarded] pra pegar o que escapar.
///
/// Em release, plug aqui o sink de telemetria (Sentry/Crashlytics).
Future<void> bootstrap(Widget Function() builder) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        // TODO(jose): integrar com Sentry/Crashlytics em release.
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('[bootstrap] uncaught: $error\n$stack');
        return true;
      };

      runApp(builder());
    },
    (error, stack) {
      debugPrint('[bootstrap] zone error: $error\n$stack');
    },
  );
}
