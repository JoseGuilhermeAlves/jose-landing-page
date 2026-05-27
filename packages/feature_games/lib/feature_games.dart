/// Feature Games — experiencias interativas em `/games`.
/// Exposto via deferred import no shell `apps/landing`: o bundle so
/// desce quando o usuario navega pra ca.
///
/// Constantes de rota (`GamesRoutePaths`) NAO sao re-exportadas aqui de
/// proposito — quem precisa delas em main bundle deve importar
/// `package:feature_games/games_route_paths.dart`.
library;

export 'src/playgrounds/raycaster_playground.dart';
