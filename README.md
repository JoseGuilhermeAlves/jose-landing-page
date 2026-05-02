# jose-landing-page

Landing page institucional em Flutter Web (PWA) — vitrine tecnica e comercial de Jose Guilherme Alves.

> Em construcao. Veja `PROJECT.md` para especificacao tecnica completa.

## Stack

Flutter 3.38+, Dart 3.10+, Pub Workspaces, Melos 7.3, Bloc/Cubit, Clean Architecture.

## Setup local

```bash
fvm install        # instala Flutter 3.38.0 (versao pinada em .fvmrc)
fvm flutter pub get
dart run melos bs  # bootstrap do workspace
```

## Comandos

```bash
melos run analyze     # analise estatica
melos run test        # testes
melos run run:web     # roda em Chrome (--wasm)
melos run build:web   # build PWA de producao
```

## Licenca

MIT — veja `LICENSE`.
