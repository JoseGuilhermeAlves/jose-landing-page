import 'package:feature_labs/labs_route_paths.dart';

/// Lista centralizada de rotas — qualquer feature que precise navegar
/// importa daqui em vez de hardcodar a string. Evita drift entre o que
/// o GoRouter conhece e o que as features usam para `context.go(...)`.
///
/// As paths do `/labs/*` ficam canonicas em `LabsRoutePaths` (dentro
/// do feature_labs) e sao re-expostas aqui pra que o shell tenha um
/// ponto unico de consulta. O import e EAGER de proposito — so as
/// constantes sobem ao main bundle, sem materializar os widgets do
/// playground.
abstract final class RoutePaths {
  static const String home = '/';
  static const String labs = LabsRoutePaths.index;

  static const String notFoundFallback = '/404';
}
