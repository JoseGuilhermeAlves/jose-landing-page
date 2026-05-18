# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Fonte de verdade

`PROJECT.md` na raiz é a especificação canônica. **Releia antes de qualquer decisão estrutural** (stack, arquitetura, conteúdo, roadmap, critérios de aceite). Em conflito com este arquivo, PROJECT.md vence.

Este CLAUDE.md descreve o **estado real** do repo + regras operacionais. PROJECT.md descreve o **alvo**. Quando o estado real diverge da especificação, isso é mencionado explicitamente abaixo — não tratar a divergência como bug a corrigir sem antes confirmar com o José.

## Estado atual do repo

Workspace Pub + Melos já configurado (PROJECT.md §6 aplicado). O shell de `apps/landing` está montado e compõe a maioria das features no scroll da home. Resumo do que **existe versus o que PROJECT.md prescreve**:

- **Setup raiz:** `pubspec.yaml` workspace, `analysis_options.yaml`, `.gitignore` raiz — feitos.
- **`packages/core`:** `failures/`, `exceptions/`, `result/`, `usecase/` — feitos.
- **`packages/design_system`:** `theme/`, `tokens/` (incluindo `app_gradients.dart` — `brand`, `brandSoft`, `glow`), `typography/`, `spacing/`, `breakpoints/`, `responsive/`, `widgets/` — feitos. Primitives visuais: `EyebrowBadge` (chip uppercase com dot pulsante), `GradientText` (ShaderMask com `BlendMode.srcIn`), `SectionHeader` (eyebrow + headline com palavra-chave em gradient + subtitle), `GlowBackdrop` (radial gradient atrás do child). **Use o `SectionHeader` em qualquer seção nova** — ele é o que padroniza o ritmo visual da landing (Linear/Vercel/Stripe-style).
- **`packages/animations`:** **os 7 painters** prescritos pelo PROJECT.md §5 (mais um) estão presentes: `ParticleFieldPainter`, `AnimatedTimelinePainter`, `LoadingSpinnerPainter`, `AnimatedBorderPainter`, `MorphingShapePainter`, `RippleHoverPainter`, `WaveDividerPainter`. Os três últimos foram criados sem widget wrapper — quem consome (hero, dividers, hover de cards, playgrounds em `feature_labs`) instancia o `CustomPaint` direto, alimentando `progress`/`phase` com `AnimationController`. Se algum repetir muito, vale extrair um wrapper como o `LoadingSpinner`.
- **`apps/landing` shell:** `main.dart` → `bootstrap()` (com `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.onError`) → `LandingApp` (MaterialApp.router, dark-only por enquanto). Router em `lib/router/app_router.dart`, paths em `lib/router/route_paths.dart`.
- **`feature_hero`, `feature_services`, `feature_about`, `feature_contact`:** plugados na `HomePage` (`apps/landing/lib/features/home_page.dart`).
- **`feature_showcase`:** plugado na home com **os 5 templates canônicos** (e-commerce, delivery, scheduling, fitness, imobiliária). **Cada mock é uma experiência com identidade visual própria** (marca fictícia + paleta dedicada via `Theme` override + tipografia com nuance) e **múltiplas telas navegáveis** (3–5 cada) — não esboços de uma tela só. Cada um tem `Bloc` próprio com dados estáticos em `data/`; sem backend real. **Pulso** (fitness, paleta cream/laranja light — ver `fitness_brand.dart`) é o template canônico; replicar o padrão ao introduzir marca nos demais. Tap em qualquer card abre o demo em `MaterialPageRoute(fullscreenDialog: true)`. **Estado real (2026-05-15):**
  - **Pulso (fitness)** completo — home dashboard + 3 abas (Hoje/Semana/Progresso) + push pra `ExerciseDetailPage` + rest timer sheet + 7 painters dedicados (`PulsoAthleteFigure`, `PulsoActivityRings`, `PulsoBodyDiagram`, `PulsoHeroBackdrop`, `VolumeHistoryChart`, `ExerciseLoadHistoryChart`, anel privado do rest timer).
  - **Garoa (e-commerce)** completo — café-livraria com paleta café-escuro/creme/musgo (ver `garoa_brand.dart`), display headlines em serif (`fontFamily: 'serif'`, sem dep externa), body em sans. Cinco telas navegáveis empurradas via `Navigator.push` com `garoaWithDemoBloc` reinjetando o `CartBloc` em cada rota: `GaroaHomePage` (hero da marca + categorias + featured) → `GaroaCatalogPage` (grid + filtro por categoria + sort por preço) → `GaroaProductDetailPage` (galeria de 3 ângulos + variantes + stepper de qty + add) → `GaroaCartSheet` (modal com checkout) → `GaroaOrderSummaryPage` (badge animado + breakdown + endereço mock + ETA). Três painters dedicados: `GaroaHeroBackdrop` (grãos flutuando + plumas de vapor), `GaroaProductIllustration` (silhuetas por categoria — saquinho de café, caneca, caderno, livro) e `GaroaCategoryIcon` (glifos pros chips de categoria). Checkout via `CartCheckoutRequested` no `CartBloc` gera `OrderSummary` com regra de frete grátis acima de R$ 150,00 e número sequencial `GAR-XXXX`. Catálogo curado em torno de café/livraria/papelaria/objetos de mesa (`ProductsCatalog`).
  - **Aurora (delivery)** completo — marketplace de hortifruti/empório com paleta verde/creme/ocre (ver `aurora_brand.dart`), display em serif, body em sans. Quatro telas navegáveis: `AuroraHomePage` (hero + card de pedido ativo com mini-mapa + strip de categorias + lista de bancas em destaque) → `AuroraStoreListPage` (lista filtrável por categoria via chips) → `AuroraOrderDetailPage` (mapa animado de altura cheia + timeline vertical com check progressivo + itens + totais) → `AuroraHistoryPage` (pedidos delivered com card por id). Painters dedicados em `lib/src/presentation/delivery/`: `AuroraDeliveryMap` (mapa abstrato com quarteirões + rota Bezier + courier em transito via `PathMetrics.getTangentForOffset` — **destaque técnico do mock**, painter recebe controller direto em `super(repaint:)`), `AuroraStatusTimeline` (timeline vertical com `_StepDotPainter`), `AuroraProductIllustration` (silhuetas por `MarketCategory` — maçã, folha, pão, queijo, pote), `AuroraCategoryIcon` (glifos pros chips), `AuroraHeroBackdrop` (ondulações verdes + folhas flutuantes). `DeliveryBloc` mantém a máquina round-robin existente; `DeliveryState` ganha getters `activeOrder`, `historyOrders` e `findById`. Catálogos `AuroraVendorsCatalog` (6 bancas — banca de hortifruti, padaria, queijaria, empório, feira itinerante, padoca) + `AuroraItemsCatalog` (14 itens vinculados aos vendors). `DeliveryOrder` foi estendido aditivamente com `vendorId`, `lineItems`, `totalCents`, `addressLine`, `placedAtLabel` (todos opcionais — testes legados continuam passando).
  - **Vitral (agendamento)** completo — estúdio de serviços técnicos por hora (consultoria, fotografia, design, marketing) com paleta indigo/pão/cinza (ver `vitral_brand.dart`), display em sans bold, body em sans, **monospace pontual nos timestamps e códigos via `VitralBrand.monoFontFamily`** (fontFamily inline, sem dep externa). Quatro telas navegáveis empurradas com `vitralWithDemoBloc`: `VitralHomePage` (hero com **relógio analógico animado real** + card de próximo agendamento + strip de categorias + lista de profissionais com avatar monograma) → `VitralServiceListPage` (catálogo filtrável por categoria) → `VitralCalendarPage` (header do serviço + strip de 14 dias + grid de slots em mono, com seleção em estado local + CTA Continuar que dispara `SchedulingSlotBooked`) → `VitralConfirmationPage` (badge animado + breakdown completo + endereço mock + CTA que dispara `SchedulingAppointmentConfirmed` e `popUntil(isFirst)`). Painters dedicados em `lib/src/presentation/scheduling/`: `VitralClockPainter` (mostrador com ponteiros de hora/minuto fixos + ponteiro de segundos animado em 60s loop — **destaque técnico**, ticks principais e auxiliares desenhados via trig), `VitralHeroBackdrop` (grid de horas + cursor varrendo verticalmente + marcador pulsante), `VitralCategoryIllustration` (silhuetas por `ServiceCategory` — bolhas de fala, câmera, paleta com pinceladas, gráfico ascendente com seta), `VitralSpecialistAvatar` (círculo monograma desenhado via `TextPainter`), `VitralConfirmationBadge`. `SchedulingBloc` ganhou evento `SchedulingAppointmentConfirmed(Appointment)` e `SchedulingState` ganhou `confirmedAppointments: List<Appointment>` + getter `nextAppointment` (mais cedo no futuro) — tudo aditivo, testes legados intactos. `VitralConfirmationPage._orderCounter` gera id sequencial `VIT-XXXX` por sessão (com `resetOrderCounter()` pra isolar testes). Catálogos `VitralSpecialistsCatalog` (6 profissionais) + `VitralServicesCatalog` (10 serviços vinculados aos profissionais).
  - **Solar (imobiliária)** completo — imobiliária de casas/chácaras/terrenos no interior de SP, paleta terracota/musgo/creme (ver `solar_brand.dart`), display em serif. Quatro telas navegáveis empurradas com `solarWithDemoBloc`: `SolarHomePage` (hero com `SolarHeroBackdrop` — morros + sol + partículas em loop — strip de bairros derivada de `state.allProperties` e grid de destaques) → `SolarListingsPage` (filtros bairro/quartos/preço-máx + lista contada) → `SolarPropertyDetailPage` (galeria de 3 ângulos com `SolarPropertyIllustration` variando por tipo, stats, features, **`SolarFloorPlan`** com cômodos rotulados como destaque técnico em casas/chácaras/apartamentos, `SolarNeighborhoodMap` com quarteirões/parque/pin pulsante seed-determinístico, card do corretor com avatar monograma) → `SolarContactPage` (form pré-preenchido + `SolarConfirmationBadge` animado). Painters dedicados em `lib/src/presentation/realestate/`: `SolarHeroBackdrop`, `SolarPropertyIllustration` (silhuetas por `PropertyType` — casa/chácara/terreno/apartamento), `SolarFloorPlan` (planta esquemática com cômodos por tipo de imóvel), `SolarNeighborhoodMap` (mapa abstrato com seed por id), `SolarFeatureIcon` (glifos pros `PropertyFeature`), `SolarBrokerAvatar` (monograma via `TextPainter`), `SolarConfirmationBadge`. `RealEstateBloc` ganhou eventos `RealEstateFavoriteToggled` e `RealEstateContactSent` (aditivos) — `RealEstateState` ganhou `favoriteIds`, `sentContactIds` e os filtros existentes. Catálogos: `PropertiesCatalog` (10 imóveis curados) + `SolarBrokersCatalog` (3 corretores). **Nota de teste:** `pumpAndSettle()` trava ao navegar pra telas com painters em loop infinito (home, detalhe) — usar pumps explícitos (`pump(100ms)` + `pump(400ms)`) como nos testes do fitness.
- **`feature_labs`:** playground real, dependência de `apps/landing`. Expõe `LabsPage` (index do `/labs` com cards pros 7 playgrounds + seção de decisões arquiteturais + slot opcional de link pro GitHub) e os 7 widgets de playground (`ParticleFieldPlayground`, `AnimatedTimelinePlayground`, `AnimatedBorderPlayground`, `LoadingSpinnerPlayground`, `MorphingShapePlayground`, `RippleHoverPlayground`, `WaveDividerPlayground`), cada um com sliders/toggles ao vivo no `PlaygroundScaffold` compartilhado. As paths das sub-rotas vivem em `LabsRoutePaths` dentro do pacote.
- **Promoção do Labs na home:** `apps/landing/lib/widgets/labs_teaser_section.dart` é uma seção destacada (gradient brandSoft + border tinted + glow shadow) entre About e Contact, com eyebrow "Para devs" como gate. Mostra preview animado do `MorphingShapePainter`, lista os 7 playgrounds em chips e tem CTA grande pra `/labs`. **Diverge do PROJECT.md §4.6** ("link discreto no footer"): a decisão atual é dar destaque ao Labs como vitrine técnica. Footer mantém o link `/labs · para devs` como fallback de navegação. Os chips do teaser duplicam dados da `PlaygroundsCatalog` propositalmente — declarados localmente para não puxar o bundle deferido pra dentro do main bundle.

### Divergências da especificação que **ainda não foram adotadas**

São decisões deliberadas (ou pelo menos não revogadas). Não introduza essas dependências sem alinhar:

- **`freezed` / `freezed_annotation` / `json_serializable` / `build_runner`** — não usados. Modelos imutáveis hoje usam classes plain Dart com `Equatable`.
- **`get_it` / `injectable`** — não usados. Cada feature recebe configuração via construtor; o shell passa o que a feature precisa direto na composição da `HomePage`. Não há container DI.
- **Bloc events em `feature_about`** — `feature_about/pubspec.yaml` não traz `flutter_bloc`. About hoje é puramente declarativo.

PROJECT.md §2.3 lista esses pacotes como "principais", mas ainda não entraram. Se for puxar `freezed` ou `injectable`, faça em PR isolado e atualize a seção `gen` do `pubspec.yaml` raiz.

## Comandos

`bs` (= `melos bootstrap`) e `clean` (= `flutter clean` em todos os pacotes) são **builtins do Melos**, não scripts declarados — não os recrie no `pubspec.yaml` raiz, Melos rejeita override de builtin com `Duplicate command`.

```bash
melos bs                  # builtin — bootstrap do workspace
melos clean               # builtin — flutter clean em todos os pacotes
melos run analyze         # análise estática (very_good_analysis), failFast
melos run test            # flutter test em todos os pacotes Flutter
melos run format          # dart format em todos os pacotes
melos run gen             # build_runner build --delete-conflicting-outputs (só roda em pacotes que dependem de build_runner — hoje, nenhum)
melos run run:web         # roda apps/landing em Chrome com --wasm
melos run build:web       # build PWA de produção (--wasm --release)
```

**Rodar um teste único** (a partir do diretório do pacote alvo):

```bash
flutter test test/path/to/file_test.dart
flutter test test/path/to/file_test.dart --plain-name "nome do teste"
```

**Web build é sempre `--wasm`** (skwasm + fallback CanvasKit). Não fazer build sem essa flag.

> Nota Windows/PowerShell: o shell padrão deste ambiente é PowerShell 5.1, sem `&&` ou `||`. Para rodar dois comandos em sequência condicional, use `;` + `if ($?) { ... }`. Se passar comandos copiáveis pro José, evite `&&`. Os scripts Melos acima são interpretados pelo Melos, não pelo shell, então `cd ... && flutter ...` dentro de `run:web` funciona normalmente.

## Arquitetura — o que requer ler vários arquivos pra entender

### Hierarquia de dependências (rígida)

```
core              ← sem dependências internas
design_system    → core
animations       → core, design_system
feature_*        → core, design_system, animations (opcional)
apps/landing     → tudo
```

**Features não dependem umas das outras.** Comunicação entre features acontece pelo shell em `apps/landing` (router + composição direta). Violar isso é o erro mais fácil de cometer e o mais caro de desfazer.

### Composição na home

`apps/landing/lib/features/home_page.dart` é o ponto onde o shell decide a ordem do scroll e os parâmetros que cada feature recebe (ex.: `ContactSection` recebe `whatsappNumber`, `email`, `linkedinUrl`, `githubUrl` por construtor). Cada feature exporta widgets prontos via `package:feature_<nome>/feature_<nome>.dart`. Para acrescentar uma seção nova ao scroll, adicione um `_SectionSlot` ali.

**Pattern de seção:** todas as seções da home seguem o mesmo molde — `SectionHeader` (eyebrow chip + título com palavra-chave em gradient + subtitle), depois o conteúdo, separadas por `SectionWaveDivider` (em `apps/landing/lib/widgets/`, anima `WaveDividerPainter` em loop) e envolvidas pelo `_SectionSlot` da própria home (que adiciona `GlowBackdrop` sutil + `maxWidth: 1180` pra evitar paragraph stretch em viewport ultrawide). O Hero é especial — não usa `SectionHeader` mas tem o mesmo grammar (eyebrow + 2-line headline com gradient na linha de baixo + trust strip de stats abaixo dos CTAs).

### Camadas dentro de cada `feature_*`

Feature-First + Clean Architecture, três pastas:
- `data/` — datasources, repository impls, catálogos estáticos (ex.: `services_catalog.dart`, `domains_catalog.dart`)
- `domain/` — entities (Equatable), repository abstracts, usecases (contrato base em `core/usecase`)
- `presentation/` — Bloc/Cubit, sections, widgets

Erros sobem como subclasses da sealed `Failure` em `core/failures` (NetworkFailure, ValidationFailure, etc.). Use `Result<T>` ou Either-style de `core/result` para retornos que podem falhar — não lance exceção atravessando camadas.

### State management — quando Cubit, quando Bloc

- **Cubit** para estado simples sem fluxo de eventos: theme toggle, navegação, scroll position.
- **Bloc** para fluxos com eventos: form de contato, demos do showcase (cart, delivery, scheduling), orquestração de animações.

Toda Bloc/Cubit nasce com seu `bloc_test` na mesma sessão (PROJECT.md §15). Veja `packages/feature_contact/test/presentation/bloc/contact_bloc_test.dart` como referência.

### Routing e deferred loading

`go_router` declarativo em `apps/landing/lib/router/app_router.dart`. Rotas: `/` (HomePage), `/labs` + 7 sub-rotas (`/labs/particles`, `/labs/timeline`, `/labs/border`, `/labs/spinner`, `/labs/morphing`, `/labs/ripple`, `/labs/wave`), `/404` (NotFoundPage), com `errorBuilder` caindo em NotFoundPage também.

`/labs` e suas sub-rotas são **deferred-loaded** — o widget bundle (`feature_labs.dart`) é importado como `deferred as labs;` e um `_DeferredLabs` interno chama `labs.loadLibrary()` no primeiro build de qualquer rota dentro de `/labs`. Em VM/teste resolve imediatamente; em web vira bundle separado. Enquanto carrega, mostra `LoadingSpinner` do `package:animations`. **Preserve essa propriedade** — qualquer mudança no router que torne `/labs/*` eager-loaded mata a otimização principal de bundle.

As **constantes de rota** (`LabsRoutePaths.index`, `.particles`, ...) vivem em `package:feature_labs/labs_route_paths.dart` — uma library separada do barrel, importada *eager* pelo shell. Esse split mantém os strings de path no main bundle (necessários pra registrar rotas no `GoRouter`) sem materializar os widgets pesados antes de o usuário chegar em `/labs`. Não re-exportar `labs_route_paths.dart` do barrel `feature_labs.dart` — quebraria o split.

### Imutabilidade

Hoje: `Equatable` + classes plain Dart imutáveis. Não há codegen. Se você decidir adotar `freezed`/`json_serializable`, precisa adicionar `build_runner` ao pacote, e aí o filtro `dependsOn: build_runner` do script `gen` passa a captá-lo.

## Custom Painters — coração técnico do projeto

Os painters em `packages/animations/lib/src/painters/` são o que prova maturidade técnica. Regras invioláveis (valem para qualquer painter novo):

**Performance / hot loop (`paint()` roda 60+ Hz):**

- **Sem alocação dentro de `paint()`.** `Paint`, `Path` complexos, `TextPainter` e shaders viram campos do painter e são reusados. Se a `Path` representa geometria estática (silhueta, planta baixa, glyph), calcule uma vez no construtor e cache; só recalcule quando dimensão ou dado de entrada mudar.
- **`shouldRepaint` comparando propriedades reais.** Nunca retornar `true` direto — confronte o `oldDelegate` campo a campo. Só repintar quando o que afeta o desenho muda.
- **Hints corretos de `isComplex` / `willChange`** quando aplicável (`isComplex: true` em cenas pesadas estáticas que valem cache no raster cache; `willChange: true` em cenas que mudam todo frame, para evitar cache desperdiçado).
- **`RepaintBoundary` em volta do `CustomPaint` quando o painter anima sozinho** dentro de uma árvore que repinta por outros motivos (scroll, hover de irmãos). Cria um display list separado e isola o repaint à subárvore. Trade-off: o engine pode rasterizar e cachear a subárvore em GPU, então custa memória de textura — vale quando a subárvore é estável em relação à vizinhança barulhenta, não em tudo.
- **Throttle de eventos de mouse no web** (especialmente `ParticleFieldPainter`) — `MouseRegion.onHover` dispara por pixel; bufferize via `Ticker`/coordenada-alvo em vez de tratar cada frame de mouse como tick de animação.

**Animação:**

- **Passe o `Listenable` ao `super(repaint: ...)`** do `CustomPainter` quando o painter depende de um `AnimationController` / `ValueListenable`. Conforme as docs do Flutter, isso faz o `RenderCustomPaint` ouvir direto o `Listenable` e **pular as fases de build e layout** do pipeline a cada tick — vai direto para paint. Embrulhar o `CustomPaint` num `AnimatedBuilder` funciona, mas reconstrói o widget a cada frame; prefira o `repaint:` em loops de 60 Hz.
- **`canvas.save()` / `canvas.restore()` envolvendo cada transform** (rotação, escala, translação, `clipRect`). Sem o par, transformações vazam para o resto da cena. Em painters com muitos sub-elementos, considere `canvas.saveLayer` apenas quando precisa de blend mode isolado — `saveLayer` é caro e aloca offscreen buffer.

**Estrutura:**

- **Modularize cenas complexas em vários painters pequenos**, cada um com responsabilidade clara (ex.: fundo, figura, overlay de dados). Mais fácil de testar `shouldRepaint` por escopo e de empilhar via `painter` + `foregroundPainter`.
- **`painter` vs. `foregroundPainter`** no `CustomPaint`: `painter` desenha **antes** do `child`, `foregroundPainter` **depois**. Use `painter` para fundo/backdrop e `foregroundPainter` para overlays que precisam ficar acima do conteúdo (selos, marcações, highlights).
- **Sizing relativo via `size` ou `LayoutBuilder`.** Use sempre o parâmetro `size` recebido em `paint()` como referência para coordenadas — nunca números absolutos. Quando o painter precisa reagir a constraints do pai antes de instanciar (ex.: pré-computar uma `Path` em função da largura disponível), embrulhe o `CustomPaint` num `LayoutBuilder` e passe `constraints.biggest` ao construtor.
- **Não substituir Custom Painter por Lottie nas animações de destaque.** Lottie só para vetoriais ilustrativos secundários, caso a caso.

Painters existentes seguem essas regras; replique o padrão deles ao adicionar painters novos.

**Painters específicos de um mock do showcase** (ilustrações de produto, plantas baixas, mascotes de marca, EKG-line do Pulso etc.) **vivem dentro do diretório do próprio mock em `feature_showcase`**, não em `packages/animations`. As mesmas regras de performance se aplicam. Exemplo: `packages/feature_showcase/lib/src/presentation/fitness/volume_history_chart.dart`.

### Testar widgets que usam hover/MouseRegion

Animações disparadas por `MouseRegion.onEnter` precisam de **dois pumps** depois do `gesture.moveTo`: um `pump()` para o frame que registra o evento e um `pump(Duration)` para o Ticker rodar. Sem o segundo pump o teste falha intermitentemente (ver memória `testing_mouseregion_animations`).

## Convenções de linguagem

- **UI / strings exibidas:** português brasileiro.
- **Comentários no código:** português.
- **Nomes de classes, métodos, variáveis, arquivos:** inglês.
- Nada de emoji em textos comerciais (Hero, Services, About, Contact). `/labs` pode ter tom mais técnico mas continua sem emoji.
- **Tom da copy:** formal, direto e sucinto. Sem coloquialismos ("sem enrolação", "prata-de-casa", "dor crônica"), sem "pra" no lugar de "para", sem expressões internas de dev. Pense portfólio sênior, não meme. **Exceção:** dentro dos mocks do `feature_showcase`, cada marca fictícia pode (e deve) ter personalidade própria coerente com o nicho (Pulso é informal e energético: "Bom treino, atleta"). Ver PROJECT.md §4.3 princípio 5.
- **Posicionamento canônico:** José é **front end mobile** (Flutter). Não é fullstack. Toda copy deve respeitar esse recorte — backend é integração com APIs já existentes, nunca construção. Evitar "ponta a ponta" sem qualificar (use "front end inteiro", "front end mobile inteiro", "front end Flutter inteiro").
- **Não nomear empregadores, clientes ou produtos** nas seções da landing — descrever por domínio/setor (varejo B2B, setor público, fintech, etc.). O LinkedIn carrega o registro nominal. Ver memória `copy_no_named_clients`.

## Web / PWA — não esquecer

- Loading screen customizado em `apps/landing/web/index.html` (HTML/CSS puro) que some quando `appRunner.runApp()` dispara. Sem ele o usuário vê tela branca por 2–4s no primeiro acesso.
- Meta tags SEO completas (title, description, og:image, twitter:card) e `Semantics` em headlines/CTAs — Flutter Web não indexa bem por padrão.
- Manifest PWA em `apps/landing/web/manifest.json` com ícones 192/512 + maskable, `display: standalone`.
- `robots.txt` e `sitemap.xml` já existem em `apps/landing/web/`; mantenha sincronizados quando adicionar rotas indexáveis.

## Hard NO-DOs (PROJECT.md §13)

- ❌ `melos.yaml` separado — config Melos vai dentro do `pubspec.yaml` raiz (Melos 7.3+).
- ❌ `flutter pub get` manual em cada pacote — sempre `melos bootstrap`.
- ❌ Dependência cruzada entre features.
- ❌ `setState` para fluxos não-triviais — use Cubit ou Bloc.
- ❌ Acoplar UI a classes de domain — sempre via Bloc/Cubit ou parâmetros do shell.
- ❌ Build sem `--wasm`.
- ❌ Imagens não otimizadas (use WebP + lazy load).
- ❌ Esquecer `Semantics` nos pontos-chave de acessibilidade.
- ❌ Esquecer o loading customizado no `index.html`.
- ❌ Tornar `/labs` eager-loaded.

## Commits

Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`).

## Quando perguntar antes de codar

Se uma decisão de produto ou arquitetura **não estiver clara em PROJECT.md**, pergunte ao José antes de implementar. Não assuma. Áreas tipicamente ambíguas:

- Paleta exata de cores e tokens finais do design system.
- Copy final das seções comerciais.
- Escopo dos templates restantes do showcase (fitness, imobiliária).
- Domínio final do deploy — `apps/landing/web/index.html` (`og:url`, `<link rel="canonical">`), `apps/landing/web/sitemap.xml` (`<loc>`) e `apps/landing/web/robots.txt` (`Sitemap:`) estão hoje com `https://example.invalid/` ou paths relativas como TODO. Trocar tudo por URL absoluta no momento do deploy.
- Repo URL do GitHub: `apps/landing/lib/config/app_config.dart` declara `AppConfig.githubRepoUrl = 'https://github.com/JoseGuilhermeAlves/jose-landing-page'` (chute baseado no git user). Confirme/ajuste quando o remote for criado — a `LabsPage` lê daí via `app_router.dart`.
- Adoção (ou não) de `freezed`/`get_it`/`injectable` — são prescritos por PROJECT.md mas o repo escolheu seguir sem por enquanto. Não puxar essas deps unilateralmente.
