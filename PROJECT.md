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
Templates demonstráveis pra cliente leigo entender. Para esta versão:
- **E-commerce** — catálogo + carrinho mock
- **Delivery** — lista de pedidos com status animado
- **Agendamento** (serviços/salão) — calendário interativo
- **Fitness** — tracker de treino com gráficos
- **Imobiliária** — listagem de imóveis com filtros

Cada um vira um modal/route com 1–2 telas representativas. **Não precisa ter backend real** — mocks funcionais bastam. Cada template é um sub-flow dentro da feature, com Bloc próprio gerenciando o estado.

### 4.4 About (feature_about)
- Foto + bio curta
- Timeline de experiência (com Custom Painter desenhando a linha)
- Projetos reais que pode mencionar publicamente: TJBA Zela (genérico, "app de governo do TJ-BA"), PocketLab Sabesp (genérico, "app de campo para concessionária de saneamento"), Passaporte Solutis, TaqTaq.
- Stack badges (Flutter, Dart, Bloc, Clean Arch, etc)

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
10. **`feature_showcase`:** os 5 templates de nicho — pode ser o maior módulo, abordar incrementalmente (E-commerce → Delivery → Agendamento → Fitness → Imobiliária)
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
- [ ] Pelo menos 6 Custom Painters implementados
- [ ] Os 5 templates de showcase navegáveis
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
