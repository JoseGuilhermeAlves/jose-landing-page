/// Constantes do shell `apps/landing`. Crescera com URLs externas
/// (LinkedIn, GitHub, WhatsApp pre-preenchido) conforme as features
/// pedirem — manter centralizado evita drift entre call sites.
///
/// **Nao** colocar aqui:
/// - segredos (chaves de API, etc.) — usar `--dart-define` no build;
/// - copy de UI — copy mora dentro de cada feature.
abstract final class AppConfig {
  /// Numero do WhatsApp em E.164 sem `+` (ex.: `5514...`). Usado pelo
  /// CTA do Hero e pelo tile alternativo da secao de contato.
  static const String whatsappNumber = '5514991163009';

  /// Email de contato — canal primario do funil tech/recruiter.
  static const String email = 'contato.joseguilhermealves@gmail.com';

  /// Perfil do LinkedIn — exibido na nav e na secao de contato.
  static const String linkedinUrl =
      'https://www.linkedin.com/in/jos%C3%A9-guilherme-alves-10a17b138/';

  /// Perfil do GitHub — usado na nav, na secao Engineering e no
  /// contato. Decisao do Jose (2026-06-11): apontar pro perfil, nao
  /// pra um repositorio especifico.
  static const String githubProfileUrl =
      'https://github.com/JoseGuilhermeAlves';

  /// Currículo em PDF — servido como asset estatico de
  /// `apps/landing/web/cv/` (URL relativa, resolve contra a origem do
  /// deploy). Ha versao PT e EN; o shell escolhe pelo idioma atual via
  /// [resumeUrlFor].
  static const String resumeUrlPt = 'cv/jose-guilherme-alves-pt.pdf';
  static const String resumeUrlEn = 'cv/jose-guilherme-alves-en.pdf';

  /// CV no idioma certo: PT para `pt`, EN para qualquer outro (os dois
  /// unicos PDFs mantidos — ver decisao 2026-06-17).
  static String resumeUrlFor(String languageCode) =>
      languageCode == 'pt' ? resumeUrlPt : resumeUrlEn;

  /// Base dos downloads da demo do Poço. Os binarios passam do limite de
  /// 100 MB por arquivo do GitHub Pages, entao moram numa GitHub Release
  /// do repo publico da landing. Pra preview local, sobrescrever com
  /// `--dart-define=POCO_DEMO_BASE=http://localhost:<porta>/`.
  static const String pocoDemoBase = String.fromEnvironment(
    'POCO_DEMO_BASE',
    defaultValue:
        'https://github.com/JoseGuilhermeAlves/jose-landing-page/releases/download/poco-demo/',
  );

  /// Versao do build publicado na release — trocar junto com o upload.
  static const String pocoDemoVersion = 'v0.6.0';

  static const String pocoDemoWindowsUrl =
      '${pocoDemoBase}Poco-demo-windows.zip';
  static const String pocoDemoAndroidUrl =
      '${pocoDemoBase}Poco-demo-android.apk';

  /// Trailer do Poço em versao web (720p, ~14 MB) servido do proprio
  /// Pages a partir de `apps/landing/web/trailer/` — asset de Release
  /// vem como download, nao toca no navegador. O original 1080p fica na
  /// Release `poco-demo`.
  static const String pocoTrailerUrl = 'trailer/poco-trailer.mp4';

  /// Poster do trailer — asset Flutter (o widget usa `Image.asset`; o
  /// `<video>` aponta pro mesmo arquivo pela URL publicada do asset).
  static const String pocoTrailerPosterAsset =
      'assets/images/poco_trailer_poster.jpg';
}
