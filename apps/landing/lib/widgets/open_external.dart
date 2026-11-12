import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre [uri] no app externo apropriado (browser, mail client, WhatsApp).
/// No web, [LaunchMode.externalApplication] equivale a `window.open(_blank)`.
/// Engole falhas (reportando ao FlutterError) — falhar um CTA nao deve
/// quebrar o resto da sessao.
Future<void> openExternalUri(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'apps/landing',
        context: ErrorDescription('opening external uri $uri'),
      ),
    );
  }
}
