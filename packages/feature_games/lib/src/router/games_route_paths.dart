/// Paths das rotas do `/games`. Declarados aqui (e nao no shell) para
/// que feature_games nao dependa de apps/landing — o shell apenas
/// importa estas constantes ao configurar o `GoRouter`.
abstract final class GamesRoutePaths {
  static const String index = '/games';
  static const String raycaster = '/games/raycaster';
}
