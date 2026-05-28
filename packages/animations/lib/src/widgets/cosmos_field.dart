import 'package:animations/src/painters/cosmos_painter.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Widget host pro `CosmosPainter` — cena 8-bit com planetas, anel, luas
/// stepped e cometa. Usado como camada de back_ground do hero, atras das
/// constelacoes nomeadas e a frente do `ParticleField`.
///
/// Controller unico em loop longo (default 32s) alimenta todas as
/// animacoes: orbita das luas, twinkle dos pixel stars e janela do cometa
/// sao derivadas do mesmo `tick`. Mantem o overhead em 1 vsync apenas.
///
/// Por default expoe planetas/nebulas/cometa que combinam com a paleta
/// dark da landing. Substituiveis via construtor pra outros contextos
/// (labs playground, por exemplo).
/// Sentinel pra distinguir "default" de "explicitamente null" no parametro
/// `comet`. Sem ele nao da pra desativar o cometa (passar null cairia no
/// fallback `?? defaultComet(colors)`).
const CosmosComet _defaultCometSentinel = CosmosComet(
  startAnchor: Offset.zero,
  endAnchor: Offset.zero,
  tailLengthPixels: 0,
  color: Color(0x00000000),
);

class CosmosField extends StatefulWidget {
  const CosmosField({
    this.duration = const Duration(seconds: 32),
    this.pixelSize = 2,
    this.planets,
    this.nebulas,
    this.galaxies,
    this.pulsars,
    this.asteroidBelts,
    this.wisps,
    this.comet = _defaultCometSentinel,
    this.shootingStars,
    this.pixelStars = CosmosField.defaultPixelStars,
    this.starColor,
    super.key,
  });

  /// Duracao de um ciclo completo. Default 32s = orbita das luas devagar
  /// e cometa aparece com ~6s de visibilidade.
  final Duration duration;

  /// Lado do "8-bit pixel" em logical px. Default 4.
  final double pixelSize;

  /// Override dos planetas. `null` aplica [defaultPlanets].
  final List<CosmosPlanet>? planets;

  /// Override das nebulosas. `null` aplica [defaultNebulas].
  final List<CosmosNebula>? nebulas;

  /// Override das galaxias espirais. `null` aplica [defaultGalaxies];
  /// passar lista vazia desativa.
  final List<CosmosGalaxy>? galaxies;

  /// Override dos pulsares. `null` aplica [defaultPulsars]; passar lista
  /// vazia desativa.
  final List<CosmosPulsar>? pulsars;

  /// Override dos cinturoes de asteroides. `null` aplica
  /// [defaultAsteroidBelts]; passar lista vazia desativa.
  final List<CosmosAsteroidBelt>? asteroidBelts;

  /// Override dos wisps. `null` aplica [defaultWisps]; passar lista vazia
  /// desativa.
  final List<CosmosWisp>? wisps;

  /// Cometa. `null` desativa explicitamente (sem cometa na cena); omitir
  /// o argumento aplica [defaultComet]. Implementado via sentinel interno
  /// porque Dart nao distingue "nao passou" de "passou null" sem isso.
  final CosmosComet? comet;

  /// Estrelas cadentes (multiple shooting stars). `null` aplica
  /// [defaultShootingStars]; passar lista vazia desativa.
  final List<CosmosComet>? shootingStars;

  /// Estrelas 8-bit avulsas (1 pixel cada). Default = posicoes
  /// deterministas espalhadas longe das ancoras dos planetas.
  final List<Offset> pixelStars;

  /// Pixel stars default — 60 posicoes deterministas jitteradas em bandas
  /// de altura. Maior densidade pra cosmos populado mas sem grid uniforme.
  static const List<Offset> defaultPixelStars = [
    // Banda superior.
    Offset(0.03, 0.05), Offset(0.08, 0.12), Offset(0.13, 0.04),
    Offset(0.19, 0.09), Offset(0.25, 0.15), Offset(0.31, 0.06),
    Offset(0.37, 0.13), Offset(0.43, 0.05), Offset(0.49, 0.11),
    Offset(0.55, 0.03), Offset(0.61, 0.09), Offset(0.67, 0.14),
    // Upper mid.
    Offset(0.05, 0.22), Offset(0.11, 0.28), Offset(0.18, 0.20),
    Offset(0.24, 0.27), Offset(0.32, 0.24), Offset(0.39, 0.30),
    Offset(0.46, 0.22), Offset(0.53, 0.28), Offset(0.60, 0.21),
    Offset(0.68, 0.27), Offset(0.78, 0.35), Offset(0.88, 0.40),
    Offset(0.96, 0.30),
    // Mid.
    Offset(0.04, 0.42), Offset(0.10, 0.48), Offset(0.17, 0.40),
    Offset(0.26, 0.50), Offset(0.33, 0.42), Offset(0.40, 0.47),
    Offset(0.47, 0.40), Offset(0.54, 0.50), Offset(0.61, 0.43),
    Offset(0.68, 0.55), Offset(0.81, 0.46), Offset(0.92, 0.55),
    // Lower mid.
    Offset(0.06, 0.62), Offset(0.13, 0.58), Offset(0.21, 0.66),
    Offset(0.28, 0.60), Offset(0.36, 0.68), Offset(0.43, 0.61),
    Offset(0.50, 0.66), Offset(0.58, 0.60), Offset(0.66, 0.66),
    Offset(0.74, 0.62), Offset(0.83, 0.68), Offset(0.94, 0.62),
    // Banda inferior.
    Offset(0.04, 0.78), Offset(0.11, 0.86), Offset(0.19, 0.74),
    Offset(0.27, 0.88), Offset(0.35, 0.80), Offset(0.43, 0.92),
    Offset(0.51, 0.82), Offset(0.59, 0.94), Offset(0.67, 0.78),
    Offset(0.75, 0.88), Offset(0.85, 0.94), Offset(0.95, 0.82),
  ];

  /// Cor das estrelas 8-bit. Default = `colors.onSurface`.
  final Color? starColor;

  /// Conjunto default de planetas — composicao em 5 corpos com hierarquia
  /// de tamanho clara pra criar focal point dramatico.
  ///
  /// Ordem visual (de maior pra menor):
  /// 1. **Red giant** — gigante vermelho ocupando canto superior direito
  ///    com ~1/3 do disco visivel (centro off-screen). Define o tom da
  ///    cena, gera bloom quente no corner.
  /// 2. **Gas giant** — Jupiter-style com anel, meio-esquerda. Counter
  ///    balance ao red giant.
  /// 3. **Teal ringed** — hemisferios ciano + anel, meio-baixo. Adiciona
  ///    cor fria pra equilibrar a paleta quente.
  /// 4. **Violet rocky** — pequeno roxo com lua, interior direito.
  /// 5. **Green distant** — mundinho verde sutil, far left.
  static List<CosmosPlanet> defaultPlanets(AppColorScheme colors) {
    return [
      // 1. RED GIANT — gigante vermelho neon, focal point dominante.
      // Anchor mais perto da borda visivel pra mostrar ~80% do disco.
      const CosmosPlanet(
        id: 'red-giant',
        canvasAnchor: Offset(0.96, -0.06),
        radiusPixels: 150,
        pattern: PlanetPattern.speckled,
        seed: 7,
        palette: [
          Color(0xFF1A0008), // shadow quase preto
          Color(0xFF7A0E2A), // mid-dark dark red
          Color(0xFFFF1F44), // mid NEON RED solido
          Color(0xFFFF6679), // mid-light pink-red
          Color(0xFFFFDADE), // highlight blush
        ],
      ),
      // 2. ICE WORLD — neon cyan ringed, mid-left.
      const CosmosPlanet(
        id: 'ice-world',
        canvasAnchor: Offset(0.10, 0.34),
        radiusPixels: 40,
        pattern: PlanetPattern.hemispheres,
        seed: 9,
        palette: [
          Color(0xFF010E1A), // shadow azul-noite profundo
          Color(0xFF0A446A), // mid-dark teal
          Color(0xFF0AC4FF), // mid NEON CYAN solido
          Color(0xFF7FE9FF), // mid-light ciano-claro
          Color(0xFFE8FBFF), // highlight gelo
        ],
        ring: PlanetRing(
          innerRadiusPixels: 54,
          outerRadiusPixels: 76,
          color: Color(0xEE0AE0FF),
          tiltY: 0.28,
        ),
      ),
      // 3. MAGENTA GIANT — neon magenta bands com vortex + lua.
      CosmosPlanet(
        id: 'magenta-giant',
        canvasAnchor: const Offset(0.42, 0.74),
        radiusPixels: 34,
        pattern: PlanetPattern.bands,
        seed: 13,
        palette: const [
          Color(0xFF1A0524), // shadow ultra-violet
          Color(0xFF5C0F7A), // mid-dark
          Color(0xFFE020F2), // mid NEON MAGENTA
          Color(0xFFFF66F5), // mid-light pink-magenta
          Color(0xFFFFCFF8), // highlight rosa-claro
        ],
        moon: PlanetMoon(
          orbitRadiusPixels: 46,
          moonRadiusPixels: 5,
          color: Color(0xFFFFFFFF),
          phaseOffset: 0.15,
        ),
      ),
      // 4. LIME ROCKY — neon lime brilhante, mid-bottom-left.
      const CosmosPlanet(
        id: 'lime-rocky',
        canvasAnchor: Offset(0.22, 0.74),
        radiusPixels: 18,
        pattern: PlanetPattern.speckled,
        seed: 3,
        palette: [
          Color(0xFF020F08),
          Color(0xFF0A4023),
          Color(0xFF1FFF6E), // mid NEON LIME
          Color(0xFFA5FFC1),
          Color(0xFFE9FFEC),
        ],
        moon: PlanetMoon(
          orbitRadiusPixels: 28,
          moonRadiusPixels: 2,
          color: Color(0xFFE6FFD9),
          phaseOffset: 0.55,
        ),
      ),
      // 5. VIOLET ROCKY — neon roxo, mid-center.
      const CosmosPlanet(
        id: 'violet-rocky',
        canvasAnchor: Offset(0.36, 0.46),
        radiusPixels: 15,
        pattern: PlanetPattern.speckled,
        seed: 17,
        palette: [
          Color(0xFF120428),
          Color(0xFF391066),
          Color(0xFF9D3FFF), // mid NEON VIOLET
          Color(0xFFD58BFF),
          Color(0xFFF0DCFF),
        ],
      ),
      // 6. GOLD DWARF — gold neon brilhante, bottom-center.
      const CosmosPlanet(
        id: 'gold-dwarf',
        canvasAnchor: Offset(0.56, 0.92),
        radiusPixels: 12,
        pattern: PlanetPattern.bands,
        seed: 23,
        palette: [
          Color(0xFF2E1A02),
          Color(0xFF7A4A0A),
          Color(0xFFFFB81F), // mid NEON GOLD
          Color(0xFFFFE066),
          Color(0xFFFFF8C8),
        ],
      ),
      // 7. ELECTRIC BLUE — top-center, distant.
      const CosmosPlanet(
        id: 'electric-blue',
        canvasAnchor: Offset(0.58, 0.20),
        radiusPixels: 10,
        pattern: PlanetPattern.hemispheres,
        seed: 19,
        palette: [
          Color(0xFF020B26),
          Color(0xFF0A2B70),
          Color(0xFF2D7FFF), // mid electric blue
          Color(0xFF7CB8FF),
          Color(0xFFE0EEFF),
        ],
      ),
      // 8. CORAL ROCKY — neon coral, mid-right-bottom (mais central).
      const CosmosPlanet(
        id: 'coral-rocky',
        canvasAnchor: Offset(0.74, 0.62),
        radiusPixels: 17,
        pattern: PlanetPattern.speckled,
        seed: 29,
        palette: [
          Color(0xFF2A0A00),
          Color(0xFF7A2308),
          Color(0xFFFF5520), // mid NEON CORAL
          Color(0xFFFFA579),
          Color(0xFFFFE5D6),
        ],
      ),
    ];
  }

  /// Nebulosas default — 5 manchas vibrantes em neon distribuidas pra
  /// criar atmosfera cosmica colorida. Cada uma com cor saturada
  /// distinta (magenta, cyan, violet, hot pink, electric blue) e
  /// densidade variavel.
  static List<CosmosNebula> defaultNebulas(AppColorScheme colors) {
    return const [
      // 1. Magenta + warm tones atras do red giant — amplifica o calor.
      CosmosNebula(
        canvasAnchor: Offset(0.78, 0.05),
        radiusPixels: 110,
        color: Color(0xFFFF1F8B),
        density: 0.78,
        seed: 4,
      ),
      // 2. Cyan atras do ice world.
      CosmosNebula(
        canvasAnchor: Offset(0.14, 0.38),
        radiusPixels: 84,
        color: Color(0xFF0AC4FF),
        density: 0.72,
        seed: 1,
      ),
      // 3. Violet centro.
      CosmosNebula(
        canvasAnchor: Offset(0.42, 0.38),
        radiusPixels: 88,
        color: Color(0xFF9D3FFF),
        density: 0.68,
        seed: 6,
      ),
      // 4. Neon magenta atras do magenta giant.
      CosmosNebula(
        canvasAnchor: Offset(0.46, 0.80),
        radiusPixels: 76,
        color: Color(0xFFE020F2),
        density: 0.70,
        seed: 5,
      ),
      // 5. Electric blue top-center.
      CosmosNebula(
        canvasAnchor: Offset(0.62, 0.24),
        radiusPixels: 58,
        color: Color(0xFF2D7FFF),
        density: 0.62,
        seed: 11,
      ),
    ];
  }

  /// Galaxias espirais default — uma unica centerpiece grande off-axis
  /// no canto inferior esquerdo. Nucleo creme quente + bracos violet
  /// frios pra harmonizar com o conjunto de planetas neon. Renderiza
  /// atras de tudo (sob nebulosas e estrelas), criando uma sensacao de
  /// profundidade cosmica sem competir com o red giant focal.
  static List<CosmosGalaxy> defaultGalaxies(AppColorScheme colors) {
    return const [
      CosmosGalaxy(
        canvasAnchor: Offset(0.18, 0.86),
        radiusPixels: 130,
        coreColor: Color(0xFFFFE8C2),
        armColor: Color(0xFF9D3FFF),
        tiltY: 0.42,
        rotation: -0.6,
        dustCount: 260,
        seed: 41,
      ),
    ];
  }

  /// Pulsares default — dois acentos pontuais em pontos calmos da cena
  /// (longe dos planetas grandes), com cores frias (cyan + hot pink) e
  /// fases dessincronizadas pra os pulsos nao baterem juntos.
  static List<CosmosPulsar> defaultPulsars(AppColorScheme colors) {
    return const [
      CosmosPulsar(
        canvasAnchor: Offset(0.86, 0.78),
        coreColor: Color(0xFF99FFEC),
        beamColor: Color(0xFF0AC4FF),
        beamLengthPixels: 70,
        seed: 31,
      ),
      CosmosPulsar(
        canvasAnchor: Offset(0.30, 0.16),
        coreColor: Color(0xFFFFCFF8),
        beamColor: Color(0xFFFF1F8B),
        coreRadiusPixels: 2,
        beamLengthPixels: 54,
        phaseOffset: 0.37,
        seed: 47,
      ),
    ];
  }

  /// Cinturao de asteroides default — um unico arco amplo no canto
  /// inferior-direito, levemente atras do coral-rocky. Rochas escuras com
  /// pingos de gold pra reforcar a paleta quente da cena sem competir com
  /// o red giant.
  static List<CosmosAsteroidBelt> defaultAsteroidBelts(AppColorScheme colors) {
    return const [
      CosmosAsteroidBelt(
        canvasAnchor: Offset(0.74, 0.62),
        radiusPixels: 90,
        rockColor: Color(0xFFC9B59A),
        highlightColor: Color(0xFFFFE066),
        tiltY: 0.32,
        rotation: 0.45,
        thicknessFactor: 0.16,
        rockCount: 160,
        arcStart: 0.08,
        arcSweep: 0.78,
        seed: 53,
      ),
    ];
  }

  /// Wisps default — um cluster soft no quadrante superior-esquerdo
  /// (cyan + violet iridescente) e outro menor mid-direito (warm pink) pra
  /// preencher cantos sem competir com nebulosas/focal points.
  static List<CosmosWisp> defaultWisps(AppColorScheme colors) {
    return const [
      CosmosWisp(
        canvasAnchor: Offset(0.32, 0.20),
        radiusPixels: 70,
        colors: [
          Color(0xFF7FE9FF),
          Color(0xFFB78BFF),
          Color(0xFFE020F2),
        ],
        blobCount: 6,
        driftPixels: 9,
        density: 0.55,
        seed: 71,
      ),
      CosmosWisp(
        canvasAnchor: Offset(0.88, 0.42),
        radiusPixels: 56,
        colors: [
          Color(0xFFFF99D6),
          Color(0xFFFFE2B0),
        ],
        blobCount: 4,
        driftPixels: 7,
        density: 0.48,
        seed: 89,
      ),
    ];
  }

  /// Cometa default: diagonal noroeste -> sudeste, com cauda longa.
  /// Janela curta no inicio do ciclo (~6s) — sensacao de evento raro.
  static CosmosComet defaultComet(AppColorScheme colors) {
    return CosmosComet(
      startAnchor: const Offset(-0.05, 0.08),
      endAnchor: const Offset(1.05, 0.55),
      tailLengthPixels: 14,
      color: colors.onSurface.withValues(alpha: 0.95),
    );
  }

  /// 4 estrelas cadentes distribuidas pelo ciclo — cada uma com janela
  /// estreita (~5% do ciclo, ~1.6s a 32s) e direcoes variadas. Junto com
  /// o cometa principal forma ~5 eventos de "shooting star" por ciclo,
  /// um a cada ~6.4s. Cores variadas (white / cool-blue / warm-gold) pra
  /// nao parecer mecanico.
  static List<CosmosComet> defaultShootingStars(AppColorScheme colors) {
    return const [
      // 1. Esquerda → meio-baixo, branco.
      CosmosComet(
        startAnchor: Offset(-0.05, 0.30),
        endAnchor: Offset(0.55, 0.62),
        tailLengthPixels: 8,
        color: Color(0xFFFFFFFF),
        windowStart: 0.24,
        windowEnd: 0.30,
      ),
      // 2. Topo → meio-direita, cool blue tint.
      CosmosComet(
        startAnchor: Offset(0.35, -0.05),
        endAnchor: Offset(0.78, 0.45),
        tailLengthPixels: 6,
        color: Color(0xFFBFD4FF),
        windowStart: 0.46,
        windowEnd: 0.51,
      ),
      // 3. Direita → meio-esquerda, warm gold.
      CosmosComet(
        startAnchor: Offset(1.05, 0.20),
        endAnchor: Offset(0.45, 0.66),
        tailLengthPixels: 10,
        color: Color(0xFFFFE2B0),
        windowStart: 0.68,
        windowEnd: 0.74,
      ),
      // 4. Esquerda-baixo → direita-baixo, branco fraco.
      CosmosComet(
        startAnchor: Offset(-0.05, 0.78),
        endAnchor: Offset(0.62, 0.96),
        tailLengthPixels: 7,
        color: Color(0xFFE8F0FF),
        windowStart: 0.86,
        windowEnd: 0.91,
      ),
    ];
  }

  @override
  State<CosmosField> createState() => _CosmosFieldState();
}

class _CosmosFieldState extends State<CosmosField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void didUpdateWidget(covariant CosmosField old) {
    super.didUpdateWidget(old);
    if (old.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final planets = widget.planets ?? CosmosField.defaultPlanets(colors);
    final nebulas = widget.nebulas ?? CosmosField.defaultNebulas(colors);
    final galaxies = widget.galaxies ?? CosmosField.defaultGalaxies(colors);
    final pulsars = widget.pulsars ?? CosmosField.defaultPulsars(colors);
    final asteroidBelts =
        widget.asteroidBelts ?? CosmosField.defaultAsteroidBelts(colors);
    final wisps = widget.wisps ?? CosmosField.defaultWisps(colors);
    final comet = identical(widget.comet, _defaultCometSentinel)
        ? CosmosField.defaultComet(colors)
        : widget.comet;
    final shootingStars =
        widget.shootingStars ?? CosmosField.defaultShootingStars(colors);
    final starColor =
        widget.starColor ?? colors.onSurface.withValues(alpha: 0.75);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          isComplex: true,
          willChange: true,
          painter: CosmosPainter(
            tick: _controller.value,
            starColor: starColor,
            pixelSize: widget.pixelSize,
            planets: planets,
            nebulas: nebulas,
            galaxies: galaxies,
            pulsars: pulsars,
            asteroidBelts: asteroidBelts,
            wisps: wisps,
            comet: comet,
            shootingStars: shootingStars,
            pixelStars: widget.pixelStars,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
