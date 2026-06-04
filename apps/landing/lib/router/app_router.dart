import 'package:go_router/go_router.dart';
import 'package:landing/features/home_page.dart';
import 'package:landing/features/not_found_page.dart';
import 'package:landing/router/route_paths.dart';

/// Configuracao centralizada do GoRouter. A landing tem uma unica rota
/// publica (`/`) — todo o conteudo vive no scroll da home. Rotas
/// desconhecidas caem em [NotFoundPage].
abstract final class AppRouter {
  static GoRouter create({String initialLocation = RoutePaths.home}) {
    return GoRouter(
      initialLocation: initialLocation,
      errorBuilder: (_, _) => const NotFoundPage(),
      routes: [
        GoRoute(
          path: RoutePaths.home,
          pageBuilder: (_, state) => const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: RoutePaths.notFoundFallback,
          pageBuilder: (_, _) => const NoTransitionPage(child: NotFoundPage()),
        ),
      ],
    );
  }
}
