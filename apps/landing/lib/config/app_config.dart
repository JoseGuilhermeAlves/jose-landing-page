/// Constantes do shell `apps/landing`. Crescera com URLs externas
/// (LinkedIn, GitHub, WhatsApp pre-preenchido) conforme as features
/// pedirem — manter centralizado evita drift entre call sites.
///
/// **Nao** colocar aqui:
/// - segredos (chaves de API, etc.) — usar `--dart-define` no build;
/// - copy de UI — copy mora dentro de cada feature.
abstract final class AppConfig {
  /// URL do repositorio publico do projeto. Exibida em `LabsPage`
  /// (botao "Ver repo no GitHub"). Atualize aqui quando o remote for
  /// criado, e o conteudo da landing automaticamente seguira.
  static const String githubRepoUrl =
      'https://github.com/JoseGuilhermeAlves/jose-landing-page';
}
