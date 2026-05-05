/// Lista centralizada de rotas — qualquer feature que precise navegar
/// importa daqui em vez de hardcodar a string. Evita drift entre o que
/// o GoRouter conhece e o que as features usam para `context.go(...)`.
abstract final class RoutePaths {
  static const String home = '/';
  static const String labs = '/labs';

  static const String notFoundFallback = '/404';
}
