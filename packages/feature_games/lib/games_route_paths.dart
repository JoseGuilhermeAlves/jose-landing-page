/// Re-export eager-only do `GamesRoutePaths`. Importe esta library (em
/// vez do barrel `feature_games.dart`) quando precisar das paths
/// constantes — assim o shell mantem o GoRouter configurado sem
/// arrastar o bundle deferido inteiro pro main chunk.
library;

export 'src/router/games_route_paths.dart';
