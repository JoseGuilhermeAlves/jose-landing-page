# jose-landing-page — Especificação Técnica do Projeto

> Documento de referência para o Claude Code construir o projeto. Este arquivo é a fonte de verdade. Releia antes de tomar qualquer decisão estrutural.

---

## 1. Contexto e Objetivo

**Quem é o autor:** José Guilherme Alves, desenvolvedor Flutter com 7+ anos de experiência. Atualmente alocado pela Solutis Tecnologias no Serasa Experian. Histórico em Sumirê Perfumaria (5 anos), TJBA Zela, Passaporte Solutis, TaqTaq, PocketLab/Sabesp.

**Propósito do projeto:** Landing page institucional em Flutter Web (PWA) que serve como **vitrine técnica e comercial** para captação de freelas. O link será divulgado em GetNinjas, LinkedIn e prospecção direta.

**Dois públicos, uma URL:**
1. **Cliente leigo (GetNinjas, dono de loja, empreendedor):** precisa ver clareza de oferta, prova social, exemplos visuais ("eu sei fazer algo parecido com X"), e CTA fácil pra WhatsApp.
2. **Cliente técnico / recrutador (LinkedIn, agências):** precisa ver maturidade arquitetural, animações sofisticadas, código limpo, monorepo organizado.

A landing principal serve o primeiro público. Uma seção **`/labs`** (acessível por scroll/link discreto) serve o segundo, demonstrando custom painters, micro-interações, e sandboxes interativos.

**Métrica de sucesso do projeto:** Visitante leigo entende em 5 segundos o que José faz e tem botão de WhatsApp à mão. Visitante técnico chega em `/labs` e fica impressionado o suficiente pra abrir o GitHub.

---

## 2. Stack e Decisões Técnicas

### 2.1 Versões e ferramentas

- **Flutter:** estável mais recente (≥ 3.38) — necessário para Pub Workspaces nativo
- **Dart:** ≥ 3.10
- **Melos:** 7.3.0+ (config dentro do `pubspec.yaml` raiz, **sem `melos.yaml` separado**)
- **Pub Workspaces:** ativo via `workspace:` no `pubspec.yaml` raiz
- **Renderer Web:** build com `--wasm` (skwasm + fallback CanvasKit automático)
- **Plataformas-alvo:** Android + Web (PWA). iOS, desktop e Windows **fora de escopo** desta versão.

### 2.2 Arquitetura

- **Padrão:** Feature-First + Clean Architecture
- **Camadas em cada feature:** `data/` (datasources, repositories impl, dtos), `domain/` (entities, repositories abstract, usecases), `presentation/` (blocs/cubits, pages, widgets)
- **State management:** **Bloc + Cubit combinados** — Cubit para estado simples (theme toggle, navegação, scroll position); Bloc para fluxos com eventos (form de contato, orquestração de animações).
- **DI:** `get_it` + `injectable` (gerado por build_runner). Cada feature registra suas próprias dependências.
- **Imutabilidade:** `freezed` para entities, states e events.
- **Erros:** sealed class `Failure` em `core`, hierarquia por tipo (NetworkFailure, ValidationFailure, etc).

### 2.3 Pacotes principais

| Categoria | Pacote | Uso |
|---|---|---|
| State | `flutter_bloc` | Bloc + Cubit |
| Modelos | `freezed`, `freezed_annotation`, `json_serializable` | Imutabilidade e serialização |
| DI | `get_it`, `injectable`, `injectable_generator` | Injeção de dependência |
| Build | `build_runner` | Codegen |
| Routing | `go_router` | Rotas declarativas, deep linking, web URL handling |
| Animações | `flutter_animate` | Micro-animações declarativas (complementa Custom Painter) |
| Lottie | `lottie` | Para animações vetoriais ilustrativas (opcional, decidir por caso) |
| Lints | `very_good_analysis` | Lint rigoroso |
| Testing | `bloc_test`, `mocktail` | Testes unitários e de bloc |

> **Importante:** Custom Painter é coração do projeto. Não substitua por Lottie nas animações de destaque — esses são os blocos que provam habilidade técnica.

---

## 3. Estrutura do Monorepo

```
jose-landing-page/
├── pubspec.yaml                    # Workspace root + config Melos
├── analysis_options.yaml           # Lints compartilhados (very_good_analysis)
├── README.md                       # README público (LinkedIn vai ler)
├── PROJECT.md                      # este arquivo
├── .gitignore
├── apps/
│   └── landing/                    # App PWA principal
│       ├── pubspec.yaml
│       ├── lib/
│       │   ├── main.dart
│       │   ├── app.dart            # MaterialApp.router + theme
│       │   ├── router/             # GoRouter config
│       │   ├── di/                 # injectable config
│       │   └── bootstrap.dart      # init de DI, observers, runZonedGuarded
│       ├── web/
│       │   ├── index.html          # custom loading screen, manifest, meta tags SEO
│       │   ├── manifest.json       # PWA manifest
│       │   └── icons/
│       └── android/
└── packages/
    ├── core/                       # SEM dependências internas
    │   ├── pubspec.yaml
    │   └── lib/
    │       └── src/
    │           ├── failures/       # Failure sealed classes
    │           ├── exceptions/     # Exceptions internos
    │           ├── usecase/        # UseCase contract base
    │           ├── result/         # Either-style ou Result<T>
    │           └── extensions/
    ├── design_system/              # depende de: core
    │   └── lib/src/
    │       ├── theme/              # ThemeData light/dark, color tokens
    │       ├── typography/
    │       ├── spacing/            # AppSpacing constants (4/8/16/24/32/64)
    │       ├── breakpoints/        # mobile / tablet / desktop
    │       ├── widgets/            # Botões, cards, inputs base
    │       └── responsive/         # ResponsiveBuilder, AdaptiveLayout
    ├── animations/                 # depende de: core, design_system
    │   └── lib/src/
    │       ├── painters/           # CustomPainters (ver seção 5)
    │       ├── controllers/        # Controllers reutilizáveis
    │       └── widgets/            # Wrappers prontos pra usar
    ├── feature_hero/               # Seção topo da landing
    ├── feature_services/           # Cards "o que eu faço"
    ├── feature_showcase/           # Templates de nichos (e-commerce, etc)
    ├── feature_about/              # Sobre o José + experiência
    ├── feature_contact/            # Formulário de contato (Bloc)
    └── feature_labs/               # Playground técnico (custom painters live)
```

### Regras de dependência

- `core` não depende de ninguém interno
- `design_system` depende apenas de `core`
- `animations` depende de `core` e `design_system`
- Cada `feature_*` depende de `core`, `design_system`, `animations` (apenas se precisar)
- **Features não dependem de outras features.** Comunicação entre features acontece via shell do app (`apps/landing`).
- App `landing` depende de tudo.

---

## 4. Conteúdo da Landing (das seções)

### 4.1 Hero (feature_hero)
- Headline: "Aplicativos Flutter de qualidade — do MVP ao app em produção"
- Subheadline: "7+ anos construindo apps mobile e web. De startups a sistemas críticos do governo."
- CTA primário: "Falar no WhatsApp" (link `wa.me`)
- CTA secundário: "Ver projetos"
- **Animação de fundo:** Custom Painter com partículas/grid animado reagindo ao mouse (ver §5.1)

### 4.2 Services (feature_services)
Grid de cards do que José entrega:
- Apps mobile (Android nativo via Flutter)
- Web Apps & PWA
- Integrações (APIs REST, Bluetooth, NFC, OAuth)
- Manutenção e evolução de apps existentes
- Consultoria técnica (arquitetura, refatoração)

Cada card com micro-animação de hover (Custom Painter desenhando borda).

### 4.3 Showcase (feature_showcase)

Cada um dos 5 templates é uma **experiência mockada quase completa** — não um esboço de uma tela só. Cada mock prova um eixo do que José pode entregar end-to-end no front, com identidade visual própria e múltiplas telas navegáveis dentro do `MaterialPageRoute(fullscreenDialog: true)`.

#### Princípios (valem pros 5 mocks)

1. **Identidade visual dedicada por mock.** Marca fictícia (nome curto + tagline), paleta dedicada via `Theme` override local (não toca a landing), micro-decisões tipográficas (peso, letter-spacing) que reforçam a marca. **Pulso** (fitness) é o template canônico — veja `packages/feature_showcase/lib/src/presentation/fitness/fitness_brand.dart` e replique o padrão ao introduzir marca nos demais.
2. **Múltiplas telas com navegação interna.** Cada mock tem 3–5 telas (home/dashboard, lista/catálogo, detalhe, ação/confirmação), conectadas por `TabBar`, `Navigator.push` ou `PageView`. Demo de uma tela só não é mais aceitável.
3. **Custom Painters para ilustrações.** Sem stock photos, sem bitmaps placeholder. Mascotes, silhuetas, gráficos, plantas baixas, mapas, banners de marca e ícones de categoria são todos desenhados via `CustomPaint`. **Esses painters vivem dentro do diretório do próprio mock**, não em `packages/animations` — que reserva-se aos painters reusáveis pela landing. Regras de performance (Paint cacheados, `shouldRepaint` correto) valem igualmente.
4. **Mocks funcionais.** Bloc/Cubit por template gerenciando estado real (carrinho, progresso, filtros), dados estáticos em `data/`. Zero backend.
5. **Tom da marca, não da landing.** A copy dentro do mock pode (e deve) ter personalidade própria — informal, técnica, lúdica — desde que coerente com o nicho. Não confundir com a regra "formal, direto, sucinto" que vale para o copy comercial da landing (Hero, Services, About, Contact).

#### 4.3.1 Pulso (Fitness) — **referência canônica**

- **Marca:** Pulso · "Treino sem fricção". **Paleta:** cream/laranja (light, oposta ao dark da landing) — laranja vibrante como primary, cream como background, slate escuro pro texto. **Referência visual:** Strava, Nike Run Club, Apple Fitness.
- **Telas:**
  - **Home (dashboard)** — entrada padrão do mock, com greeting, hero card do treino do dia (silhueta de atleta animada), activity rings (sets/minutos/exercícios), diagrama corporal destacando músculos do dia e resumo da semana.
  - **Hoje** (aba 1 do scaffold) — greeting + hero card com backdrop EKG, stats rápidos (sequência, sets, volume) e preview do plano.
  - **Semana** (aba 2) — strip horizontal de dias, progresso semanal com mini-barras, lista de exercícios com set dots tocáveis; **tap no card empurra `ExerciseDetailPage`**.
  - **Progresso** (aba 3) — % grande, barras por dia, gráfico de volume de 8 semanas.
  - **Detalhe de exercício** (push) — sumário sets/reps/carga, set tiles tocáveis, histórico de carga das 8 últimas semanas (painter dedicado), grupos musculares ativados (reusa body diagram) e notas técnicas inferidas do exercício.
  - **Rest timer sheet** (modal bottom sheet) — cronômetro com anel de progresso, ajuste ±15s, "Pular descanso".
- **Custom Painters dedicados:**
  - `VolumeHistoryChart` — line chart com Catmull-Rom smoothing, gradient fill e halo no ponto da semana atual.
  - `ExerciseLoadHistoryChart` — bar chart de carga por semana, barra atual destacada com halo + label flutuante.
  - `PulsoHeroBackdrop` — EKG-line scrollando atrás do hero card da aba Hoje; cadência mais calma no modo "descanso".
  - `PulsoActivityRings` — três anéis concêntricos estilo Apple Fitness; cada um anima de 0 até o progresso final.
  - `PulsoAthleteFigure` — silhueta geométrica de atleta em pose de levantamento com leve "respiração" sinusoidal.
  - `PulsoBodyDiagram` — diagrama anatômico estilizado com grupos musculares preencháveis.
  - Anel de rest timer (painter privado dentro de `rest_timer_sheet.dart`).
- **Status:** completo — 3 abas + home dashboard + detalhe de exercício + rest timer + 7 painters dedicados.

#### 4.3.2 Garoa (E-commerce) — café-livraria

- **Marca:** Garoa · "Café que rende uma conversa." Café-livraria urbana, tom caseiro/brasileiro/ritual. Catálogo curado em café/livraria/papelaria/objetos de mesa (não confundir com loja eclética). **Paleta:** café `#2B1A12` (primary), creme `#F6EFE0` (background), musgo `#5C6E47` (accent), surface branco. **Tipografia:** display em `fontFamily: 'serif'` (sem dep externa — Flutter resolve pro serif do sistema), body em sans. **Referência visual:** Blue Bottle, café-livrarias paulistanas/curitibanas, MUJI.
- **Telas (todas entregues):**
  - **Home** — hero da marca com backdrop animado (`GaroaHeroBackdrop`: grãos flutuando + plumas de vapor), strip de categorias (`GaroaCategoryIcon` em cada chip), grid de produtos em destaque, bloco "Sobre a Garoa".
  - **Catálogo** — grid responsivo 2/3/4 colunas com filtro por categoria (chips com glifos) e ordenação por preço (popup menu). Estado local via `StatefulWidget` (não justifica Cubit).
  - **Detalhe do produto** — galeria com 3 "ângulos" via cores/backgrounds variantes da mesma ilustração, headline em serif, origem, descrição editorial, variantes selecionáveis (`ProductVariant` com `deltaCents` opcional), stepper de quantidade, CTA "Adicionar" com snackbar de feedback + ação "Ver".
  - **Carrinho** (modal bottom sheet) — `GaroaCartSheet` com linhas tematizadas (ilustração via painter), stepper inline, breakdown subtotal/frete/total e CTA "Finalizar pedido".
  - **Resumo de pedido** — `GaroaOrderSummaryPage` com badge animado de check (`super(repaint: controller)` direto no painter, sem `AnimatedBuilder`), breakdown final, endereço mock fixo, ETA de entrega, CTA "Voltar à loja" (`popUntil(isFirst)`).
- **Custom Painters dedicados:** `GaroaHeroBackdrop` (grãos + vapor animado em loop), `GaroaProductIllustration` (silhueta categórica por `ProductCategory`: saquinho de café, caneca, caderno, livro), `GaroaCategoryIcon` (glifos pros chips), painter privado do badge de confirmação na tela de resumo.
- **Bloc:** `CartBloc` estendido com evento `CartCheckoutRequested` → snapshota `CartState` em `OrderSummary`, esvazia items e emite com `lastOrder` preenchido. Regra de frete: grátis acima de R$ 150,00, senão R$ 15,00 fixo. Número de pedido sequencial por sessão (`GAR-XXXX`). Helper `CartBloc.resetOrderCounter` para isolar testes.
- **Catálogo:** `ProductsCatalog.all` com 12 produtos curados em café/papelaria/livraria/mesa. `ProductsCatalog.featured` expõe 4 destaques pra home. `ProductsCatalog.byCategory(c)` filtra no catálogo.
- **Status:** completo — 5 telas navegáveis + identidade dedicada + 4 painters + checkout funcional.

#### 4.3.3 [marca-tbd] (Delivery)

- **Marca:** TBD. **Paleta:** TBD — proposta: laranja/preto ou amarelo de alerta.
- **Telas (planejadas):** Home (pedido ativo + categorias rápidas), Lista de restaurantes/lojas, Detalhe do pedido em andamento (timeline + mapa ilustrado), Histórico.
- **Custom Painters dedicados (planejados):** **mapa abstrato com rota animada** (destaque técnico), timeline de status com ícones desenhados, marker do entregador.
- **Status:** lista de pedidos com status animado existente é o ponto de partida; falta marca, mapa-painter e telas de home/detalhe.

#### 4.3.4 [marca-tbd] (Agendamento)

- **Marca:** TBD. **Paleta:** TBD — proposta: pastel ou minimalist wellness.
- **Telas (planejadas):** Home (próximo agendamento + grid de serviços), Catálogo de serviços, Calendário interativo de horários, Confirmação com resumo ilustrado.
- **Custom Painters dedicados (planejados):** ilustração de relógio/calendário decorativo na home, ícones dos serviços (corte, manicure, massagem etc.), confirmation badge com check animado.
- **Status:** calendário interativo existente é o ponto de partida; falta marca, home, catálogo e confirmação com painters.

#### 4.3.5 [marca-tbd] (Imobiliária)

- **Marca:** TBD. **Paleta:** TBD — proposta: navy/cream architectural ou earth tones.
- **Telas (planejadas):** Home (featured + busca por bairro/preço), Listagem com filtros, Detalhe do imóvel (galeria ilustrada + **planta baixa** + mapa de localização), Contato com corretor.
- **Custom Painters dedicados (planejados):** **planta baixa esquemática** (destaque técnico), silhueta de edifício/casa, mapa de bairro abstrato, ícones de feature (vaga, varanda, piscina).
- **Status:** listagem com filtros existente é o ponto de partida; falta marca, detalhe com planta baixa e painters de mapa.

> **Ordem de execução:** Pulso (fitness) → Garoa (e-commerce) — ambos completos — → delivery → agendamento → imobiliária. Cada mock é um PR médio-grande; não fundir dois numa só passagem.

### 4.4 About (feature_about)
- Foto + bio curta
- **Grid de domínios em que já atuei** (varejo B2B, plataforma interna, saneamento/operação de campo, setor público, fintech). Cards categóricos — não é timeline cronológica.
- **Nota de escopo** honesta: apps de varejo B2B foram construídos por ele ponta a ponta; nos demais domínios atua em time de produto, com escopo de feature/arquitetura.
- Stack badges (Flutter, Dart, Bloc, Clean Arch, etc).
- **Não nomear empresas nem produtos.** Detalhe nominal fica no LinkedIn — `https://www.linkedin.com/in/jos%C3%A9-guilherme-alves-10a17b138/`. Ver `MEMORY.md` (`copy_no_named_clients`) para a regra completa.

### 4.5 Contact (feature_contact)
- Formulário com Bloc completo: name, email, message, tipo de projeto (dropdown)
- Validações inline
- Submissão envia para WhatsApp pré-preenchido (sem backend nesta versão)
- CTAs alternativos: WhatsApp direto, email, LinkedIn, GitHub

### 4.6 Labs (feature_labs) — rota `/labs`
Esta é a vitrine técnica. **Não está no menu principal** — link discreto no footer ("para devs"). Conteúdo:
- Custom Painter playground com sliders ao vivo
- Demos de animações (cada um em rota própria)
- Link pro repo GitHub deste projeto
- Possível seção "decisões arquiteturais" descrevendo o monorepo

---

## 5. Animações — onde brilha o Custom Painter

Lista mínima de Custom Painters a implementar (em `packages/animations`):

### 5.1 `ParticleFieldPainter` (hero background)
- Partículas que reagem ao posicionamento do mouse/touch
- Performance crítica — usar `shouldRepaint` apropriadamente, evitar criar Paint dentro do paint()
- Throttle de eventos no web

### 5.2 `AnimatedTimelinePainter` (about)
- Desenha linha temporal progressivamente conforme entra na viewport
- Usa `PathMetrics.extractPath` para revelar caminho gradualmente
- Trigger por `VisibilityDetector`

### 5.3 `MorphingShapePainter` (transições entre seções)
- Interpola entre formas (ex: círculo → blob → quadrado)
- Demonstra controle de Path

### 5.4 `RippleHoverPainter` (em botões/cards)
- Onda expandindo do ponto de hover
- Reage a eventos de mouse no web

### 5.5 `WaveDividerPainter` (separadores entre seções)
- Onda animada baseada em sin/cos
- Decorativo mas leve

### 5.6 `LoadingSpinnerPainter` (exclusivo do projeto)
- Spinner customizado nas trocas de rota e fetches mockados
- Substitui CircularProgressIndicator padrão

**Princípio:** todos os painters devem ter `shouldRepaint` corretamente implementado (só repinta quando valor animado muda), Paint cacheados, e onde possível, oferecer `isComplex`/`willChange` hints corretos.

---

## 6. Configuração do Monorepo (Pub Workspaces + Melos 7.3)

### 6.1 `pubspec.yaml` raiz

```yaml
name: jose_landing_page
publish_to: none

environment:
  sdk: ">=3.10.0 <4.0.0"
  flutter: ">=3.38.0"

workspace:
  - apps/landing
  - packages/core
  - packages/design_system
  - packages/animations
  - packages/feature_hero
  - packages/feature_services
  - packages/feature_showcase
  - packages/feature_about
  - packages/feature_contact
  - packages/feature_labs

dev_dependencies:
  melos: ^7.3.0
  very_good_analysis: ^6.0.0

melos:
  scripts:
    bs:
      run: melos bootstrap
      description: Setup completo do workspace

    analyze:
      run: dart analyze .
      description: Análise estática em todos os pacotes
      exec:
        concurrency: 5
        failFast: true

    test:
      run: flutter test
      description: Roda testes em todos os pacotes Flutter
      exec:
        concurrency: 3
        failFast: true

    format:
      run: dart format .
      description: Formata todos os pacotes
      exec:
        concurrency: 5

    gen:
      run: dart run build_runner build --delete-conflicting-outputs
      description: Roda codegen onde aplicável
      exec:
        concurrency: 1
        failFast: true
      packageFilters:
        dependsOn: build_runner

    clean:
      run: flutter clean
      description: Limpa builds
      exec:
        concurrency: 5

    run:web:
      run: cd apps/landing && flutter run -d chrome --wasm
      description: Roda landing em Chrome com renderer WASM

    build:web:
      run: cd apps/landing && flutter build web --wasm --release
      description: Build de produção PWA com WASM
```

### 6.2 Cada pacote interno

Cada `packages/*/pubspec.yaml` deve ter:

```yaml
name: <package_name>
publish_to: none

environment:
  sdk: ">=3.10.0 <4.0.0"

resolution: workspace
```

E declarar dependências internas via path:

```yaml
dependencies:
  core:
    path: ../core
  design_system:
    path: ../design_system
```

---

## 7. Configuração Web / PWA

### 7.1 `apps/landing/web/index.html`

Implementar **custom loading screen** que aparece enquanto WASM/CanvasKit baixa. Sem isso, o usuário vê tela branca por 2–4s na primeira visita e desiste.

Requisitos:
- HTML/CSS puro do loading (não usa Flutter)
- Spinner discreto + texto "Carregando..."
- Some quando Flutter dispara `appRunner.runApp()`
- Meta tags SEO completas (title, description, og:image, twitter:card)
- Manifest PWA linkado
- Theme color matching com o app

### 7.2 `apps/landing/web/manifest.json`

PWA installable com:
- name, short_name
- ícones em múltiplos tamanhos (192, 512, maskable)
- theme_color e background_color matching
- display: standalone
- start_url: "/"

### 7.3 SEO

Flutter Web tem limitações de SEO porque renderiza em canvas. Mitigações:
- Meta tags completas no `index.html`
- Usar widget `Semantics` em pontos-chave (headlines, CTAs)
- Sitemap.xml estático
- robots.txt liberando indexação

---

## 8. Performance (não-negociável para landing)

- **Build sempre com `--wasm --release`** para deploy
- **Tree-shake icons** ativo (default no release)
- **Deferred imports** para `feature_labs` (não baixa se usuário não acessar `/labs`)
- **Imagens em WebP**, com fallback PNG
- **Fontes preloadadas** via `<link rel="preload">` no index.html
- **Targets de performance:** First Contentful Paint < 2s, Time to Interactive < 4s em 4G simulado

---

## 9. Tema, Branding e Tom

- **Visual direction:** moderno, profissional, com toque "tech" — não corporativo engessado, mas também não cartoon. Pense em sites como Linear, Vercel, Stripe — minimalismo com momentos de detalhe.
- **Cores:** paleta dark-first (mais comum em portfólios técnicos), com light mode opcional. Sugestão de paleta: roxo profundo + ciano accent + neutros — mas o design system deve permitir trocar via tokens.
- **Tipografia:** sans-serif moderna (Inter, Manrope ou similar via Google Fonts).
- **Tom de voz:** direto, brasileiro, sem jargão técnico nas seções comerciais; assertivo nas seções técnicas.
- **NÃO usar:** emojis em textos comerciais (parece amador), ilustrações 3D genéricas de stock, gradientes saturados.

---

## 10. Testes

Cobertura mínima esperada:
- **`core`:** 100% nas Failures e UseCase contracts
- **Cubits/Blocs:** todos com `bloc_test` cobrindo happy path + edge cases
- **Domain layer:** UseCases testados com mocks dos repositories
- **Widget tests:** componentes do design_system

Não exigir 100% no presentation/widgets das features — foco é onde o erro custa caro.

---

## 11. README.md (público)

O README que vai pro GitHub deve ter:
- Headline + 1 parágrafo do que é o projeto
- Screenshot/GIF do hero
- Stack utilizada (badges)
- Diagrama da arquitetura monorepo
- Como rodar localmente (`melos bs`, `melos run run:web`)
- Como buildar PWA
- Link para a versão deployada
- Estrutura de pastas comentada
- Decisões arquiteturais resumidas

> **Importante:** este README é leitura obrigatória de recrutador técnico. Capricha.

---

## 12. Roadmap de Execução (ordem sugerida)

Execute nesta ordem para evitar retrabalho:

1. **Setup raiz:** `pubspec.yaml` workspace, `analysis_options.yaml`, `.gitignore`, README placeholder
2. **`packages/core`:** Failure, UseCase, Result, extensions
3. **`packages/design_system`:** tokens, theme, breakpoints, widgets base, responsive helpers
4. **`packages/animations`:** ao menos `ParticleFieldPainter` e `LoadingSpinnerPainter`
5. **`apps/landing` shell:** main, app, router, DI, bootstrap, web/index.html com loading customizado, manifest
6. **`feature_hero`:** seção topo com painter integrado
7. **`feature_services`:** grid simples com cards animados
8. **`feature_about`:** timeline com `AnimatedTimelinePainter`
9. **`feature_contact`:** form com Bloc completo + validações
10. **`feature_showcase` — expansão dos 5 mocks (§4.3):** com baselines de cada nicho já entregues (carrinho, lista de pedidos, calendário, tracker de fitness, listagem de imóveis), cada template agora ganha marca/paleta/tipografia dedicada, múltiplas telas e Custom Painters de ilustração. Ordem: Pulso (fitness, canônico) → e-commerce → delivery → agendamento → imobiliária. Tratar cada mock como sub-projeto de PR médio-grande.
11. **`feature_labs`:** playground técnico, deferred-loaded
12. **Testes:** cobrir core, blocs e usecases
13. **Polish:** SEO, manifest icons, lighthouse audit, ajustes finais

A cada etapa rodar `melos run analyze` e `melos run test` antes de seguir.

---

## 13. O que NÃO fazer

- ❌ Não criar `melos.yaml` separado — config vai no `pubspec.yaml` raiz (Melos 7.3+)
- ❌ Não rodar `flutter pub get` manualmente em cada pacote — usar `melos bootstrap`
- ❌ Não criar features com dependência circular ou cruzada entre si
- ❌ Não usar `setState` para gerenciamento de estado em fluxos não-triviais — Cubit ou Bloc
- ❌ Não acoplar UI com classes de domain — sempre via Bloc/Cubit
- ❌ Não fazer build sem `--wasm` (queremos skwasm)
- ❌ Não usar imagens pesadas sem otimizar (WebP + lazy load)
- ❌ Não ignorar acessibilidade — `Semantics` nos pontos-chave
- ❌ Não esquecer o loading customizado no `index.html`

---

## 14. Critérios de aceite final

O projeto está pronto quando:
- [ ] `melos bs` faz setup limpo do zero
- [ ] `melos run analyze` passa sem warnings
- [ ] `melos run test` passa
- [ ] `melos run build:web` gera PWA funcional
- [ ] Landing carrega em < 4s no 4G simulado
- [ ] Lighthouse Performance ≥ 80, Accessibility ≥ 90, PWA ≥ 90
- [ ] Manifest PWA válido (instalável em Android)
- [ ] Pelo menos 6 Custom Painters implementados no `packages/animations` (reusáveis pela landing) + painters dedicados dentro de cada mock do showcase
- [ ] Os 5 templates de showcase com identidade visual dedicada (marca + paleta + tipografia) e ≥ 3 telas cada (§4.3)
- [ ] Form de contato funcional com Bloc
- [ ] `/labs` deferred-loaded
- [ ] README público completo
- [ ] Repo Git inicializado com commits semânticos (Conventional Commits)

---

## 15. Observações finais para o Claude Code

- Faça **commits semânticos** (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`) — Melos pode usar isso para versionamento futuro
- Sempre que criar um Bloc/Cubit, criar o teste correspondente na mesma sessão
- Antes de implementar Custom Painter complexo, validar com versão mínima e iterar
- Se uma decisão não estiver clara aqui, **pergunte** ao José antes de codar — não assuma
- Todas as strings de UI em português brasileiro
- Comentários no código em português, mas nomes de classes/métodos em inglês
