import 'package:go_router/go_router.dart';
import 'package:landing/features/case_study/case_study_page.dart';
import 'package:landing/features/home_page.dart';
import 'package:landing/features/not_found_page.dart';
import 'package:landing/router/route_paths.dart';

/// Configuracao centralizada do GoRouter. A landing tem agora uma
/// unica rota publica (`/`) — o slot do antigo `/games` (raycaster /
/// Cosmos Defender) foi removido junto com o pacote `feature_games`,
/// substituido por um case study no scroll da home. Rotas
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
          path: RoutePaths.caseStudy,
          builder: (_, _) => const CaseStudyPage(),
        ),
        GoRoute(
          path: RoutePaths.notFoundFallback,
          pageBuilder: (_, _) => const NoTransitionPage(child: NotFoundPage()),
        ),
      ],
    );
  }
}
