import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing/router/route_paths.dart';

/// Caida de URLs invalidas. Mantem o usuario dentro do app — sem deep
/// link errado faz o crawler pensar que o site quebrou.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key = const Key('not-found-page')});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('404', style: textTheme.displayMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Página não encontrada.',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Voltar para a home',
                  onPressed: () => context.go(RoutePaths.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
