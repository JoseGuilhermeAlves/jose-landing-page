import 'package:feature_tech/src/domain/stack_category.dart';
import 'package:feature_tech/src/domain/stack_item.dart';

/// Stack real do projeto (versoes alinhadas com pubspec.yaml). Cada
/// item declara a categoria que pertence — a `TechSection` agrupa por
/// categoria pra escaneamento rapido.
abstract final class StackCatalog {
  static const List<StackItem> all = [
    // Framework
    StackItem(
      name: 'Flutter',
      version: '>=3.38',
      role: 'Framework base, Material 3 dark-only',
      category: StackCategory.framework,
    ),
    StackItem(
      name: 'Dart',
      version: '>=3.10',
      role: 'SDK, null safety e records',
      category: StackCategory.framework,
    ),
    StackItem(
      name: 'Equatable',
      version: '2.0.7',
      role: 'Equality sem codegen pra value objects',
      category: StackCategory.framework,
    ),
    StackItem(
      name: 'Platform Channels',
      version: 'Flutter API',
      role: 'Ponte nativa Dart ↔ Kotlin/Swift',
      category: StackCategory.framework,
    ),

    // Estado
    StackItem(
      name: 'flutter_bloc',
      version: '9.x',
      role: 'Bloc + Cubit pros fluxos com eventos',
      category: StackCategory.state,
    ),
    StackItem(
      name: 'Provider',
      version: '6.x',
      role: 'InheritedWidget simplificado, DI leve',
      category: StackCategory.state,
    ),
    StackItem(
      name: 'Riverpod',
      version: '2.x',
      role: 'Estado reativo com code generation',
      category: StackCategory.state,
    ),
    StackItem(
      name: 'GetX',
      version: '4.x',
      role: 'Estado reativo, rotas e DI integrados',
      category: StackCategory.state,
    ),
    StackItem(
      name: 'MobX',
      version: '2.x',
      role: 'Observables e reactions transparentes',
      category: StackCategory.state,
    ),
    StackItem(
      name: 'bloc_test',
      version: '10.x',
      role: 'Test harness pra blocs e cubits',
      category: StackCategory.quality,
    ),

    // Rotas
    StackItem(
      name: 'go_router',
      version: '16.2.4',
      role: 'Routing declarativo com deferred loading',
      category: StackCategory.routing,
    ),
    StackItem(
      name: 'flutter_modular',
      version: '6.x',
      role: 'DI + rotas modulares por feature',
      category: StackCategory.routing,
    ),

    // Graficos
    StackItem(
      name: 'CustomPainter',
      version: 'Flutter API',
      role: 'Renderizacao 2D de baixo nivel no Canvas',
      category: StackCategory.graphics,
    ),
    StackItem(
      name: 'Animations',
      version: 'Flutter API',
      role: 'Implicitas, explicitas e Tween chains',
      category: StackCategory.graphics,
    ),

    // Rede
    StackItem(
      name: 'Dio',
      version: '5.x',
      role: 'HTTP client com interceptors e cancel tokens',
      category: StackCategory.networking,
    ),
    StackItem(
      name: 'http',
      version: '1.x',
      role: 'HTTP client leve do Dart team',
      category: StackCategory.networking,
    ),

    // Persistencia
    StackItem(
      name: 'SQLite',
      version: 'sqflite',
      role: 'Banco relacional local no device',
      category: StackCategory.persistence,
    ),
    StackItem(
      name: 'Hive',
      version: '4.x',
      role: 'Key-value store rapido, sem SQL',
      category: StackCategory.persistence,
    ),
    StackItem(
      name: 'shared_preferences',
      version: '2.x',
      role: 'Key-value persistente simples por plataforma',
      category: StackCategory.persistence,
    ),
    StackItem(
      name: 'Firebase',
      version: 'FlutterFire',
      role: 'Auth, Firestore, Analytics, Push, Crashlytics',
      category: StackCategory.persistence,
    ),

    // Code Generation
    StackItem(
      name: 'freezed',
      version: '2.x',
      role: 'Unions, copyWith e serialização por codegen',
      category: StackCategory.codegen,
    ),
    StackItem(
      name: 'json_serializable',
      version: '6.x',
      role: 'Serialização JSON type-safe com codegen',
      category: StackCategory.codegen,
    ),

    // Arquitetura
    StackItem(
      name: 'Clean Architecture',
      version: 'Padrao',
      role: 'Camadas data / domain / presentation por feature',
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'MVVM',
      version: 'Padrao',
      role: 'View-ViewModel binding reativo',
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'SOLID',
      version: 'Principios',
      role: 'Inversao de dependencia e responsabilidade unica',
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'Monorepo',
      version: 'Pub Workspaces',
      role: 'Pacotes independentes com contratos explicitos',
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'get_it',
      version: '8.x',
      role: 'Service locator para inversao de dependencia',
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'injectable',
      version: '2.x',
      role: 'DI por anotações com codegen sobre get_it',
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'Design System',
      version: 'Tokens',
      role: 'Cores, tipografia, spacing e componentes reutilizáveis',
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'SDUI',
      version: 'Server-Driven',
      role: 'UI dirigida por contrato remoto, sem deploy',
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'Feature-First',
      version: 'Organizacao',
      role: 'Modulos isolados por dominio, sem dependencia cruzada',
      category: StackCategory.architecture,
    ),

    // Qualidade
    StackItem(
      name: 'very_good_analysis',
      version: '6.0.0',
      role: 'Lints estritos com failFast no CI',
      category: StackCategory.quality,
    ),
    StackItem(
      name: 'flutter_test',
      version: 'SDK',
      role: 'Widget tests por feature + bloc tests',
      category: StackCategory.quality,
    ),
    StackItem(
      name: 'mocktail',
      version: '1.x',
      role: 'Mocks sem codegen pra testes unitarios',
      category: StackCategory.quality,
    ),
    StackItem(
      name: 'integration_test',
      version: 'SDK',
      role: 'Testes E2E no device real ou emulador',
      category: StackCategory.quality,
    ),

    // Web / PWA
    StackItem(
      name: 'Skwasm',
      version: '--wasm',
      role: 'Renderer WASM, fallback CanvasKit automatico',
      category: StackCategory.web,
    ),
    StackItem(
      name: 'PWA',
      version: 'manifest + sitemap',
      role: 'Instalavel, indexavel, com loading custom',
      category: StackCategory.web,
    ),
    StackItem(
      name: 'url_launcher',
      version: '6.3.0',
      role: 'Deep links externos (WhatsApp, mail, GitHub)',
      category: StackCategory.web,
    ),

    // Tooling
    StackItem(
      name: 'Melos',
      version: '7.3.0',
      role: 'Orquestrador do monorepo Pub Workspaces',
      category: StackCategory.tooling,
    ),
    StackItem(
      name: 'GitHub Actions',
      version: 'CI',
      role: 'Pipelines de analyze, test e build web',
      category: StackCategory.tooling,
    ),
    StackItem(
      name: 'Fastlane',
      version: 'CI/CD',
      role: 'Automacao de build, sign e deploy mobile',
      category: StackCategory.tooling,
    ),
  ];

  /// Itens agrupados por categoria, preservando a ordem original.
  static Map<StackCategory, List<StackItem>> get byCategory {
    final map = <StackCategory, List<StackItem>>{};
    for (final category in StackCategory.values) {
      map[category] = all.where((i) => i.category == category).toList();
    }
    return map;
  }
}
