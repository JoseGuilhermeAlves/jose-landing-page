import 'package:feature_tech/src/domain/arch_decision.dart';
import 'package:flutter/material.dart';

/// 7 decisoes arquiteturais "que valem ler antes de explorar o monorepo".
/// Curtas, em pt-br — quem ve esta secao ja e tecnico ou curioso. Detalhe
/// completo em PROJECT.md.
abstract final class ArchDecisionsCatalog {
  static const List<ArchDecision> all = [
    ArchDecision(
      id: 'workspace',
      title: 'Pub Workspaces + Melos 7.3',
      body:
          'Config inteira no pubspec.yaml raiz, sem melos.yaml separado. '
          'melos bs faz setup do zero; scripts unificados pra analyze, '
          'test, format e codegen.',
      icon: Icons.hub_outlined,
    ),
    ArchDecision(
      id: 'clean_arch',
      title: 'Feature-First + Clean Arch',
      body:
          'Cada feature tem data, domain e presentation. Features nao se '
          'conhecem — comunicacao acontece no shell em apps/landing.',
      icon: Icons.account_tree_outlined,
    ),
    ArchDecision(
      id: 'core',
      title: 'core sem dependencia interna',
      body:
          'Failure (sealed), Result<T>, UseCase contract. Toda feature '
          'depende dele; ele nao depende de ninguem.',
      icon: Icons.layers_outlined,
    ),
    ArchDecision(
      id: 'painters',
      title: 'Custom Painter como coracao',
      body:
          'Painters em packages/animations e nos mocks — Paint cacheado '
          'em campo, shouldRepaint correto, hints isComplex/willChange. '
          'Lottie so em ilustracoes secundarias.',
      icon: Icons.brush_outlined,
    ),
    ArchDecision(
      id: 'bloc',
      title: 'Bloc + Cubit, sem DI container',
      body:
          'Cubit pra estado simples, Bloc pra fluxos com eventos. Sem '
          'get_it ou injectable — cada feature recebe config por '
          'construtor e o shell compoe.',
      icon: Icons.alt_route_outlined,
    ),
    ArchDecision(
      id: 'wasm',
      title: 'Web build sempre --wasm',
      body:
          'skwasm com fallback CanvasKit automatico. Loading screen '
          'custom em HTML/CSS no index.html esconde a tela branca '
          'enquanto o bundle desce.',
      icon: Icons.public_outlined,
    ),
    ArchDecision(
      id: 'deferred',
      title: '/labs com deferred import',
      body:
          'Quem nao vai pra /labs nao paga o bundle do feature_labs. O '
          'GoRouter dispara loadLibrary() no primeiro build da rota.',
      icon: Icons.bolt_outlined,
    ),
  ];
}
