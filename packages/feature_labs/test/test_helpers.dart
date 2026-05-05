import 'package:design_system/design_system.dart';
import 'package:feature_labs/labs_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Pump um widget dentro de um `MaterialApp.router` com:
/// - tema dark do design system;
/// - GoRouter com `/labs` apontando pra `child` e `/labs/<id>` placeholders
///   pra que `context.go(...)` em playgrounds nao expluda.
///
/// Use [path] pra forcar uma rota inicial alem de `/labs`.
Future<void> pumpLabsHarness(
  WidgetTester tester,
  Widget child, {
  String path = LabsRoutePaths.index,
}) {
  final router = GoRouter(
    initialLocation: path,
    routes: [
      GoRoute(
        path: LabsRoutePaths.index,
        builder: (_, _) => child,
      ),
      // Placeholder pra qualquer sub-rota referenciada via context.go.
      for (final p in LabsRoutePaths.playgroundPaths)
        GoRoute(
          path: p,
          builder: (_, _) => const _PlaygroundPlaceholder(),
        ),
      GoRoute(
        path: '/',
        builder: (_, _) => const _PlaygroundPlaceholder(),
      ),
    ],
  );

  return tester.pumpWidget(
    MaterialApp.router(
      theme: AppTheme.dark(),
      routerConfig: router,
    ),
  );
}

class _PlaygroundPlaceholder extends StatelessWidget {
  const _PlaygroundPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('placeholder', key: Key('test-placeholder'))),
    );
  }
}
