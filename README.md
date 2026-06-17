# jose-landing-page

Landing page de portfólio em **Flutter Web (PWA)** que serve como vitrine
técnica e comercial — duas leituras, uma URL. O visitante leigo entende em
poucos segundos o que é oferecido e tem canais de contato à mão; o
visitante técnico rola até a seção **Engenharia** e vê maturidade
arquitetural, custom painters a 60 fps e o monorepo organizado — tudo na
própria home, sem rota separada.

[![Flutter](https://img.shields.io/badge/Flutter-3.38%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Melos](https://img.shields.io/badge/Melos-7.5-FE9F26)](https://melos.invertase.dev)
[![Bloc](https://img.shields.io/badge/State-flutter__bloc-7C6BFF)](https://bloclibrary.dev)
[![i18n](https://img.shields.io/badge/i18n-9%20idiomas-5741D8)](packages/design_system/lib/l10n)
[![Lint](https://img.shields.io/badge/lint-very__good__analysis-1FA34F)](https://pub.dev/packages/very_good_analysis)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Demo

🔗 **<https://joseguilhermealves.github.io/jose-landing-page/>** — servido
via GitHub Pages a partir da branch `gh-pages`.

## Sobre

- Plataformas-alvo: **Android** e **Web (PWA)**. iOS, desktop e Windows
  estão fora de escopo nesta versão.
- Renderer web: build sempre com `--wasm` (skwasm + fallback CanvasKit).
- **Rota única `/`** (mais `/404` de fallback). Toda a experiência vive
  no scroll da home: **Hero → Showcase → Sobre → Engenharia → Contato**.
- Identidade visual **arcade / synthwave**: nome em fonte bitmap
  (`PixelText`), backdrop CRT com grid Outrun, cena cósmica com planetas e
  um boss reproduzido pixel-a-pixel — tudo em `CustomPainter`.
- **Internacionalização:** 9 idiomas (pt como fonte; en, es, de, it, ja,
  zh, fr, ru), com seletor de locale e bandeiras desenhadas em
  `CustomPainter`.

## Stack

- **Flutter 3.38+ / Dart 3.10+** — versão pinada via [`.fvmrc`](.fvmrc).
- **Pub Workspaces + [Melos 7.5](https://melos.invertase.dev)** — sem
  `melos.yaml` separado; toda a config Melos vive no
  [`pubspec.yaml`](pubspec.yaml) raiz.
- **State management:** `flutter_bloc` — Cubit para estado simples
  (toggle de locale, scroll), Bloc para fluxos com eventos (demos do
  showcase: carrinho, delivery, agendamento).
- **Roteamento:** `go_router` declarativo, rota única `/` + `/404`,
  com `errorBuilder` caindo na `NotFoundPage`.
- **Internacionalização:** `flutter_localizations` + `gen-l10n`. Arquivos
  `.arb` em [`packages/design_system/lib/l10n`](packages/design_system/lib/l10n)
  (pt é o template); o código gerado fica em `l10n/generated/`.
- **Imutabilidade:** classes plain Dart com `Equatable`. Sem `freezed`
  / `json_serializable` / `build_runner` por enquanto.
- **DI:** **sem container.** Cada feature recebe configuração via
  construtor; o shell em `apps/landing` compõe a home.
- **Lint:** `very_good_analysis`, `failFast` em todos os pacotes.
- **Testes:** `flutter_test`, `bloc_test`, `mocktail`.

## Arquitetura

Hierarquia de dependências rígida — features **não** dependem umas das
outras. Comunicação entre features acontece pelo shell `apps/landing`.

```
core               <- shell placeholder (sem dependências internas)
design_system      -> core
animations         -> core, design_system
feature_*          -> core, design_system, animations (opcional)
apps/landing       -> tudo
```

Cada feature segue Feature-First + Clean Architecture, com três pastas:

```
feature_<nome>/lib/src/
├── data/           # datasources, repository impls, catálogos estáticos
├── domain/         # entities (Equatable), repositórios abstratos, usecases
└── presentation/   # Bloc/Cubit, sections, widgets
```

No `feature_showcase` a divisão é **recursiva**: cada mock é uma
sub-feature com seu próprio triângulo `data/domain/presentation` em
`lib/src/<mock>/`, e os mocks não se importam entre si — só de
`lib/src/shared/`.

## Estrutura de pastas

```
jose-landing-page/
├── pubspec.yaml                # workspace + config Melos
├── analysis_options.yaml       # very_good_analysis compartilhado
├── .fvmrc                      # pin de versão do Flutter
├── apps/
│   └── landing/                # PWA principal — shell que compõe as features
│       ├── lib/
│       │   ├── main.dart       # bootstrap (runZonedGuarded + observers)
│       │   ├── router/         # GoRouter + paths (/ e /404)
│       │   ├── config/         # AppConfig (links, e-mail, URLs do CV)
│       │   ├── features/       # composição das features na home
│       │   └── widgets/        # chrome arcade, engineering, nav, footer, dividers
│       ├── web/                # index.html (loading screen), manifest, robots, sitemap
│       └── android/            # build Android
└── packages/
    ├── core/                   # shell placeholder (topo da hierarquia)
    ├── design_system/          # tema dark, tokens, tipografia, PixelText, breakpoints, widgets base, l10n
    ├── animations/             # 11 Custom Painters + chrome arcade (backdrop/CRT) + boss Oni
    ├── feature_hero/           # hero arcade "title screen": black hole portrait + cena cósmica + boss Oni
    ├── feature_services/       # grid de serviços com hover animado
    ├── feature_showcase/       # 3 mocks navegáveis (Mira, Aurora, Solar)
    ├── feature_about/          # bio + lista de domínios + bloco "Como eu entrego" (estilo changelog)
    ├── feature_tech/           # catálogos da seção Engenharia (stack + decisões + painters em destaque)
    ├── feature_contact/        # funil mailto + CTAs (GitHub/LinkedIn/WhatsApp) + download do CV (PT/EN)
    └── feature_labs/           # legado — playground técnico, hoje sem rota no app
```

## Showcase — 3 mocks navegáveis

Cada mock é uma experiência com **identidade visual própria** (marca
fictícia + paleta dedicada via `Theme` override) e múltiplas telas
navegáveis. Sem backend real; dados estáticos em `data/`, cada um com seu
`Bloc`. Tap num card abre o demo em `MaterialPageRoute(fullscreenDialog: true)`.

| Marca   | Nicho         | Destaque técnico                                              |
|---------|---------------|--------------------------------------------------------------|
| Mira    | Investimentos | Candlestick com crosshair interativo + donut de alocação     |
| Aurora  | Delivery      | Mapa animado com courier em trânsito via `PathMetrics`       |
| Solar   | Imobiliária   | Planta baixa esquemática + mapa de bairro seed-determinístico |

## Setup local

```bash
# Requer FVM (https://fvm.app) + Flutter na versão do .fvmrc.
fvm install
fvm flutter pub get

# Bootstrap do workspace — roda em todos os pacotes.
dart run melos bs
```

> **Nunca** rode `flutter pub get` manualmente em cada pacote. Sempre
> `melos bs`.

## Comandos

| Script               | Descrição                                                        |
|----------------------|------------------------------------------------------------------|
| `melos bs`           | bootstrap do workspace (builtin do Melos)                        |
| `melos run analyze`  | `dart analyze` em todos os pacotes, `failFast`                   |
| `melos run test`     | `flutter test` em todos os pacotes                               |
| `melos run format`   | `dart format .` em todos os pacotes                              |
| `melos run run:web`  | roda a landing em Chrome com `--wasm`                            |
| `melos run build:web`| build PWA de produção (`--wasm --release`)                       |

Para rodar um teste específico (a partir do diretório do pacote alvo):

```bash
flutter test test/path/to/file_test.dart
flutter test test/path/to/file_test.dart --plain-name "nome do teste"
```

Para regenerar os arquivos de localização após editar um `.arb`:

```bash
cd packages/design_system
flutter gen-l10n
```

## Build & Deploy (GitHub Pages)

```bash
cd apps/landing
flutter build web --wasm --release --base-href "/jose-landing-page/"
# build/web/ contém o bundle pronto pra deploy.
```

O `--base-href` é necessário porque o GitHub Pages serve o site em um
subpath (`/jose-landing-page/`). O conteúdo de `build/web/` é publicado na
branch `gh-pages` (com um `.nojekyll` na raiz). Build **sempre** com
`--wasm`: gera skwasm + fallback CanvasKit automático. Como o GitHub Pages
não envia os headers COOP/COEP que o skwasm exige, o runtime cai no
CanvasKit — esperado e transparente. Uma loading screen em HTML/CSS puro
(`apps/landing/web/index.html`) cobre o tempo de download do bundle.

## Custom Painters

Onze painters em [`packages/animations/lib/src/painters/`](packages/animations/lib/src/painters/).
São a prova de maturidade técnica do projeto: sem alocação no hot loop,
`shouldRepaint` comparando propriedades reais, `super(repaint:)` ligado
ao `AnimationController` para pular build/layout a cada frame.

| Painter                  | Papel na landing                                              |
|--------------------------|--------------------------------------------------------------|
| `ParticleFieldPainter`   | Campo de partículas reativo ao mouse                         |
| `CosmosPainter`          | Planetas, nebulosas, galáxias e pulsares — cena do hero      |
| `ConstellationPainter`   | Constelações nomeadas (Cruzeiro do Sul, Órion, Triângulo)    |
| `ArcadeBackdropPainter`  | Starfield em parallax + grid Outrun — fundo do shell arcade  |
| `CrtPainter`             | Scanlines + vinheta + flicker — moldura CRT                  |
| `AnimatedBorderPainter`  | Borda de cards revelada no hover                             |
| `WaveDividerPainter`     | Separadores senoidais entre seções                          |
| `AnimatedTimelinePainter`| Traço progressivo via `extractPath`                          |
| `MorphingShapePainter`   | Formas que transmutam (círculo ↔ blob ↔ quadrado)            |
| `RippleHoverPainter`     | Feedback de ripple em hover                                  |
| `LoadingSpinnerPainter`  | Spinner de loading                                           |

> Painters **específicos de um mock** (plantas baixas, mapas, ilustrações
> de produto) vivem dentro do diretório do próprio mock em
> `feature_showcase`, não em `animations`. As mesmas regras de performance
> valem.

> **Reprodução 1:1 de sprite raster.** O boss Oni do hero (`OniBoss`) não é
> re-desenho vetorial: é o frame de um GIF de referência recortado/keyado
> (`packages/animations/assets/images/oni_boss.png`), decodificado uma vez
> em `ui.Image` e composto via `drawImageRect` + `FilterQuality.none`
> (nearest, blocos crocantes, **1 draw call** em vez de ~130k `drawRect`).

## Testes

```bash
melos run test    # flutter test em todos os pacotes
```

- Cada Cubit/Bloc nasce com seu `bloc_test` cobrindo happy path + edge cases.
- Cada feature tem widget tests das suas sections.
- `design_system`: widget tests dos componentes base + `LocaleCubit`.
- Os mocks do showcase têm testes de fluxo (navegação entre telas, eventos).

Para rodar com coverage em um pacote:

```bash
cd packages/feature_showcase
flutter test --coverage
# coverage/lcov.info — abrir com lcov local ou seu reader favorito.
```

## Contato

Autor: **José Guilherme Alves** — front end mobile (Flutter).

- LinkedIn: <https://www.linkedin.com/in/jos%C3%A9-guilherme-alves-10a17b138/>
- E-mail: <contato.joseguilhermealves@gmail.com>

> A landing em si não nomeia empregadores, clientes ou produtos — descreve
> atuação por domínio/setor (varejo, setor público, campo, plataforma
> interna, serviço financeiro). O registro nominal mora no LinkedIn.

## Licença

[MIT](LICENSE) — © 2026 José Guilherme Alves.
