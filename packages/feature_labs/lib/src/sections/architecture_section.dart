import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Bloco de "decisoes arquiteturais" exibido na home do `/labs`. Curto,
/// direto, em pt-br — quem chega aqui ja e tecnico.
class ArchitectureSection extends StatelessWidget {
  const ArchitectureSection({super.key});

  static const List<_Decision> _decisions = [
    _Decision(
      title: 'Pub Workspaces + Melos 7.3',
      body:
          'Config inteira no pubspec.yaml raiz, sem melos.yaml separado. '
          'melos bs faz setup do zero; melos run analyze/test/format e '
          'gen rodam em todos os pacotes.',
    ),
    _Decision(
      title: 'Feature-First + Clean Arch',
      body:
          'Cada feature tem data/domain/presentation. Features nao se '
          'conhecem — comunicacao acontece no shell em apps/landing.',
    ),
    _Decision(
      title: 'core sem dependencia interna',
      body:
          'Failure (sealed), Result<T>, UseCase contract. Toda feature '
          'depende dele; ele nao depende de ninguem.',
    ),
    _Decision(
      title: 'Custom Painter como coracao',
      body:
          '7 painters em packages/animations — Paint cacheado em campo, '
          'shouldRepaint correto, hints isComplex/willChange. Lottie so '
          'em ilustracoes secundarias.',
    ),
    _Decision(
      title: 'Bloc + Cubit, sem DI container',
      body:
          'Cubit pra estado simples, Bloc pra fluxos com eventos. Sem '
          'get_it/injectable — cada feature recebe config por construtor '
          'e o shell compoe.',
    ),
    _Decision(
      title: 'Web build sempre --wasm',
      body:
          'skwasm + fallback CanvasKit automatico. Custom loading screen '
          'em HTML/CSS no index.html pra esconder a tela branca '
          'enquanto o bundle desce.',
    ),
    _Decision(
      title: '/labs com deferred import',
      body:
          'Quem nao vem pra ca nao paga o bundle do feature_labs. O '
          'GoRouter dispara loadLibrary() no primeiro build da rota.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Decisoes arquiteturais',
            style: textTheme.headlineSmall?.copyWith(color: colors.onSurface),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'O que vale ler antes de explorar o monorepo. PROJECT.md na '
          'raiz tem o detalhe completo.',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < _decisions.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _DecisionCard(decision: _decisions[i]),
        ],
      ],
    );
  }
}

class _Decision {
  const _Decision({required this.title, required this.body});
  final String title;
  final String body;
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.decision});
  final _Decision decision;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      key: const Key('architecture-decision-card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            decision.title,
            style: textTheme.titleSmall?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            decision.body,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
