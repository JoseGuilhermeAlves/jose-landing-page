# jose-landing-page

Landing page institucional em **Flutter Web (PWA)** que serve como vitrine
tecnica e comercial — duas leituras, uma URL: cliente leigo entende em
poucos segundos o que e oferecido e tem botao de WhatsApp a mao; cliente
tecnico chega em `/labs` e ve maturidade arquitetural, custom painters
ao vivo e o monorepo organizado.

[![Flutter](https://img.shields.io/badge/Flutter-3.38%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Melos](https://img.shields.io/badge/Melos-7.3-FE9F26)](https://melos.invertase.dev)
[![Bloc](https://img.shields.io/badge/State-flutter__bloc-7C6BFF)](https://bloclibrary.dev)
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
- A pagina principal serve cliente leigo (oferta clara, prova social,
  CTA pra WhatsApp). A rota `/labs` serve cliente tecnico (custom
  painter playgrounds com sliders ao vivo, decisoes arquiteturais).
- O conteudo concreto da landing — sections, copy, paleta — esta
  especificado em [`PROJECT.md`](PROJECT.md). Esse README e a porta
  de entrada do repo; PROJECT.md e a fonte de verdade do alvo.

## Stack

- **Flutter 3.38+ / Dart 3.10+** — versao pinada via [`.fvmrc`](.fvmrc).
- **Pub Workspaces + [Melos 7.3](https://melos.invertase.dev)** — sem
  `melos.yaml` separado; toda a config Melos vive em
  [`pubspec.yaml`](pubspec.yaml) raiz.
- **State management:** `flutter_bloc` — Cubit pra estado simples
  (toggle, scroll), Bloc pra fluxos com eventos (form de contato,
  demos do showcase, playgrounds).
- **Roteamento:** `go_router` declarativo, com `/labs/*` deferred-loaded
  (bundle separado).
- **Imutabilidade:** classes plain Dart com `Equatable`. Sem `freezed`
  / `json_serializable` / `build_runner` por enquanto.
- **DI:** **sem container.** Cada feature recebe configuracao via
  construtor; o shell em `apps/landing` compoe.
- **Erros:** `Failure` sealed em `core` (NetworkFailure, ServerFailure,
  CacheFailure, ValidationFailure, UnknownFailure) + `Result<T>`
  either-style. Exceptions ficam confinadas na borda data.
- **Lint:** `very_good_analysis`, `failFast` em todos os pacotes.
- **Testes:** `flutter_test`, `bloc_test`, `mocktail`.

## Arquitetura

Hierarquia de dependencias rigida — features **nao** dependem umas das
outras. Comunicacao entre features acontece pelo shell `apps/landing`.

```
core               <- sem dependencias internas
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
│       │   ├── app.dart        # MaterialApp.router
│       │   ├── router/         # GoRouter + paths
│       │   └── features/       # composicao das features na home
│       ├── web/                # index.html com loading screen, manifest, robots, sitemap
│       └── android/            # build Android
└── packages/
    ├── core/                   # Failure, Result<T>, UseCase, exceptions
    ├── design_system/          # tema dark, tokens, spacing, breakpoints, widgets base
    ├── animations/             # 7 Custom Painters + wrappers
    ├── feature_hero/           # hero da landing (CTA WhatsApp + particle field)
    ├── feature_services/       # grid de servicos com hover animado
    ├── feature_showcase/       # 5 templates demonstraveis (e-commerce, delivery, ...)
    ├── feature_about/          # bio + grid de dominios atuados (sem nomes nominais)
    ├── feature_contact/        # formulario com Bloc + WhatsApp pre-preenchido
    └── feature_labs/           # playground tecnico em /labs (deferred)
```

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

| Script             | Descricao                                                        |
|--------------------|------------------------------------------------------------------|
| `melos bs`         | bootstrap do workspace (builtin do Melos)                        |
| `melos run analyze`| `dart analyze` em todos os pacotes, `failFast`                   |
| `melos run test`   | `flutter test` em todos os pacotes                               |
| `melos run format` | `dart format .` em todos os pacotes                              |
| `melos run gen`    | `build_runner build` (so onde aplicavel — hoje, ninguem)         |
| `melos run run:web`| roda landing em Chrome com `--wasm`                              |
| `melos run build:web`| build PWA de producao (`--wasm --release`)                     |

Pra rodar um teste especifico (a partir do diretorio do pacote alvo):

```bash
flutter test test/path/to/file_test.dart
flutter test test/path/to/file_test.dart --plain-name "nome do teste"
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

| Decisao                                | Por que                                                                                                                                                       |
|----------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Pub Workspaces + Melos 7.3 sem `melos.yaml` | Toda config no `pubspec.yaml` raiz — Melos 7.3 rejeita override de builtins. Um lugar so pra olhar.                                                            |
| Feature-First + Clean Arch             | Features sao auto-contidas, com `data/domain/presentation` cada uma. Nao se conhecem entre si — comunicacao pelo shell.                                       |
| Bloc + Cubit (sem `freezed`/`get_it`)  | `flutter_bloc` direto, modelos com `Equatable`. Sem codegen e sem container DI por opcao explicita — escala bem com o tamanho atual; revisitar quando crescer.|
| `core` sem dependencia interna         | `Failure` sealed, `Result<T>`, `UseCase` contract. Toda feature depende; ele nao depende de ninguem. 100% testado nos contratos.                              |
| Custom Painter como coracao            | Performance critica: `Paint` cacheado em campo, `shouldRepaint` correto, hints `isComplex`/`willChange`, throttle de pointer no web.                          |
| Web build sempre `--wasm`              | skwasm + fallback CanvasKit. Loading screen em HTML/CSS puro escondendo a tela branca de 2-4s no primeiro acesso.                                             |
| `/labs/*` deferred-loaded              | Quem nao chega ate la nao paga o bundle. `LabsRoutePaths` em library separada do barrel pra que so as paths constantes subam pro main bundle.                 |

Detalhe completo em [PROJECT.md](PROJECT.md). Estado real do repo
(divergencias, regras operacionais, hard NO-DOs) em [CLAUDE.md](CLAUDE.md).

## Custom Painters

Sete painters em [`packages/animations/lib/src/painters/`](packages/animations/lib/src/painters/).
Cada um tem playground interativo em `/labs/<id>`:

| Painter                  | Onde usado na landing                          | Playground                |
|--------------------------|------------------------------------------------|---------------------------|
| `ParticleFieldPainter`   | Background do hero, reativo ao mouse           | `/labs/particles`         |
| `AnimatedTimelinePainter`| Linha temporal do About via `extractPath`      | `/labs/timeline`          |
| `AnimatedBorderPainter`  | Borda de cards de servico revelada no hover    | `/labs/border`            |
| `LoadingSpinnerPainter`  | Trocas de rota e fetches mockados              | `/labs/spinner`           |
| `MorphingShapePainter`   | Transicoes entre secoes (circulo - blob - quadrado) | `/labs/morphing`     |
| `RippleHoverPainter`     | Feedback de hover em botoes/cards              | `/labs/ripple`            |
| `WaveDividerPainter`     | Separadores entre secoes (senoide animada)     | `/labs/wave`              |

## Testes

```bash
melos run test    # flutter test em todos os pacotes
```

Cobertura por pacote (PROJECT.md §10):

- `core`: 100% nas Failures, Result e exceptions; UseCase contract
  exercitado pelas implementacoes concretas dos testes.
- Cubits/Blocs: cada um com `bloc_test` cobrindo happy path + edge
  cases.
- Domain: usecases testados com mocks dos repositories.
- `design_system`: widget tests dos componentes base.

Pra rodar com coverage em um pacote:

```bash
cd packages/core
flutter test --coverage
# coverage/lcov.info — abrir com Codecov, lcov local, ou seu reader favorito.
```

## Deploy

> URL pendente. Deploy planejado em hosting estatico (Firebase Hosting,
> Vercel ou similar). Atualizar este link e a `og:url`/`og:image` em
> [`apps/landing/web/index.html`](apps/landing/web/index.html) quando
> publicado.

## Contato

Autor: **Jose Guilherme Alves** — desenvolvedor Flutter.

- LinkedIn: <https://www.linkedin.com/in/jos%C3%A9-guilherme-alves-10a17b138/>
- E-mail: <contato.joseguilhermealves@gmail.com>

> A landing em si nao nomeia empregadores, clientes ou produtos —
> descreve atuacao por dominio/setor (varejo B2B, setor publico,
> fintech, etc.). O registro nominal mora no LinkedIn.

## Licenca

[MIT](LICENSE) — © 2026 Jose Guilherme Alves.
