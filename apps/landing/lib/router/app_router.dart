import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
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
        // Mock do showcase como rota: o open entra no historico do navegador,
        // entao o botao voltar fecha o mock (volta pra home) em vez de sair do
        // site. `fullscreenDialog` preserva a transicao slide-up + o X de
        // fechar. As telas internas do mock seguem em Navigator.push imperativo
        // (sobre esta pagina); um voltar fecha o mock inteiro de uma vez.
        GoRoute(
          path: RoutePaths.demo,
          pageBuilder: (_, state) {
            final demo = showcaseDemoById(state.pathParameters['id'] ?? '');
            return MaterialPage<void>(
              fullscreenDialog: true,
              child: demo ?? const NotFoundPage(),
            );
          },
        ),
      ],
    );
  }
}
