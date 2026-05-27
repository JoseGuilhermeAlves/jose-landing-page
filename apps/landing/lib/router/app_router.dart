import 'package:animations/animations.dart';
import 'package:feature_games/feature_games.dart' deferred as games;
import 'package:feature_games/games_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing/features/home_page.dart';
import 'package:landing/features/not_found_page.dart';
import 'package:landing/router/route_paths.dart';

/// Configuracao centralizada do GoRouter. Mantem `/games` como
/// **deferred import** — em build web, o codigo do feature_games
/// vira um bundle separado que so baixa quando o usuario navega.
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
          path: GamesRoutePaths.index,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredGames(
              builder: () => games.RaycasterPlayground(),
            ),
          ),
        ),
        GoRoute(
          path: GamesRoutePaths.raycaster,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredGames(
              builder: () => games.RaycasterPlayground(),
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.notFoundFallback,
          pageBuilder: (_, _) => const NoTransitionPage(child: NotFoundPage()),
        ),
      ],
    );
  }
}

/// Wrapper que dispara `loadLibrary()` no primeiro build.
class _DeferredGames extends StatefulWidget {
  const _DeferredGames({required this.builder});

  final Widget Function() builder;

  @override
  State<_DeferredGames> createState() => _DeferredGamesState();
}

class _DeferredGamesState extends State<_DeferredGames> {
  late final Future<void> _loaded = games.loadLibrary();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loaded,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const NotFoundPage();
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: LoadingSpinner()));
        }
        return widget.builder();
      },
    );
  }
}
