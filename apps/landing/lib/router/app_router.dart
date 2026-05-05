import 'dart:async';

import 'package:animations/animations.dart';
import 'package:feature_labs/feature_labs.dart' deferred as labs;
import 'package:feature_labs/labs_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing/config/app_config.dart';
import 'package:landing/features/home_page.dart';
import 'package:landing/features/not_found_page.dart';
import 'package:landing/router/route_paths.dart';
import 'package:url_launcher/url_launcher.dart';

/// Configuracao centralizada do GoRouter. Mantem `/labs` (e todas as
/// suas sub-rotas) como **deferred import** — em build web, o codigo
/// do feature_labs vira um bundle separado que so baixa quando o
/// usuario navega pra dentro do playground.
///
/// Constantes de rota vem de `LabsRoutePaths` (eager-imported via
/// `package:feature_labs/labs_route_paths.dart`); os widgets das
/// pages vivem atras do prefix `labs.` deferido.
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
          path: LabsRoutePaths.index,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredLabs(
              builder: () => labs.LabsPage(
                githubUrl: AppConfig.githubRepoUrl,
                onOpenGithub: _openExternalUrl,
              ),
            ),
          ),
        ),
        GoRoute(
          path: LabsRoutePaths.particles,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredLabs(
              builder: () => labs.ParticleFieldPlayground(),
            ),
          ),
        ),
        GoRoute(
          path: LabsRoutePaths.timeline,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredLabs(
              builder: () => labs.AnimatedTimelinePlayground(),
            ),
          ),
        ),
        GoRoute(
          path: LabsRoutePaths.border,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredLabs(
              builder: () => labs.AnimatedBorderPlayground(),
            ),
          ),
        ),
        GoRoute(
          path: LabsRoutePaths.spinner,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredLabs(
              builder: () => labs.LoadingSpinnerPlayground(),
            ),
          ),
        ),
        GoRoute(
          path: LabsRoutePaths.morphing,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredLabs(
              builder: () => labs.MorphingShapePlayground(),
            ),
          ),
        ),
        GoRoute(
          path: LabsRoutePaths.ripple,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredLabs(
              builder: () => labs.RippleHoverPlayground(),
            ),
          ),
        ),
        GoRoute(
          path: LabsRoutePaths.wave,
          pageBuilder: (_, _) => NoTransitionPage(
            child: _DeferredLabs(
              builder: () => labs.WaveDividerPlayground(),
            ),
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

/// Abre uma URL externa no navegador/app padrao do SO. Usado pelo
/// `LabsPage` ao tap do botao de GitHub. Falha silenciosa quando o
/// parse da URI nao bate — sem dialog de erro pra nao poluir UX por
/// uma feature de side-channel.
void _openExternalUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
}

/// Wrapper que dispara `loadLibrary()` no primeiro build. Em VM (testes)
/// `loadLibrary` resolve imediatamente; em web ele aguarda o download
/// do bundle deferido. O [builder] so e invocado apos o future resolver,
/// entao referenciar simbolos `labs.X` la dentro e seguro.
class _DeferredLabs extends StatefulWidget {
  const _DeferredLabs({required this.builder});

  final Widget Function() builder;

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
        return widget.builder();
      },
    );
  }
}
