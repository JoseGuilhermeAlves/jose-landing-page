// Catalogo estatico de descricoes expandidas por tecnologia. As chaves casam
// com `TechBody.techName` exposto em `cosmic_bodies.dart`; o consumidor e o
// popup acionado quando o usuário clica num corpo celeste da cena cosmica.

/// Conteudo expandido por tech, exibido no popup quando o usuário clica
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

  /// Restricao de versão (ex.: ">=3.38").
  final String version;

  /// Paragrafo longo, 3-5 linhas, explicando o porque desta tech no projeto
  /// e qual problema ela resolve.
  final String body;

  /// URL opcional pra documentação oficial.
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
          'Sustenta toda a landing como app multiplataforma — o mesmo código '
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
          'no caminho critico, mantendo o monorepo livre de `build_runner` e '
          'de etapas de codegen.',
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
          'a estado, facilitando testes e composição. Code generation via '
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
      tagline: 'Routing declarativo e enxuto.',
      role: 'Rotas',
      version: '^16.2.4',
      body:
          'Routing declarativo com configuracao centralizada num unico '
          'arquivo. O router da landing e deliberadamente enxuto — rota raiz '
          'e pagina 404 — porque toda a narrativa vive no scroll da home. '
          'O `errorBuilder` cobre qualquer path desconhecido caindo na '
          'NotFoundPage, sem rota nominal extra.',
      docsUrl: 'https://pub.dev/packages/go_router',
    ),
    'flutter_modular': TechDescription(
      title: 'flutter_modular',
      tagline: 'Injeção de dependência e rotas modulares por feature.',
      role: 'Rotas',
      version: '^6.0.0',
      body:
          'Framework que agrupa rotas e bindings de dependência em módulos '
          'isolados por feature. Injeção de dependência por escopo garante '
          'que repositórios e blocs vivam apenas enquanto o módulo está '
          'ativo, liberando recursos ao sair. Alternativa ao par '
          'go_router + get_it em projetos que preferem convenção única '
          'para navegação e DI.',
      docsUrl: 'https://pub.dev/packages/flutter_modular',
    ),
    'CustomPainter': TechDescription(
      title: 'CustomPainter',
      tagline: 'Renderização 2D de baixo nivel no Canvas.',
      role: 'Gráficos',
      version: 'Flutter API',
      body:
          'API de desenho 2D do Flutter para interfaces que ultrapassam o '
          'catalogo de widgets. Cada painter recebe o Canvas e o Size, '
          'desenhando com Path, Paint e TextPainter em 60 Hz sem alocação '
          'no hot loop. Nesta landing, sustenta 20+ painters dedicados — '
          'mapas, plantas baixas, gráficos, backdrops e relógios animados '
          'nos mocks do showcase.',
      docsUrl:
          'https://api.flutter.dev/flutter/rendering/CustomPainter-class.html',
    ),
    'Animations': TechDescription(
      title: 'Animations',
      tagline: 'Implicitas, explícitas e Tween chains.',
      role: 'Gráficos',
      version: 'Flutter API',
      body:
          'Dominio completo do pipeline de animacao do Flutter: '
          'AnimatedContainer e AnimatedOpacity para transicoes implicitas, '
          'AnimationController com Tween chains para sequências explícitas, '
          'e Ticker direto em CustomPainter via super(repaint:) para loops '
          'de 60 Hz sem rebuild. Staggered animations, curves customizadas '
          'e physics-based springs aplicados nos mocks do showcase e nas '
          'cenas da própria landing.',
      docsUrl: 'https://docs.flutter.dev/ui/animations',
    ),
    'SQLite': TechDescription(
      title: 'SQLite',
      tagline: 'Banco relacional local no device.',
      role: 'Persistência',
      version: 'sqflite',
      body:
          'Banco relacional embarcado para persistencia estruturada no '
          'device. Queries SQL tipadas via sqflite com migrations versionadas '
          'garantem integridade dos dados offline. Utilizado em apps que '
          'exigem consultas complexas, joins e indices — cenarios onde '
          'key-value stores não oferecem a expressividade necessária.',
      docsUrl: 'https://pub.dev/packages/sqflite',
    ),
    'Hive': TechDescription(
      title: 'Hive',
      tagline: 'Key-value store rapido, sem SQL.',
      role: 'Persistência',
      version: '4.x',
      body:
          'Key-value store de alta performance para dados estruturados no '
          'device. Sem overhead de SQL — leitura e escrita em microsegundos '
          'com TypeAdapters tipados. Ideal para cache local, preferências '
          'do usuário e dados de sessão que não exigem queries relacionais. '
          'Complementa SQLite em arquiteturas que separam cache de dados '
          'persistentes.',
      docsUrl: 'https://pub.dev/packages/hive',
    ),
    'Clean Architecture': TechDescription(
      title: 'Clean Architecture',
      tagline: 'Separação rígida data / domain / presentation.',
      role: 'Arquitetura',
      version: 'Padrao',
      body:
          'Cada feature segue o triangulo data / domain / presentation com '
          'fronteiras explícitas. Domain não conhece Flutter, data não conhece '
          'presentation, e o shell compoe tudo via construtor. Resultado: '
          'features substituiveis sem efeito colateral, testabilidade total '
          'por camada e onboarding rapido em qualquer modulo.',
    ),
    'SOLID': TechDescription(
      title: 'SOLID',
      tagline: 'Princípios que sustentam a extensibilidade.',
      role: 'Arquitetura',
      version: 'Princípios',
      body:
          'Single Responsibility, Open-Closed, Liskov Substitution, Interface '
          'Segregation e Dependency Inversion aplicados em todas as camadas. '
          'Repositories abstratos no domain, implementações concretas no data, '
          'Blocs que dependem de contratos — não de implementações. Cada '
          'decisão de design passa por esses filtros antes de virar código.',
    ),
    'Monorepo': TechDescription(
      title: 'Monorepo',
      tagline: 'Pub Workspaces com Melos.',
      role: 'Arquitetura',
      version: 'Pub Workspaces',
      body:
          'Workspace Pub nativo com Melos orquestrando bootstrap, analyze, '
          'test e build em todos os pacotes. Cada pacote tem pubspec próprio, '
          'dependências explícitas e barrel de exportação. Mudanças atômicas '
          'que cruzam pacotes entram num único commit sem risco de versão '
          'desalinhada entre feature e design system.',
    ),
    'Design System': TechDescription(
      title: 'Design System',
      tagline: 'Tokens, componentes e ritmo visual centralizado.',
      role: 'Arquitetura',
      version: 'Tokens',
      body:
          'Pacote design_system com tokens de cor, tipografia, spacing, '
          'breakpoints e componentes reutilizáveis (SectionHeader, EyebrowBadge, '
          'GradientText, GlowBackdrop, AppButton). Garante consistencia visual '
          'entre features sem duplicacao — qualquer mudanca de token propaga '
          'automaticamente para toda a landing.',
    ),
    'SDUI': TechDescription(
      title: 'SDUI',
      tagline: 'Interface dirígida por contrato remoto.',
      role: 'Arquitetura',
      version: 'Server-Driven',
      body:
          'Server-Driven UI permite atualizar layouts, ordem de seções e '
          'conteúdo sem publicar nova versão do app. O front end consome '
          'contratos JSON que descrevem a árvore de componentes, e o '
          'design system resolve cada nodo no widget correspondente. '
          'Reduz ciclo de deploy e desacopla produto de engenharia.',
    ),
    'Feature-First': TechDescription(
      title: 'Feature-First',
      tagline: 'Modulos por dominio, sem dependência cruzada.',
      role: 'Arquitetura',
      version: 'Organização',
      body:
          'Organização por feature — cada dominio vive em pacote isolado '
          'com sua própria árvore data/domain/presentation. Features não '
          'importam entre si; comunicação acontece pelo shell via composição '
          'direta. Adicionar ou remover uma feature não quebra as demais. '
          'Hierarquia rígida: core → design_system → animations → feature_*.',
    ),
    'Datadog': TechDescription(
      title: 'Datadog',
      tagline: 'APM, logs e RUM de apps em produção.',
      role: 'Observabilidade',
      version: 'SaaS',
      body:
          'Plataforma de observabilidade que correlaciona métricas, traces e '
          'logs num único painel. O APM instrumenta o app e expõe latência, '
          'throughput e erros por transação; o Real User Monitoring (RUM) '
          'captura sessões reais — tempo de tela, crashes e jornada do '
          'usuário no mobile. Dashboards e alertas fecham o ciclo: regressão '
          'de performance ou pico de erro viram sinal antes de o usuário '
          'reclamar.',
      docsUrl: 'https://www.datadoghq.com/',
    ),
    'very_good_analysis': TechDescription(
      title: 'very_good_analysis',
      tagline: 'Lints estritos em todo o workspace.',
      role: 'Qualidade',
      version: '^10.0.0',
      body:
          'Conjunto estrito de lints aplicado a todos os pacotes do '
          'workspace via `melos run analyze` com failFast. Mantem o código '
          'limpo sem PR review repetitivo — estilo, imutabilidade e ordering '
          'ja vem cobertos pela regra, entao inconsistência é barrada antes '
          'de qualquer review humano enxergar o diff.',
      docsUrl: 'https://pub.dev/packages/very_good_analysis',
    ),
    'bloc_test': TechDescription(
      title: 'bloc_test',
      tagline: 'Harness oficial pra testar blocs.',
      role: 'Qualidade',
      version: '^10.0.0',
      body:
          'Harness oficial pra testar blocs sem mock manual de dependencia. '
          'Cada Bloc/Cubit nasce com seus testes na mesma sessão — politica do '
          'projeto, não opcional. A API `blocTest` deixa explicito o `seed`, '
          'os eventos disparados e a sequência de states esperada, eliminando '
          'flakiness por ordering de stream.',
      docsUrl: 'https://bloclibrary.dev',
    ),
    'url_launcher': TechDescription(
      title: 'url_launcher',
      tagline: 'Deep links externos com fallback gracioso.',
      role: 'Tooling',
      version: '^6.3.0',
      body:
          'Deep links externos da landing: WhatsApp, mail, GitHub e LinkedIn. '
          'Cobre `https`, `mailto` e schemes customizados de apps moveis com '
          'um unico ponto de entrada. Fallback gracioso quando o app externo '
          'não abre — a landing não crasha por isso, apenas registra a '
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
          'Custom Painters em 60 Hz não engasgam mesmo com varias cenas '
          'ativas simultaneamente no scroll.',
      docsUrl: 'https://docs.flutter.dev/platform-integration/web/renderers',
    ),
    'Fastlane': TechDescription(
      title: 'Fastlane',
      tagline: 'Automacao de build, sign e deploy mobile.',
      role: 'Tooling',
      version: 'CI/CD',
      body:
          'Automacao de build, code signing e deploy para iOS e Android. '
          'Lanes configuradas por ambiente (dev, staging, prod) eliminam '
          'passos manuais no ciclo de release — do bump de versão ao upload '
          'na App Store e Google Play. Integrado com GitHub Actions para '
          'pipeline completo de CI/CD mobile sem intervencao humana.',
      docsUrl: 'https://fastlane.tools',
    ),
    'GitHub Actions': TechDescription(
      title: 'GitHub Actions',
      tagline: 'Automacao de CI/CD via workflows YAML.',
      role: 'Tooling',
      version: 'Workflow YAML',
      body:
          'Plataforma de CI/CD integrada ao GitHub — workflows YAML disparam '
          'analyze, test e build a cada push ou pull request, com matrix de '
          'plataformas e cache de dependencias. Quebra de analise ou teste '
          'vira sinal vermelho antes de qualquer review humano, mantendo a '
          'confianca no `main` sem depender de disciplina manual.',
      docsUrl: 'https://docs.github.com/actions',
    ),
    'flutter_test': TechDescription(
      title: 'flutter_test',
      tagline: 'Widget tests e bloc tests por feature.',
      role: 'Qualidade',
      version: 'Flutter SDK',
      body:
          'Framework de testes integrado ao SDK — cada feature nasce com seus '
          'widget tests e bloc tests na mesma sessão de desenvolvimento. '
          'Cobertura por camada: unit tests validam domain e data, widget tests '
          'verificam interação e rendering, bloc tests cobrem transições de '
          'estado. Execução via Melos em todos os pacotes com failFast.',
      docsUrl: 'https://docs.flutter.dev/testing',
    ),
    'PWA': TechDescription(
      title: 'PWA',
      tagline: 'Instalável, indexável, com loading customizado.',
      role: 'Web / PWA',
      version: 'manifest + sitemap',
      body:
          'Progressive Web App com manifest completo (ícones 192/512 + maskable), '
          'loading screen customizado em HTML/CSS puro que elimina a tela branca '
          'de 2-4s no primeiro acesso, sitemap.xml e robots.txt para indexação. '
          'Display standalone transforma o browser em shell nativo — o usuário '
          'instala e abre como app sem perceber que é web.',
    ),
    'Melos': TechDescription(
      title: 'Melos',
      tagline: 'Orquestrador do monorepo Pub Workspaces.',
      role: 'Tooling',
      version: '7.3.0',
      body:
          'Orquestra bootstrap, análise, testes e build em todos os pacotes do '
          'workspace com um único comando. Resolve dependências locais via path '
          'sem publicar no pub.dev, executa scripts em paralelo com concurrency '
          'configurável e filtra pacotes por dependência (ex.: rodar codegen só '
          'em pacotes que usam build_runner). Substitui scripts shell frágeis '
          'por configuração declarativa no pubspec.yaml raiz.',
      docsUrl: 'https://melos.invertase.dev',
    ),
    'Provider': TechDescription(
      title: 'Provider',
      tagline: 'InheritedWidget simplificado para DI leve.',
      role: 'Estado',
      version: '^6.0.0',
      body:
          'Wrapper idiomático sobre InheritedWidget que simplifica injeção de '
          'dependência e propagação de estado pela árvore. Ideal para escopos '
          'simples onde Bloc seria excesso — configurações, temas, serviços '
          'singleton. Combina bem com ChangeNotifier para view models leves '
          'em projetos menores ou em contextos MVVM.',
      docsUrl: 'https://pub.dev/packages/provider',
    ),
    'GetX': TechDescription(
      title: 'GetX',
      tagline: 'Estado reativo, rotas e DI integrados.',
      role: 'Estado',
      version: '^4.0.0',
      body:
          'Framework all-in-one que unifica gerenciamento de estado reativo, '
          'navegação e injeção de dependência num único pacote. Observables '
          'via .obs e GetBuilder para estado sem streams. Curva de entrada '
          'rápida para MVPs e projetos com equipe enxuta — produtividade '
          'alta quando o escopo é controlado.',
      docsUrl: 'https://pub.dev/packages/get',
    ),
    'MobX': TechDescription(
      title: 'MobX',
      tagline: 'Observables e reactions transparentes.',
      role: 'Estado',
      version: '^2.0.0',
      body:
          'Estado reativo baseado em observables, actions e reactions — '
          'mudanças propagam automaticamente para os observers sem '
          'boilerplate manual de streams ou notifiers. Codegen via '
          'build_runner gera o store tipado. Encaixa bem em projetos '
          'com lógica de UI complexa e muitas dependências cruzadas '
          'entre campos de estado.',
      docsUrl: 'https://pub.dev/packages/flutter_mobx',
    ),
    'Dio': TechDescription(
      title: 'Dio',
      tagline: 'HTTP client robusto com interceptors.',
      role: 'Rede',
      version: '^5.0.0',
      body:
          'Cliente HTTP com interceptors em cadeia, cancel tokens, '
          'upload/download com progresso e transformers customizáveis. '
          'Interceptors centralizam auth token refresh, logging e retry '
          'sem poluir cada chamada. FormData nativo para multipart. '
          'Padrão de mercado para apps Flutter com integração REST '
          'não trivial.',
      docsUrl: 'https://pub.dev/packages/dio',
    ),
    'http': TechDescription(
      title: 'http',
      tagline: 'HTTP client leve do Dart team.',
      role: 'Rede',
      version: '^1.0.0',
      body:
          'Cliente HTTP minimalista mantido pelo Dart team — sem '
          'dependências externas, API simples baseada em futures. '
          'Suficiente para integrações REST diretas sem necessidade '
          'de interceptors ou cancel tokens. Ideal para pacotes '
          'internos que precisam de HTTP sem arrastar dependências '
          'pesadas.',
      docsUrl: 'https://pub.dev/packages/http',
    ),
    'shared_preferences': TechDescription(
      title: 'shared_preferences',
      tagline: 'Key-value persistente simples por plataforma.',
      role: 'Persistência',
      version: '^2.0.0',
      body:
          'Abstração cross-platform sobre NSUserDefaults (iOS), '
          'SharedPreferences (Android) e localStorage (web). Persiste '
          'flags, tokens e preferências do usuário com API síncrona '
          'de leitura após init. Não substitui banco de dados — é o '
          'complemento leve para estado que precisa sobreviver ao '
          'restart do app.',
      docsUrl: 'https://pub.dev/packages/shared_preferences',
    ),
    'Firebase': TechDescription(
      title: 'Firebase',
      tagline: 'Auth, Firestore, Analytics, Push, Crashlytics.',
      role: 'Persistência',
      version: 'FlutterFire',
      body:
          'Suite backend-as-a-service via plugins FlutterFire — '
          'Authentication para login social e email, Cloud Firestore '
          'para dados em tempo real, Analytics para métricas de uso, '
          'Cloud Messaging para push notifications e Crashlytics para '
          'crash reporting em produção. Integração direta sem servidor '
          'próprio.',
      docsUrl: 'https://firebase.google.com/docs/flutter/setup',
    ),
    'freezed': TechDescription(
      title: 'freezed',
      tagline: 'Unions, copyWith e serialização por codegen.',
      role: 'Code Generation',
      version: '^2.0.0',
      body:
          'Gerador de código que produz classes imutáveis com copyWith, '
          'toString, equality e pattern matching via sealed unions — '
          'tudo type-safe sem boilerplate manual. Integra com '
          'json_serializable para fromJson/toJson automáticos. '
          'Elimina centenas de linhas repetitivas em projetos com '
          'muitas entities de domínio.',
      docsUrl: 'https://pub.dev/packages/freezed',
    ),
    'json_serializable': TechDescription(
      title: 'json_serializable',
      tagline: 'Serialização JSON type-safe com codegen.',
      role: 'Code Generation',
      version: '^6.0.0',
      body:
          'Gera fromJson/toJson a partir de anotações — elimina '
          'parsing manual e erros de typo em chaves de mapa. '
          'Suporta nested objects, enums, DateTime, custom converters '
          'e null safety completo. Roda via build_runner no CI, '
          'garantindo que a serialização está sempre em sincronia com '
          'os modelos de domínio.',
      docsUrl: 'https://pub.dev/packages/json_serializable',
    ),
    'MVVM': TechDescription(
      title: 'MVVM',
      tagline: 'View-ViewModel binding reativo.',
      role: 'Arquitetura',
      version: 'Padrão',
      body:
          'Model-View-ViewModel separa lógica de apresentação da view '
          'via binding reativo — a view observa o ViewModel sem '
          'conhecer o model. Em Flutter, combina com ChangeNotifier '
          'ou streams para atualização automática. Adequado para '
          'projetos onde a camada de apresentação domina a complexidade '
          'e Clean Architecture seria excesso.',
    ),
    'get_it': TechDescription(
      title: 'get_it',
      tagline: 'Service locator para inversão de dependência.',
      role: 'Arquitetura',
      version: '^8.0.0',
      body:
          'Service locator que registra e resolve dependências sem '
          'depender da árvore de widgets — acessível de qualquer camada '
          '(domain, data, presentation). Suporta singleton, lazy '
          'singleton e factory. Leve e sem codegen, funciona como base '
          'para injectable quando o projeto escala.',
      docsUrl: 'https://pub.dev/packages/get_it',
    ),
    'injectable': TechDescription(
      title: 'injectable',
      tagline: 'DI por anotações com codegen sobre get_it.',
      role: 'Arquitetura',
      version: '^2.0.0',
      body:
          'Gerador de código que lê anotações (@injectable, @singleton, '
          '@lazySingleton) e produz o registro de dependências no get_it '
          'automaticamente. Elimina o boilerplate de registrar cada '
          'serviço manualmente e mantém o grafo de dependências '
          'verificável em tempo de compilação.',
      docsUrl: 'https://pub.dev/packages/injectable',
    ),
    'mocktail': TechDescription(
      title: 'mocktail',
      tagline: 'Mocks sem codegen para testes unitários.',
      role: 'Qualidade',
      version: '^1.0.0',
      body:
          'Framework de mocking que usa extensão de classes em vez de '
          'codegen — basta estender Mock e implementar a interface. '
          'API fluente com when/verify inspirada no Mockito, sem '
          'dependência de build_runner. Ideal para isolar repositórios '
          'e datasources nos testes de Bloc e domain.',
      docsUrl: 'https://pub.dev/packages/mocktail',
    ),
    'integration_test': TechDescription(
      title: 'integration_test',
      tagline: 'Testes E2E no device real ou emulador.',
      role: 'Qualidade',
      version: 'Flutter SDK',
      body:
          'Framework oficial para testes de integração que rodam no '
          'device real ou emulador — validam fluxos completos de '
          'navegação, interação e rendering. Complementam widget tests '
          'cobrindo o que mocks não alcançam: performance de scroll, '
          'transições de rota e integração com plugins nativos.',
      docsUrl: 'https://docs.flutter.dev/testing/integration-tests',
    ),
    'Platform Channels': TechDescription(
      title: 'Platform Channels',
      tagline: 'Ponte nativa Dart ↔ Kotlin/Swift.',
      role: 'Framework',
      version: 'Flutter API',
      body:
          'Mecanismo de comunicação entre Dart e código nativo '
          '(Kotlin/Java no Android, Swift/ObjC no iOS) via '
          'MethodChannel, EventChannel e BasicMessageChannel. '
          'Permite acessar APIs de plataforma sem plugin publicado — '
          'sensores, biometria, armazenamento seguro, Bluetooth e '
          'qualquer SDK nativo que ainda não tenha wrapper Flutter.',
      docsUrl: 'https://docs.flutter.dev/platform-integration/'
          'platform-channels',
    ),
  };
}
