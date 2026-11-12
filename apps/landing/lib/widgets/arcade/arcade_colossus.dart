import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Boss + portal black-hole ancorados ao ponto de fuga da pista, no MESMO
/// plano FIXO do `ArcadeBackdrop` (vivem no `ArcadeShell`, atras de todo o
/// conteudo). Por nao morarem no sliver do hero, NAO rolam com a pagina:
/// ficam grudados na linha do horizonte como a estrada — identicos em todas
/// as secoes.
///
/// Geometria amarrada ao backdrop: vanishing point em `(w/2, h*0.62)`, igual
/// ao `_horizonFraction`/`vanishingX` do `ArcadeBackdropPainter`. O boss desce
/// pra mergulhar atras da pista e desbota a 0 no horizonte (corpo abaixo do
/// vanishing point fica invisivel). Decorativo, `IgnorePointer`.
class ArcadeColossus extends StatelessWidget {
  const ArcadeColossus({super.key});

  /// Opacidade do boss — translucido, ao fundo de tudo (cores originais).
  static const double _bossOpacity = 0.4;

  /// Largura do fade (fracao da altura do boss) logo ACIMA do horizonte: o
  /// alpha vai de 1 -> 0 nessa banda e zera no vanishing point.
  static const double _bossFadeBand = 0.16;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          final isMobile = w < 600;
          const bossAspect = 1255 / 1560;

          var bossH = h * 0.8;
          var bossW = bossH * bossAspect;
          final maxBossW = w * (isMobile ? 1.02 : 0.46);
          if (bossW > maxBossW) {
            bossW = maxBossW;
            bossH = bossW / bossAspect;
          }

          // Ponto de fuga da pista (centro do backdrop fullscreen).
          final vanishingX = w / 2;
          final horizonY = h * 0.62;

          final bossLeft = vanishingX - bossW / 2;
          // Desce bastante (bottom bem abaixo do horizonte) — corpo mergulha
          // atras da pista, reforcando o "gigante ao fundo".
          final bossTop = horizonY - bossH + h * 0.22;

          // Fracao da altura do boss onde fica o horizonte. O mask zera o alpha
          // A PARTIR daqui -> tudo abaixo do vanishing point fica invisivel.
          final bossHorizonFrac = ((horizonY - bossTop) / bossH).clamp(0.0, 1.0);
          final bossFadeStartFrac =
              (bossHorizonFrac - _bossFadeBand).clamp(0.0, bossHorizonFrac);
          final bossMask = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Colors.white,
              Colors.white,
              Colors.transparent,
              Colors.transparent,
            ],
            stops: [0, bossFadeStartFrac, bossHorizonFrac, 1],
          );

          // Portal no fim da estrada — pequeno, centrado no ponto de fuga.
          final portalD = isMobile ? w * 0.34 : w * 0.16;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: bossLeft,
                top: bossTop,
                width: bossW,
                height: bossH,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: bossMask.createShader,
                  child: const OniBoss(opacity: _bossOpacity),
                ),
              ),
              Positioned(
                left: vanishingX - portalD / 2,
                top: horizonY - portalD / 2,
                width: portalD,
                height: portalD,
                child: const RoadPortal(),
              ),
            ],
          );
        },
      ),
    );
  }
}
