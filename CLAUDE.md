# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Fonte de verdade

`PROJECT.md` na raiz é a especificação canônica deste projeto. **Releia antes de qualquer decisão estrutural** (stack, arquitetura, conteúdo, roadmap, critérios de aceite). Este CLAUDE.md é um resumo operacional — em caso de conflito, PROJECT.md vence.

## Estado atual do repo

O monorepo ainda está em **scaffolding inicial**: apps/landing e cada packages/* foram criados via `flutter create` e ainda contêm os stubs default. Nada do que está em PROJECT.md §6 (Pub Workspaces + Melos) foi aplicado ainda — não existe `pubspec.yaml` na raiz, `analysis_options.yaml` raiz, nem `.gitignore` raiz. As dependências internas entre pacotes (path:) também não foram declaradas. Antes de implementar features, siga o roadmap §12 a partir do passo 1 (setup raiz).

Por isso, os comandos `melos run *` listados abaixo **só funcionam depois** que o `pubspec.yaml` raiz com a config Melos for criado e `melos bs` rodar com sucesso.

## Comandos

Após o setup do workspace estar concluído (PROJECT.md §6):

```bash
melos bs                  # builtin — bootstrap do workspace (alias de melos bootstrap)
melos clean               # builtin — flutter clean em todos os pacotes
melos run analyze         # análise estática em todos os pacotes (very_good_analysis)
melos run test            # flutter test em todos os pacotes
melos run format          # dart format em todos os pacotes
melos run gen             # build_runner build --delete-conflicting-outputs (freezed, injectable, json_serializable)
melos run run:web         # roda apps/landing em Chrome com --wasm
melos run build:web       # build PWA de produção (--wasm --release)
```

> `bs` e `clean` são **comandos builtin** do Melos, não scripts. Não declare scripts com esses nomes — Melos rejeita override de builtins com `Duplicate command`.

**Rodar um teste único** (dentro do diretório do pacote alvo, ex.: `packages/feature_contact`):

```bash
flutter test test/path/to/file_test.dart
flutter test test/path/to/file_test.dart --plain-name "nome do teste"
```

**Web build é sempre `--wasm`** (skwasm + fallback CanvasKit). Não fazer build sem essa flag.

## Arquitetura — o que requer ler vários arquivos pra entender

### Hierarquia de dependências (rígida)

```
core              ← sem dependências internas
design_system    → core
animations       → core, design_system
feature_*        → core, design_system, animations (opcional)
apps/landing     → tudo
```

**Features não dependem umas das outras.** Comunicação entre features acontece pelo shell em `apps/landing` (router + DI). Violar isso é o erro mais fácil de cometer e o mais caro de desfazer.

### Camadas dentro de cada `feature_*`

Feature-First + Clean Architecture, com três pastas:
- `data/` — datasources, repository impls, DTOs
- `domain/` — entities (freezed), repository abstracts, usecases (contrato base em `core/usecase`)
- `presentation/` — Bloc/Cubit, pages, widgets

Erros sobem como subclasses da sealed `Failure` definida em `core/failures` (NetworkFailure, ValidationFailure, etc.). Use `Result<T>` ou Either-style de `core/result` para retornos que podem falhar — não lance exceção atravessando camadas.

### State management — quando Cubit, quando Bloc

- **Cubit** para estado simples sem fluxo de eventos: theme toggle, navegação, scroll position.
- **Bloc** para fluxos com eventos: form de contato, orquestração de animações, qualquer coisa com transições não-triviais.

Toda Bloc/Cubit nasce com seu `bloc_test` na mesma sessão (PROJECT.md §15).

### DI

`get_it` + `injectable`. Cada feature **registra suas próprias dependências** — não centralizar registro no app shell. Codegen via `melos run gen`.

### Imutabilidade

`freezed` para entities, states e events. `json_serializable` para DTOs. Re-rodar `melos run gen` depois de qualquer mudança nessas classes.

### Routing

`go_router` declarativo. `/labs` é **deferred-loaded** (não baixa se o usuário não acessar) — preservar essa propriedade ao mexer no router.

## Custom Painters — coração técnico do projeto

Os painters em `packages/animations/lib/src/painters/` são o que prova maturidade técnica. PROJECT.md §5 lista os 6 mínimos. Regras invioláveis:

- `shouldRepaint` correto (só repinta quando o valor animado muda).
- `Paint` cacheados como campos — **nunca** instanciados dentro de `paint()`.
- Hints corretos de `isComplex` / `willChange` quando aplicável.
- Throttle de eventos de mouse no web (especialmente `ParticleFieldPainter`).
- **Não substituir Custom Painter por Lottie nas animações de destaque.** Lottie só para vetoriais ilustrativos secundários, caso a caso.

## Convenções de linguagem

- **UI / strings exibidas:** português brasileiro.
- **Comentários no código:** português.
- **Nomes de classes, métodos, variáveis, arquivos:** inglês.
- Nada de emoji em textos comerciais (Hero, Services, About, Contact). `/labs` pode ter tom mais técnico mas continua sem emoji.

## Web / PWA — não esquecer

- Loading screen customizado em `apps/landing/web/index.html` (HTML/CSS puro) que some quando `appRunner.runApp()` dispara. Sem ele o usuário vê tela branca por 2–4s no primeiro acesso.
- Meta tags SEO completas (title, description, og:image, twitter:card) e `Semantics` em headlines/CTAs — Flutter Web não indexa bem por padrão.
- Manifest PWA com ícones 192/512 + maskable, `display: standalone`.

## Hard NO-DOs (PROJECT.md §13)

- ❌ `melos.yaml` separado — config Melos vai dentro do `pubspec.yaml` raiz (Melos 7.3+).
- ❌ `flutter pub get` manual em cada pacote — sempre `melos bootstrap`.
- ❌ Dependência cruzada entre features.
- ❌ `setState` para fluxos não-triviais — use Cubit ou Bloc.
- ❌ Acoplar UI a classes de domain — sempre via Bloc/Cubit.
- ❌ Build sem `--wasm`.
- ❌ Imagens não otimizadas (use WebP + lazy load).
- ❌ Esquecer `Semantics` nos pontos-chave de acessibilidade.
- ❌ Esquecer o loading customizado no `index.html`.

## Commits

Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`). Melos pode usar isso para versionamento futuro.

## Quando perguntar antes de codar

Se uma decisão de produto ou arquitetura **não estiver clara em PROJECT.md**, pergunte ao José antes de implementar. Não assuma. Áreas tipicamente ambíguas: paleta exata de cores, copy final das seções, escopo dos templates de showcase, conteúdo da timeline About.
