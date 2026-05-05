import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing/features/home_page.dart';
import 'package:landing/features/labs_page.dart' deferred as labs;
import 'package:landing/features/not_found_page.dart';
import 'package:landing/router/route_paths.dart';

/// Configuracao centralizada do GoRouter. Mantem `/labs` como
/// **deferred import** — em build web, o codigo da feature_labs vira
/// um bundle separado que so baixa quando o usuario navega para ca.
abstract final class AppRouter {
  /// Cria uma instancia nova de [GoRouter]. Recebe [initialLocation]
  /// pra facilitar testes deep-link.
  static GoRouter create({String initialLocation = RoutePaths.home}) {
    return GoRouter(
      initialLocation: initialLocation,
      errorBuilder: (_, _) => const NotFoundPage(),
      routes: [
        GoRoute(
          path: RoutePaths.home,
          pageBuilder: (_, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: RoutePaths.labs,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredLabs(),
          ),
        ),
        GoRoute(
          path: RoutePaths.notFoundFallback,
          pageBuilder: (_, _) => const NoTransitionPage(
            child: NotFoundPage(),
          ),
        ),
      ],
    );
  }
}

/// Wrapper que dispara `loadLibrary()` no primeiro build. Em VM (testes)
/// `loadLibrary` resolve imediatamente; em web ele aguarda o download
/// do bundle deferido.
class _DeferredLabs extends StatefulWidget {
  @override
  State<_DeferredLabs> createState() => _DeferredLabsState();
}

class _DeferredLabsState extends State<_DeferredLabs> {
  late final Future<void> _loaded = labs.loadLibrary();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loaded,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const NotFoundPage();
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: LoadingSpinner()),
          );
        }
        return labs.LabsPage();
      },
    );
  }
}
