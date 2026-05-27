import 'package:feature_games/games_route_paths.dart';

/// Lista centralizada de rotas — qualquer feature que precise navegar
/// importa daqui em vez de hardcodar a string.
abstract final class RoutePaths {
  static const String home = '/';
  static const String games = GamesRoutePaths.index;

  static const String notFoundFallback = '/404';
}
