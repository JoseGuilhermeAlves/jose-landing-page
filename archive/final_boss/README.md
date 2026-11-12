# Final boss (arquivado)

Arte do "final boss" que ficava fixo ao fundo de todas as secoes da landing
(atras do conteudo, ancorado no ponto de fuga da pista Outrun), mais o portal
neon no fim da estrada. Removido no redesign `feat/redesign-pro-poco`
(2026-11) porque competia com o texto e deixava a pagina poluida.

Arquivos (extensao `.txt` pra ficarem fora da analise/compilacao do Dart):

- `oni_boss.png` — recorte 1:1 do frame 0 do GIF de referencia (466x285),
  fundo navy removido. Era asset do pacote `animations`.
- `oni_boss.dart.txt` — `OniBoss`: decodifica o PNG em `ui.Image` e desenha
  com `drawImageRect` + `FilterQuality.none` (pixels crocantes), com overlay
  de respiracao e bloom.
- `road_portal.dart.txt` — `RoadPortal`: portal black-hole no fim da pista.
- `arcade_colossus.dart.txt` — `ArcadeColossus`: posicionava boss + portal
  no `ArcadeShell`, com mascara que dissolvia o corpo no horizonte.

## Restaurar

1. Mover `oni_boss.png` para `packages/animations/assets/images/` e declarar
   em `packages/animations/pubspec.yaml` (`flutter: assets:`).
2. Renomear os `.dart.txt` para `.dart` nos lugares de origem
   (`packages/animations/lib/src/widgets/` e `apps/landing/lib/widgets/arcade/`)
   e reexportar `oni_boss.dart` / `road_portal.dart` em `animations.dart`.
3. Recolocar `const Positioned.fill(child: ArcadeColossus())` no `ArcadeShell`.
