import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

/// Cena cosmica do hero, em duas camadas que dividem o mesmo controller:
///
/// 1. **FAR** — galaxia espiral focal + nebulosas neon + wisp + pulsar
///    (gas difuso via [CosmosPainter]). Da contexto e profundidade: os
///    planetas deixam de parecer "jogados" e passam a habitar um universo.
/// 2. **MID** — planetas pixel ([CelestialPlanet]) que PASSAM devagar da
///    direita pra esquerda (parallax por `step`), cada um com halo neon.
///
/// Tudo vive na FAIXA DO CEU (acima do horizonte do grid Outrun em ~0.62) —
/// nada cruza a pista. **Camadas (tras -> frente):** galaxia/nebulosa -> BOSS
/// (colosso gigante e translucido, CENTRADO no ponto de fuga da pista) ->
/// planetas. O boss fica ATRAS dos planetas e do texto de proposito: eles
/// passam na frente e reforcam que ele e maior e mais ao fundo. Decorativo,
/// `IgnorePointer`.
class HeroCosmos extends StatefulWidget {
  const HeroCosmos({super.key});

  /// x inicial 0..1; y 0..1 (so faixa do ceu, < ~0.5); diametro px; corpo;
  /// passo de parallax (1 = lento, 2 = ~2x); cor do halo neon.
  static const List<_Body> _bodies = [
    _Body(0.11, 0.17, 140, CelestialBody.saturn, 1, Color(0xFFFF3CAC)),
    _Body(0.49, 0.085, 66, CelestialBody.ice, 2, Color(0xFF36E0FF)),
    _Body(0.38, 0.21, 72, CelestialBody.portal, 2, Color(0xFFE83CC8)),
    _Body(0.27, 0.40, 88, CelestialBody.earth, 1, Color(0xFF2FA8E0)),
    _Body(0.64, 0.33, 92, CelestialBody.lava, 1, Color(0xFFFF6A1E)),
  ];

  // ---- Camada FAR (gas difuso). Anchors em fracao; radii em px absolutos
  // (escalados por pixelSize conforme breakpoint). Todos no ceu (y < 0.45).

  static const List<CosmosGalaxy> _galaxies = [
    CosmosGalaxy(
      canvasAnchor: Offset(0.17, 0.22),
      radiusPixels: 185,
      coreColor: Color(0xFFFFE6C2),
      armColor: Color(0xFF49E8FF),
      tiltY: 0.40,
      rotation: 0.6,
      dustCount: 300,
      seed: 7,
    ),
  ];

  // Nebulosas: glow neon SUTIL sobre o preto (density baixa) — contexto de
  // profundidade, nao lavar a cena de pastel.
  static const List<CosmosNebula> _nebulas = [
    CosmosNebula(
      canvasAnchor: Offset(0.30, 0.26),
      radiusPixels: 210,
      color: Color(0xFFFF2EA0),
      density: 0.16,
      seed: 3,
    ),
    CosmosNebula(
      canvasAnchor: Offset(0.70, 0.18),
      radiusPixels: 180,
      color: Color(0xFF6A3CFF),
      density: 0.15,
      seed: 11,
    ),
    CosmosNebula(
      canvasAnchor: Offset(0.54, 0.42),
      radiusPixels: 150,
      color: Color(0xFF14C2D6),
      density: 0.12,
      seed: 5,
    ),
  ];

  static const List<CosmosWisp> _wisps = [
    CosmosWisp(
      canvasAnchor: Offset(0.88, 0.31),
      radiusPixels: 100,
      colors: [Color(0xFFFF66C4), Color(0xFF36E0FF)],
      driftPixels: 14,
      density: 0.28,
      seed: 9,
    ),
  ];

  static const List<CosmosPulsar> _pulsars = [
    CosmosPulsar(
      canvasAnchor: Offset(0.42, 0.10),
      coreColor: Color(0xFFFFFFFF),
      beamColor: Color(0xFF8AF0FF),
      beamLengthPixels: 64,
      beamWidthRadians: 0.09,
      phaseOffset: 0.2,
      seed: 4,
    ),
  ];

  @override
  State<HeroCosmos> createState() => _HeroCosmosState();
}

class _HeroCosmosState extends State<HeroCosmos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scroll;

  @override
  void initState() {
    super.initState();
    // 1 volta = travessia de um "passo" de parallax. Loop sem salto: x usa
    // multiplos inteiros do span de wrap (ver _xFor). A galaxia/nebulosa/
    // pulsar leem o mesmo tick via CosmosPainter(super: repaint).
    _scroll = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.stop();
    } else if (!_scroll.isAnimating) {
      _scroll.repeat();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Span de wrap em fracao de largura (entra/sai com folga).
  static const double _span = 1.3;

  /// x normalizado com wrap continuo (seamless: desloca multiplo inteiro
  /// de [_span] por volta, entao value 0 e 1 coincidem).
  double _xFor(_Body b) {
    var x = (b.x - _scroll.value * _span * b.step) % _span;
    if (x < 0) x += _span;
    return x - 0.15; // folga a esquerda
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          // Mobile encolhe os corpos difusos (radii sao px absolutos).
          final pixelSize = w < 600 ? 0.6 : 1.0;
          // FINAL BOSS "Oni Mask": sprite pixel-art 1:1 (oni neon de corpo
          // inteiro, fundo removido), reconstruido no Canvas pelo OniBoss.
          // Agora um COLOSSO LA NO FUNDO: gigante, translucido e CENTRADO no
          // ponto de fuga da pista. O grid Outrun do shell converge em
          // (w/2, screenH * _horizonFraction); o boss sobe dali, com a cauda
          // pousando exatamente onde a pista termina. Fica ATRAS de tudo
          // (planetas + texto passam na frente) e com opacidade baixa pra nao
          // roubar o foco da copy.
          const bossAspect = 1255 / 1560; // w/h do sprite recortado
          final isMobileViewport = w < 600;
          // Escala pela VIEWPORT (nao pelo `h` do hero, que cresce no mobile com
          // o conteudo empilhado): a origem do hero coincide com o topo da tela,
          // entao y em espaco-hero == y em espaco-viewport no 1o fold.
          final screenH = MediaQuery.sizeOf(context).height;
          // Colosso CENTRADO no ponto de fuga. Mesma escala vertical em web e
          // mobile (a do mobile ficou perfeita): a cauda pousa perto do
          // horizonte e o rosto fica no topo nos dois.
          var bossH = screenH * 0.68;
          var bossW = bossH * bossAspect;
          // No mobile o cap pela largura corta de leve as laterais (mantem
          // presenca); no desktop limita pra nao ocupar a tela toda.
          final maxBossW = w * (isMobileViewport ? 1.02 : 0.46);
          if (bossW > maxBossW) {
            bossW = maxBossW;
            bossH = bossW / bossAspect;
          }
          // CENTRO do boss = PONTO DE FUGA da pista. O grid do shell e
          // full-width (vive ATRAS do menu lateral), entao converge no centro da
          // VIEWPORT — nao no centro da area de conteudo, que no desktop e
          // empurrada pra direita pelo side nav. Converte o centro da viewport
          // pra coords locais do HeroCosmos (no mobile, sem nav, vira w/2).
          final screenW = MediaQuery.sizeOf(context).width;
          final trackCenterX = w - screenW / 2;
          final bossLeft = trackCenterX - bossW / 2;
          // Vertical: WEB ancora a CAUDA no horizonte (linha da pista, 0.62 da
          // viewport) — o fim da pista encontra o boss. MOBILE mantem a ancora
          // pelo rosto (composicao ja aprovada).
          final bossTop = isMobileViewport
              ? screenH * 0.12 - bossH * 0.16
              : screenH * 0.62 - bossH;
          // Meio-termo: opacidade media + DESSATURADO. Presente como colosso,
          // mas as cores neon mutadas nao roubam o destaque da copy.
          const bossOpacity = 0.5;
          const bossSaturation = 0.82;
          return Stack(
            fit: StackFit.expand,
            children: [
              // FAR: galaxia + nebulosas + wisp + pulsar. O painter ouve o
              // _scroll direto (repaint:), entao fica FORA do AnimatedBuilder.
              RepaintBoundary(
                child: CustomPaint(
                  isComplex: true,
                  willChange: true,
                  painter: CosmosPainter(
                    animation: _scroll,
                    starColor: const Color(0x00000000),
                    pixelSize: pixelSize,
                    galaxies: HeroCosmos._galaxies,
                    nebulas: HeroCosmos._nebulas,
                    wisps: HeroCosmos._wisps,
                    pulsars: HeroCosmos._pulsars,
                  ),
                  size: Size.infinite,
                ),
              ),
              // BOSS: colosso gigante e translucido, CENTRADO no ponto de fuga
              // (cauda na linha do horizonte), ATRAS dos planetas e do texto —
              // os planetas passam na frente e reforcam profundidade.
              Positioned(
                left: bossLeft,
                top: bossTop,
                width: bossW,
                height: bossH,
                child: const OniBoss(
                  opacity: bossOpacity,
                  saturation: bossSaturation,
                ),
              ),
              // MID: planetas pixel passando (parallax) — NA FRENTE do boss.
              AnimatedBuilder(
                animation: _scroll,
                builder: (context, _) {
                  return Stack(
                    children: [
                      for (final b in HeroCosmos._bodies)
                        // Caixa do halo (1.7x o corpo) — o planeta opaco cobre
                        // o miolo do gradiente, sobra so o anel de bloom neon.
                        Positioned(
                          left: _xFor(b) * w - b.size * 0.85,
                          top: b.y * h - b.size * 0.85,
                          width: b.size * 1.7,
                          height: b.size * 1.7,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      b.glow.withValues(alpha: 0.5),
                                      b.glow.withValues(alpha: 0),
                                    ],
                                    stops: const [0.34, 1],
                                  ),
                                ),
                              ),
                              Center(
                                child: SizedBox(
                                  width: b.size,
                                  height: b.size,
                                  child: CelestialPlanet(
                                    body: b.body,
                                    seed: b.seed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Body {
  const _Body(this.x, this.y, this.size, this.body, this.step, this.glow);

  final double x;
  final double y;
  final double size;
  final CelestialBody body;
  final int step;

  /// Cor do halo neon (bloom) atras do corpo.
  final Color glow;

  /// Seed estavel por posicao (varia o noise entre corpos do mesmo tipo).
  int get seed => (x * 100).round() + (y * 13).round() + 1;
}
