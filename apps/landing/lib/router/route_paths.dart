/// Lista centralizada de rotas — qualquer feature que precise navegar
/// importa daqui em vez de hardcodar a string.
abstract final class RoutePaths {
  static const String home = '/';

  /// Pagina de estudo de caso dos Custom Painters / cosmos da landing.
  /// Alcancada pelo teaser na home.
  static const String caseStudy = '/estudo';

  static const String notFoundFallback = '/404';
}
