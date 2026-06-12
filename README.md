# jose-landing-page

Landing page institucional em **Flutter Web (PWA)** que serve como vitrine
tecnica e comercial — duas leituras, uma URL. O cliente leigo entende em
poucos segundos o que e oferecido e tem botao de WhatsApp a mao; o cliente
tecnico rola ate a secao **Engenharia** e ve maturidade
arquitetural, custom painters a 60 fps e o monorepo organizado — tudo na
propria home, sem rota separada.

[![Flutter](https://img.shields.io/badge/Flutter-3.38%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Melos](https://img.shields.io/badge/Melos-7.3-FE9F26)](https://melos.invertase.dev)
[![Bloc](https://img.shields.io/badge/State-flutter__bloc-7C6BFF)](https://bloclibrary.dev)
[![i18n](https://img.shields.io/badge/i18n-9%20idiomas-5741D8)](packages/design_system/lib/l10n)
[![Lint](https://img.shields.io/badge/lint-very__good__analysis-1FA34F)](https://pub.dev/packages/very_good_analysis)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Preview

> Screenshot pendente — capturar o hero em producao e salvar em
> `docs/preview-hero.png`. Ate la, rode `melos run run:web` pra ver
> o estado atual.

## Sobre

- Plataformas-alvo: **Android** e **Web (PWA)**. iOS, desktop e Windows
  estao fora de escopo nesta versao.
- Renderer web: build sempre com `--wasm` (skwasm + fallback CanvasKit).
- **Rota unica `/`** (mais `/404` de fallback). Toda a experiencia vive
  no scroll da home: Hero → Showcase → Sobre → Engenharia → Contato.
  (As antigas rotas `/games` e `/labs` foram removidas.)
- **Internacionalizacao:** 9 idiomas (pt como fonte; en, es, de, it, ja,
  zh, fr, ru), com seletor de locale e bandeiras desenhadas em
  `CustomPainter`.
- O conteudo concreto da landing — sections, copy, paleta — esta
  especificado em [`PROJECT.md`](PROJECT.md). Esse README e a porta
  de entrada do repo; PROJECT.md e a fonte de verdade do alvo, e
  [`CLAUDE.md`](CLAUDE.md) descreve o estado real (divergencias, regras).

## Stack

- **Flutter 3.38+ / Dart 3.10+** — versao pinada via [`.fvmrc`](.fvmrc).
- **Pub Workspaces + [Melos 7.3](https://melos.invertase.dev)** — sem
  `melos.yaml` separado; toda a config Melos vive em
  [`pubspec.yaml`](pubspec.yaml) raiz.
- **State management:** `flutter_bloc` — Cubit pra estado simples
  (toggle de locale, scroll), Bloc pra fluxos com eventos (form de
  contato, demos do showcase).
- **Roteamento:** `go_router` declarativo, rota unica `/` + `/404`,
  com `errorBuilder` caindo na `NotFoundPage`.
- **Internacionalizacao:** `flutter_localizations` + `gen-l10n`. Arquivos
  `.arb` em [`packages/design_system/lib/l10n`](packages/design_system/lib/l10n)
  (pt e o template); o codigo gerado fica em `l10n/generated/`.
- **Imutabilidade:** classes plain Dart com `Equatable`. Sem `freezed`
  / `json_serializable` / `build_runner` por enquanto.
- **DI:** **sem container.** Cada feature recebe configuracao via
  construtor; o shell em `apps/landing` compoe a home.
- **Lint:** `very_good_analysis`, `failFast` em todos os pacotes.
- **Testes:** `flutter_test`, `bloc_test`, `mocktail`.

## Arquitetura

Hierarquia de dependencias rigida — features **nao** dependem umas das
outras. Comunicacao entre features acontece pelo shell `apps/landing`.

```
core               <- shell placeholder (sem dependencias internas)
design_system      -> core
animations         -> core, design_system
feature_*          -> core, design_system, animations (opcional)
apps/landing       -> tudo
```

Cada feature segue Feature-First + Clean Architecture, com tres pastas:

```
feature_<nome>/lib/src/
├── data/           # datasources, repository impls, catalogos estaticos
├── domain/         # entities (Equatable), repositorios abstratos, usecases
└── presentation/   # Bloc/Cubit, sections, widgets
```

No `feature_showcase` a divisao e **recursiva**: cada mock e uma
sub-feature com seu proprio triangulo `data/domain/presentation` em
`lib/src/<mock>/`, e os mocks nao se importam entre si — so de
`lib/src/shared/`.

## Estrutura de pastas

```
jose-landing-page/
├── pubspec.yaml                # workspace + config Melos
├── analysis_options.yaml       # very_good_analysis compartilhado
├── PROJECT.md                  # fonte de verdade da especificacao
├── CLAUDE.md                   # estado real do repo + regras pra IA
├── .fvmrc                      # pin de versao do Flutter
├── apps/
│   └── landing/                # PWA principal — shell que compoe features
│       ├── lib/
│       │   ├── main.dart       # bootstrap (runZonedGuarded + observers)
│       │   ├── app.dart        # MaterialApp.router (dark-only)
│       │   ├── router/         # GoRouter + paths (/ e /404)
│       │   ├── features/       # composicao das features na home
│       │   └── widgets/        # engineering, nav, footer, dividers
│       ├── web/                # index.html com loading screen, manifest, robots, sitemap
│       └── android/            # build Android
└── packages/
    ├── core/                   # shell placeholder (topo da hierarquia)
    ├── design_system/          # tema dark, tokens, tipografia, breakpoints, widgets base, l10n
    ├── animations/             # 9 Custom Painters + wrappers (CosmosField, ConstellationField)
    ├── feature_hero/           # hero da landing (CTA WhatsApp + particle field + portrait)
    ├── feature_services/       # grid de servicos com hover animado
    ├── feature_showcase/       # 5 mocks navegaveis (Mira, Aurora, Vitral, Pulso, Solar)
    ├── feature_about/          # bio + constelacao interativa de dominios + "Como eu entrego"
    ├── feature_tech/           # secao Engenharia (stack + decisoes + painters em destaque)
    ├── feature_contact/        # formulario com Bloc + WhatsApp pre-preenchido
    └── feature_labs/           # legado — playground tecnico, hoje sem rota no app
```

> `feature_labs` permanece no workspace por ora, mas **nao** esta plugado
> no router — a prova tecnica migrou pra secao Engenharia na home.

## Showcase — 5 mocks navegaveis

Cada mock e uma experiencia com **identidade visual propria** (marca
ficticia + paleta dedicada) e multiplas telas navegaveis. Sem backend
real; dados estaticos em `data/`. Tap num card abre o demo em
`MaterialPageRoute(fullscreenDialog: true)`.

| Marca   | Nicho         | Destaque tecnico                                            |
|---------|---------------|------------------------------------------------------------|
| Mira    | Investimentos | Candlestick com crosshair interativo + donut de alocacao   |
| Aurora  | Delivery      | Mapa animado com courier em transito via `PathMetrics`     |
| Vitral  | Agendamento   | Relogio analogico animado + calendario interativo          |
| Pulso   | Fitness       | Recovery dashboard + logger set-a-set + rest timer no Bloc |
| Solar   | Imobiliaria   | Planta baixa esquematica + mapa de bairro seed-deterministico |

## Setup local

```bash
# Requer FVM (https://fvm.app) + Flutter na versao do .fvmrc.
fvm install
fvm flutter pub get

# Bootstrap do workspace — roda em todos os pacotes.
dart run melos bs
```

> **Nunca** rode `flutter pub get` manualmente em cada pacote. Sempre
> `melos bs`.

## Comandos

| Script               | Descricao                                                        |
|----------------------|------------------------------------------------------------------|
| `melos bs`           | bootstrap do workspace (builtin do Melos)                        |
| `melos run analyze`  | `dart analyze` em todos os pacotes, `failFast`                   |
| `melos run test`     | `flutter test` em todos os pacotes                               |
| `melos run format`   | `dart format .` em todos os pacotes                              |
| `melos run gen`      | `build_runner build` (so onde aplicavel — hoje, ninguem)         |
| `melos run run:web`  | roda landing em Chrome com `--wasm`                              |
| `melos run build:web`| build PWA de producao (`--wasm --release`)                       |

Pra rodar um teste especifico (a partir do diretorio do pacote alvo):

```bash
flutter test test/path/to/file_test.dart
flutter test test/path/to/file_test.dart --plain-name "nome do teste"
```

Pra regenerar os arquivos de localizacao apos editar um `.arb`:

```bash
cd packages/design_system
flutter gen-l10n
```

## Build PWA

```bash
melos run build:web
# build/web/ contem o bundle pronto pra deploy.
```

Build sempre com `--wasm`. Ele gera skwasm + fallback CanvasKit
automatico, alem da loading screen customizada (HTML/CSS puro em
`apps/landing/web/index.html`) que cobre o tempo de download do bundle.

Targets de performance (ver [PROJECT.md §8](PROJECT.md#8-performance-nao-negociavel-para-landing)):
First Contentful Paint < 2s, Time to Interactive < 4s em 4G simulado;
Lighthouse Performance >= 80, Accessibility >= 90, PWA >= 90.

## Decisoes arquiteturais resumidas

| Decisao                                | Por que                                                                                                                          |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| Pub Workspaces + Melos 7.3 sem `melos.yaml` | Toda config no `pubspec.yaml` raiz — Melos 7.3 rejeita override de builtins. Um lugar so pra olhar.                        |
| Feature-First + Clean Arch             | Features sao auto-contidas, com `data/domain/presentation` cada uma. Nao se conhecem entre si — comunicacao pelo shell.         |
| Bloc + Cubit (sem `freezed`/`get_it`)  | `flutter_bloc` direto, modelos com `Equatable`. Sem codegen e sem container DI por opcao explicita — revisitar quando crescer.  |
| `core` como shell placeholder          | Os primitivos `Failure`/`Result`/`UseCase` foram removidos como codigo morto (zero features importavam). A casca mantem o topo da hierarquia. |
| Custom Painter como coracao            | Performance critica: `Paint` cacheado em campo, `shouldRepaint` correto, `super(repaint:)` em loops, throttle de pointer no web.|
| Prova tecnica na propria home          | Em vez de uma rota `/labs` separada, a secao Engenharia prova maturidade no fluxo principal.                                   |
| Web build sempre `--wasm`              | skwasm + fallback CanvasKit. Loading screen em HTML/CSS puro escondendo a tela branca de 2-4s no primeiro acesso.               |

Detalhe completo em [PROJECT.md](PROJECT.md). Estado real do repo
(divergencias, regras operacionais, hard NO-DOs) em [CLAUDE.md](CLAUDE.md).

## Custom Painters

Nove painters em [`packages/animations/lib/src/painters/`](packages/animations/lib/src/painters/).
Sao a prova de maturidade tecnica do projeto: sem alocacao no hot loop,
`shouldRepaint` comparando propriedades reais, `super(repaint:)` ligado
ao `AnimationController` pra pular build/layout a cada frame.

| Painter                  | Papel na landing                                              |
|--------------------------|--------------------------------------------------------------|
| `ParticleFieldPainter`   | Campo de particulas no hero, reativo ao mouse                |
| `CosmosPainter`          | Planetas, nebulosas, galaxias e pulsares — fundo da landing  |
| `ConstellationPainter`   | Constelacoes nomeadas (Cruzeiro do Sul, Orion, Triangulo)    |
| `AnimatedBorderPainter`  | Borda de cards revelada no hover (servicos, arch, bio)       |
| `WaveDividerPainter`     | Separadores senoidais entre secoes                          |
| `AnimatedTimelinePainter`| Traco progressivo via `extractPath`                          |
| `MorphingShapePainter`   | Formas que transmutam (circulo ↔ blob ↔ quadrado)            |
| `RippleHoverPainter`     | Feedback de ripple em hover                                  |
| `LoadingSpinnerPainter`  | Spinner de loading                                           |

> Painters **especificos de um mock** (plantas baixas, mapas, ilustracoes
> de produto, EKG-line) vivem dentro do diretorio do proprio mock em
> `feature_showcase`, nao em `animations`. As mesmas regras de performance
> valem.

## Testes

```bash
melos run test    # flutter test em todos os pacotes
```

- Cada Cubit/Bloc nasce com seu `bloc_test` cobrindo happy path + edge cases.
- Cada feature tem widget tests das suas sections.
- `design_system`: widget tests dos componentes base + `LocaleCubit`.
- Os mocks do showcase tem testes de fluxo (navegacao entre telas, eventos).

Pra rodar com coverage em um pacote:

```bash
cd packages/feature_showcase
flutter test --coverage
# coverage/lcov.info — abrir com Codecov, lcov local, ou seu reader favorito.
```

## Deploy

> URL pendente. Deploy planejado em hosting estatico (Firebase Hosting,
> Vercel ou similar). Atualizar este link e a `og:url`/`og:image` em
> [`apps/landing/web/index.html`](apps/landing/web/index.html), alem de
> `robots.txt` e `sitemap.xml`, quando publicado.

## Contato

Autor: **Jose Guilherme Alves** — front end mobile (Flutter).

- LinkedIn: <https://www.linkedin.com/in/jos%C3%A9-guilherme-alves-10a17b138/>
- E-mail: <contato.joseguilhermealves@gmail.com>

> A landing em si nao nomeia empregadores, clientes ou produtos —
> descreve atuacao por dominio/setor (varejo, setor publico, campo,
> plataforma interna, servico financeiro). O registro nominal mora no
> LinkedIn.

## Licenca

[MIT](LICENSE) — © 2026 Jose Guilherme Alves.
