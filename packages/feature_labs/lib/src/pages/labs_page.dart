import 'package:design_system/design_system.dart';
import 'package:feature_labs/src/data/playgrounds_catalog.dart';
import 'package:feature_labs/src/domain/playground_descriptor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home do `/labs`. Vitrine interativa pura dos Custom Painters — cada
/// card abre uma sub-rota com sliders ao vivo. Decisoes arquiteturais
/// e tech stack moraram aqui ate maio/2026; agora vivem na secao
/// "Arquitetura & Stack" da landing (feature_tech).
class LabsPage extends StatelessWidget {
  const LabsPage({super.key = const Key('labs-page')});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          key: const Key('labs-back-button'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar para a home',
          onPressed: () => context.go('/'),
        ),
        title: Text('Labs', style: textTheme.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Playground tecnico',
                  style: textTheme.headlineLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sete Custom Painters do projeto, com sliders ao vivo. '
                'Cada um vive em rota propria; todo o `/labs` e '
                'deferred-loaded — quem nao chega aqui nao paga o bundle.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _PlaygroundsGrid(playgrounds: PlaygroundsCatalog.all),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaygroundsGrid extends StatelessWidget {
  const _PlaygroundsGrid({required this.playgrounds});
  final List<PlaygroundDescriptor> playgrounds;

  int _columnsFor(Breakpoint bp) => switch (bp) {
    Breakpoint.mobile => 1,
    Breakpoint.tablet => 2,
    Breakpoint.desktop || Breakpoint.wide => 3,
  };

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(context.breakpoint);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.md;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final p in playgrounds)
              SizedBox(
                width: cardWidth,
                child: _PlaygroundCard(descriptor: p),
              ),
          ],
        );
      },
    );
  }
}

class _PlaygroundCard extends StatelessWidget {
  const _PlaygroundCard({required this.descriptor});
  final PlaygroundDescriptor descriptor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: descriptor.label,
      onTap: () => context.go(descriptor.routePath),
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: Key('labs-card-${descriptor.id}'),
          onTap: () => context.go(descriptor.routePath),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(descriptor.icon, color: colors.primary, size: 22),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  descriptor.label,
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  descriptor.painterName,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  descriptor.shortDescription,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Text(
                      'Abrir playground',
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.arrow_forward, size: 14, color: colors.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
