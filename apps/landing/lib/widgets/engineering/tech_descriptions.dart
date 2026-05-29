// Catalogo estatico de descricoes expandidas por tecnologia. As chaves casam
// com `TechBody.techName` exposto em `cosmic_bodies.dart`; o consumidor e o
// popup acionado quando o usuario clica num corpo celeste da cena cosmica.

/// Conteudo expandido por tech, exibido no popup quando o usuario clica
/// num corpo celeste da cena cosmic.
class TechDescription {
  const TechDescription({
    required this.title,
    required this.tagline,
    required this.role,
    required this.version,
    required this.body,
    this.docsUrl,
  });

  /// Nome de exibicao (ex.: "Flutter").
  final String title;

  /// Sub-headline curta no popup.
  final String tagline;

  /// Categoria/papel curto (ex.: "Framework base").
  final String role;

  /// Restricao de versao (ex.: ">=3.38").
  final String version;

  /// Paragrafo longo, 3-5 linhas, explicando o porque desta tech no projeto
  /// e qual problema ela resolve.
  final String body;

  /// URL opcional pra documentacao oficial.
  final String? docsUrl;
}

abstract final class TechDescriptionsCatalog {
  static const Map<String, TechDescription> byName = <String, TechDescription>{
    'Flutter': TechDescription(
      title: 'Flutter',
      tagline: 'Framework base da landing, Material 3 dark-only.',
      role: 'Framework',
      version: '>=3.38',
      body:
          'Sustenta toda a landing como app multiplataforma — o mesmo codigo '
          'roda como mobile, PWA e desktop. Material 3 em dark-only define a '
          'base visual, com tokens proprios sobrescrevendo as cores semanticas '
          'do scheme. Compilado com renderer WASM por padrao, garantindo '
          'performance consistente entre as plataformas suportadas.',
      docsUrl: 'https://docs.flutter.dev',
    ),
    'Dart': TechDescription(
      title: 'Dart',
      tagline: 'SDK com null safety, records e pattern matching.',
      role: 'Framework',
      version: '>=3.10.0 <4.0.0',
      body:
          'SDK 3.10+ com null safety, records e pattern matching habilitam '
          'modelagem expressiva sem boilerplate. Tipos solidos atravessam '
          'todas as camadas — entities, blocs, repositories — sem `dynamic` '
          'no caminho critico. Equatable cobre value objects sem precisar de '
          'codegen, mantendo o monorepo livre de `build_runner`.',
      docsUrl: 'https://dart.dev',
    ),
    'Riverpod': TechDescription(
      title: 'Riverpod',
      tagline: 'Estado reativo com code generation e compile-time safety.',
      role: 'Estado',
      version: '2.x',
      body:
          'Alternativa reativa ao InheritedWidget com providers tipados e '
          'compile-time safety. Elimina contexto de BuildContext para acesso '
          'a estado, facilitando testes e composicao. Code generation via '
          'riverpod_generator reduz boilerplate e garante consistencia. '
          'Utilizado em projetos que exigem granularidade fina de rebuild '
          'e cache automatico de estado derivado.',
      docsUrl: 'https://riverpod.dev',
    ),
    'flutter_bloc': TechDescription(
      title: 'flutter_bloc',
      tagline: 'Estado por feature, sem store global.',
      role: 'Estado',
      version: '^9.1.1',
      body:
          'Estado por feature via Bloc + Cubit, escolhido pelo tipo do fluxo. '
          'Fluxos com eventos (forms, demos do showcase, orquestracao de '
          'animacoes) usam Bloc; estado simples (theme toggle, scroll, '
          'navegacao) usa Cubit. Sem global store — cada feature recebe sua '
          'configuracao via construtor e expoe widgets prontos pelo barrel.',
      docsUrl: 'https://bloclibrary.dev',
    ),
    'go_router': TechDescription(
      title: 'go_router',
      tagline: 'Routing declarativo com deferred loading.',
      role: 'Rotas',
      version: '^16.2.4',
      body:
          'Routing declarativo com `/labs` e suas sub-rotas carregadas como '
          'bundle separado on-demand via `deferred as labs`. A primeira pintura '
          'da home nao paga o custo dos sete playgrounds — o widget bundle so '
          'materializa quando o usuario navega ate `/labs`. O `errorBuilder` '
          'cobre 404 sem rota nominal extra.',
      docsUrl: 'https://pub.dev/packages/go_router',
    ),
    'CustomPainter': TechDescription(
      title: 'CustomPainter',
      tagline: 'Renderizacao 2D de baixo nivel no Canvas.',
      role: 'Graficos',
      version: 'Flutter API',
      body:
          'API de desenho 2D do Flutter para interfaces que ultrapassam o '
          'catalogo de widgets. Cada painter recebe o Canvas e o Size, '
          'desenhando com Path, Paint e TextPainter em 60 Hz sem alocacao '
          'no hot loop. Nesta landing, sustenta 20+ painters dedicados — '
          'mapas, plantas baixas, graficos, backdrops e relogios animados '
          'nos mocks do showcase.',
      docsUrl:
          'https://api.flutter.dev/flutter/rendering/CustomPainter-class.html',
    ),
    'Animations': TechDescription(
      title: 'Animations',
      tagline: 'Implicitas, explicitas e Tween chains.',
      role: 'Graficos',
      version: 'Flutter API',
      body:
          'Dominio completo do pipeline de animacao do Flutter: '
          'AnimatedContainer e AnimatedOpacity para transicoes implicitas, '
          'AnimationController com Tween chains para sequencias explicitas, '
          'e Ticker direto em CustomPainter via super(repaint:) para loops '
          'de 60 Hz sem rebuild. Staggered animations, curves customizadas '
          'e physics-based springs aplicados nos mocks e playgrounds.',
      docsUrl: 'https://docs.flutter.dev/ui/animations',
    ),
    'SQLite': TechDescription(
      title: 'SQLite',
      tagline: 'Banco relacional local no device.',
      role: 'Persistencia',
      version: 'sqflite',
      body:
          'Banco relacional embarcado para persistencia estruturada no '
          'device. Queries SQL tipadas via sqflite com migrations versionadas '
          'garantem integridade dos dados offline. Utilizado em apps que '
          'exigem consultas complexas, joins e indices — cenarios onde '
          'key-value stores nao oferecem a expressividade necessaria.',
      docsUrl: 'https://pub.dev/packages/sqflite',
    ),
    'Hive': TechDescription(
      title: 'Hive',
      tagline: 'Key-value store rapido, sem SQL.',
      role: 'Persistencia',
      version: '4.x',
      body:
          'Key-value store de alta performance para dados estruturados no '
          'device. Sem overhead de SQL — leitura e escrita em microsegundos '
          'com TypeAdapters tipados. Ideal para cache local, preferencias '
          'do usuario e dados de sessao que nao exigem queries relacionais. '
          'Complementa SQLite em arquiteturas que separam cache de dados '
          'persistentes.',
      docsUrl: 'https://pub.dev/packages/hive',
    ),
    'Clean Architecture': TechDescription(
      title: 'Clean Architecture',
      tagline: 'Separacao rigida data / domain / presentation.',
      role: 'Arquitetura',
      version: 'Padrao',
      body:
          'Cada feature segue o triangulo data / domain / presentation com '
          'fronteiras explicitas. Domain nao conhece Flutter, data nao conhece '
          'presentation, e o shell compoe tudo via construtor. Resultado: '
          'features substituiveis sem efeito colateral, testabilidade total '
          'por camada e onboarding rapido em qualquer modulo.',
    ),
    'SOLID': TechDescription(
      title: 'SOLID',
      tagline: 'Principios que sustentam a extensibilidade.',
      role: 'Arquitetura',
      version: 'Principios',
      body:
          'Single Responsibility, Open-Closed, Liskov Substitution, Interface '
          'Segregation e Dependency Inversion aplicados em todas as camadas. '
          'Repositories abstratos no domain, implementacoes concretas no data, '
          'Blocs que dependem de contratos — nao de implementacoes. Cada '
          'decisao de design passa por esses filtros antes de virar codigo.',
    ),
    'Monorepo': TechDescription(
      title: 'Monorepo',
      tagline: 'Pub Workspaces com Melos.',
      role: 'Arquitetura',
      version: 'Pub Workspaces',
      body:
          'Workspace Pub nativo com Melos orquestrando bootstrap, analyze, '
          'test e build em todos os pacotes. Cada pacote tem pubspec proprio, '
          'dependencias explicitas e barrel de exportacao. Mudancas atomicas '
          'que cruzam pacotes entram num unico commit sem risco de versao '
          'desalinhada entre feature e design system.',
    ),
    'Design System': TechDescription(
      title: 'Design System',
      tagline: 'Tokens, componentes e ritmo visual centralizado.',
      role: 'Arquitetura',
      version: 'Tokens',
      body:
          'Pacote design_system com tokens de cor, tipografia, spacing, '
          'breakpoints e componentes reutilizaveis (SectionHeader, EyebrowBadge, '
          'GradientText, GlowBackdrop, AppButton). Garante consistencia visual '
          'entre features sem duplicacao — qualquer mudanca de token propaga '
          'automaticamente para toda a landing.',
    ),
    'SDUI': TechDescription(
      title: 'SDUI',
      tagline: 'Interface dirigida por contrato remoto.',
      role: 'Arquitetura',
      version: 'Server-Driven',
      body:
          'Server-Driven UI permite atualizar layouts, ordem de secoes e '
          'conteudo sem publicar nova versao do app. O front end consome '
          'contratos JSON que descrevem a arvore de componentes, e o '
          'design system resolve cada nodo no widget correspondente. '
          'Reduz ciclo de deploy e desacopla produto de engenharia.',
    ),
    'Feature-First': TechDescription(
      title: 'Feature-First',
      tagline: 'Modulos por dominio, sem dependencia cruzada.',
      role: 'Arquitetura',
      version: 'Organizacao',
      body:
          'Organizacao por feature — cada dominio vive em pacote isolado '
          'com sua propria arvore data/domain/presentation. Features nao '
          'importam entre si; comunicacao acontece pelo shell via composicao '
          'direta. Adicionar ou remover uma feature nao quebra as demais. '
          'Hierarquia rigida: core → design_system → animations → feature_*.',
    ),
    'very_good_analysis': TechDescription(
      title: 'very_good_analysis',
      tagline: 'Lints estritos failFast no CI.',
      role: 'Qualidade',
      version: '^10.0.0',
      body:
          'Conjunto estrito de lints rodando failFast no pipeline de '
          'analise estatica. Mantem o codigo limpo sem PR review repetitivo — '
          'estilo, imutabilidade e ordering ja vem cobertos pela regra. O CI '
          'quebra antes de qualquer review humano enxergar o diff, entao '
          'inconsistencia nao chega ate o reviewer.',
      docsUrl: 'https://pub.dev/packages/very_good_analysis',
    ),
    'bloc_test': TechDescription(
      title: 'bloc_test',
      tagline: 'Harness oficial pra testar blocs.',
      role: 'Qualidade',
      version: '^10.0.0',
      body:
          'Harness oficial pra testar blocs sem mock manual de dependencia. '
          'Cada Bloc/Cubit nasce com seus testes na mesma sessao — politica do '
          'projeto, nao opcional. A API `blocTest` deixa explicito o `seed`, '
          'os eventos disparados e a sequencia de states esperada, eliminando '
          'flakiness por ordering de stream.',
      docsUrl: 'https://bloclibrary.dev',
    ),
    'url_launcher': TechDescription(
      title: 'url_launcher',
      tagline: 'Deep links externos com fallback gracioso.',
      role: 'Tooling',
      version: '^6.3.1',
      body:
          'Deep links externos da landing: WhatsApp, mail, GitHub e LinkedIn. '
          'Cobre `https`, `mailto` e schemes customizados de apps moveis com '
          'um unico ponto de entrada. Fallback gracioso quando o app externo '
          'nao abre — a landing nao crasha por isso, apenas registra a '
          'tentativa e segue o fluxo.',
      docsUrl: 'https://pub.dev/packages/url_launcher',
    ),
    'Skwasm': TechDescription(
      title: 'Skwasm',
      tagline: 'Renderer WASM com fallback CanvasKit.',
      role: 'Web',
      version: 'Flutter web default',
      body:
          'Renderer WASM com fallback CanvasKit em navegadores sem suporte. '
          'O build da landing sempre roda com `--wasm`, entregando performance '
          'Canvas-like sem o peso do bundle CanvasKit no first paint. '
          'Custom Painters em 60 Hz nao engasgam mesmo com varias cenas '
          'ativas simultaneamente no scroll.',
      docsUrl: 'https://docs.flutter.dev/platform-integration/web/renderers',
    ),
    'Equatable': TechDescription(
      title: 'Equatable',
      tagline: 'Equality por valor sem codegen.',
      role: 'Qualidade',
      version: '^2.0.7',
      body:
          'Equality sem codegen. Value objects do dominio comparam por valor '
          'sem `==` manual nem `freezed`/`build_runner` puxado pro monorepo. '
          'Cada entity sobrescreve `props` declarando os campos relevantes e '
          'pronto — `Equatable` cuida de `==` e `hashCode`. Mantem o ciclo de '
          'build curto, sem etapa de geracao de codigo.',
      docsUrl: 'https://pub.dev/packages/equatable',
    ),
    'Fastlane': TechDescription(
      title: 'Fastlane',
      tagline: 'Automacao de build, sign e deploy mobile.',
      role: 'Tooling',
      version: 'CI/CD',
      body:
          'Automacao de build, code signing e deploy para iOS e Android. '
          'Lanes configuradas por ambiente (dev, staging, prod) eliminam '
          'passos manuais no ciclo de release — do bump de versao ao upload '
          'na App Store e Google Play. Integrado com GitHub Actions para '
          'pipeline completo de CI/CD mobile sem intervencao humana.',
      docsUrl: 'https://fastlane.tools',
    ),
    'GitHub Actions': TechDescription(
      title: 'GitHub Actions',
      tagline: 'Pipeline CI: analyze + test + build web.',
      role: 'Tooling',
      version: 'Workflow YAML',
      body:
          'Pipeline CI: analyze + test + build web disparado em qualquer push, '
          'orquestrado via Melos no workspace. O workflow roda em qualquer '
          'branch, dando feedback antes do PR sair — quebra de analise ou '
          'teste vira sinal vermelho imediato. Mantem a confianca no `main` '
          'sem depender de disciplina manual.',
      docsUrl: 'https://docs.github.com/actions',
    ),
  };
}
