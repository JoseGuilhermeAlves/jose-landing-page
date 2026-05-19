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

  /// Pixel stars default — 36 posicoes deterministas. Distribuicao
  /// espalhada por bandas de altura, evitando colidir com as ancoras dos
  /// planetas e densificando regioes "vazias" (centro-esquerda e canto
  /// inferior). Constante pra nao re-alocar por build.
  static const List<Offset> defaultPixelStars = [
    // Banda superior — densidade media, evita o canto direito (red giant).
    Offset(0.04, 0.06), Offset(0.10, 0.14), Offset(0.18, 0.04),
    Offset(0.26, 0.10), Offset(0.34, 0.18), Offset(0.40, 0.06),
    Offset(0.48, 0.12), Offset(0.56, 0.04), Offset(0.62, 0.10),
    // Upper mid.
    Offset(0.06, 0.22), Offset(0.30, 0.26), Offset(0.42, 0.30),
    Offset(0.58, 0.24), Offset(0.66, 0.32), Offset(0.78, 0.36),
    Offset(0.94, 0.42),
    // Lower mid.
    Offset(0.08, 0.50), Offset(0.20, 0.46), Offset(0.28, 0.54),
    Offset(0.44, 0.58), Offset(0.62, 0.52), Offset(0.74, 0.60),
    Offset(0.86, 0.52), Offset(0.96, 0.62),
    // Banda inferior.
    Offset(0.04, 0.74), Offset(0.14, 0.86), Offset(0.24, 0.70),
    Offset(0.32, 0.92), Offset(0.40, 0.80), Offset(0.50, 0.92),
    Offset(0.66, 0.88), Offset(0.78, 0.78), Offset(0.86, 0.94),
    Offset(0.96, 0.80), Offset(0.58, 0.68), Offset(0.16, 0.62),
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
      // 1. RED GIANT — paleta 5-stop em rampa vermelha. Painter
      // dithera as transicoes via Bayer 4x4 — sem gradient smooth.
      const CosmosPlanet(
        id: 'red-giant',
        canvasAnchor: Offset(1.05, -0.12),
        radiusPixels: 260,
        pattern: PlanetPattern.speckled,
        seed: 7,
        palette: [
          Color(0xFF240307), // shadow (terminator quase preto)
          Color(0xFF7A1A13), // mid-dark vermelho profundo
          Color(0xFFC9341F), // mid vermelho coral
          Color(0xFFF06A3A), // mid-light laranja queimado
          Color(0xFFFFC270), // highlight creme dourado
        ],
      ),
      // 2. GAS GIANT — bandas Jupiter + vortex spot. 5 stops.
      const CosmosPlanet(
        id: 'gas-giant',
        canvasAnchor: Offset(0.18, 0.32),
        radiusPixels: 36,
        pattern: PlanetPattern.bands,
        seed: 13,
        palette: [
          Color(0xFF311607), // shadow marrom escuro
          Color(0xFF6B3210), // mid-dark
          Color(0xFFB46A22), // mid laranja queimado
          Color(0xFFE8A14C), // mid-light laranja claro
          Color(0xFFFFE6A3), // highlight cream
        ],
        ring: PlanetRing(
          innerRadiusPixels: 48,
          outerRadiusPixels: 68,
          color: Color(0xFFE8D5A8),
          tiltY: 0.30,
        ),
      ),
      // 3. TEAL RINGED — hemisferios ciano com polar caps + lua.
      CosmosPlanet(
        id: 'teal-ringed',
        canvasAnchor: const Offset(0.52, 0.74),
        radiusPixels: 26,
        pattern: PlanetPattern.hemispheres,
        seed: 9,
        palette: const [
          Color(0xFF051A2E), // shadow azul-noite
          Color(0xFF114269), // mid-dark teal escuro
          Color(0xFF2D7DA8), // mid ciano oceano
          Color(0xFF6FC9E8), // mid-light ciano claro
          Color(0xFFD4F2FF), // highlight gelo
        ],
        ring: const PlanetRing(
          innerRadiusPixels: 36,
          outerRadiusPixels: 52,
          color: Color(0xCC9FD8E8),
          tiltY: 0.26,
        ),
        moon: PlanetMoon(
          orbitRadiusPixels: 32,
          moonRadiusPixels: 4,
          color: colors.onSurface.withValues(alpha: 0.88),
          phaseOffset: 0.15,
        ),
      ),
      // 4. VIOLET ROCKY — pequeno mas detalhado, crateras dithered.
      const CosmosPlanet(
        id: 'violet-rocky',
        canvasAnchor: Offset(0.74, 0.48),
        radiusPixels: 14,
        pattern: PlanetPattern.speckled,
        seed: 3,
        palette: [
          Color(0xFF120628), // shadow ultra-violeta
          Color(0xFF3D1B70), // mid-dark indigo
          Color(0xFF7240C2), // mid violeta saturado
          Color(0xFFB68BFF), // mid-light lilas
          Color(0xFFEADCFF), // highlight branco-violaceo
        ],
        moon: PlanetMoon(
          orbitRadiusPixels: 22,
          moonRadiusPixels: 2,
          color: Color(0xFFE0D4FF),
          phaseOffset: 0.55,
        ),
      ),
      // 5. GREEN DISTANT — mundo bandado verde, far-left.
      const CosmosPlanet(
        id: 'green-distant',
        canvasAnchor: Offset(0.34, 0.62),
        radiusPixels: 12,
        pattern: PlanetPattern.bands,
        seed: 2,
        palette: [
          Color(0xFF0A2618), // shadow forest-deep
          Color(0xFF1F5A3A), // mid-dark verde mata
          Color(0xFF3F9B6C), // mid verde clareira
          Color(0xFF8AE2B0), // mid-light verde lima
          Color(0xFFE4FFEC), // highlight gelo-verde
        ],
      ),
    ];
  }

  /// Conjunto default de nebulosas — 3 manchas em cores complementares
  /// pra adicionar profundidade sem competir com as estrelas.
  /// - Magenta no canto superior direito, amplifica o calor do red giant;
  /// - Brand purple no centro-esquerda, atras do gas giant;
  /// - Ciano sutil no centro-baixo, atras do teal ringed.
  static List<CosmosNebula> defaultNebulas(AppColorScheme colors) {
    return [
      const CosmosNebula(
        canvasAnchor: Offset(0.80, 0.10),
        radiusPixels: 60,
        color: Color(0xFFCE4FB8),
        density: 0.40,
        seed: 4,
      ),
      CosmosNebula(
        canvasAnchor: const Offset(0.22, 0.36),
        radiusPixels: 44,
        color: colors.primary.withValues(alpha: 0.45),
        density: 0.50,
        seed: 1,
      ),
      CosmosNebula(
        canvasAnchor: const Offset(0.58, 0.80),
        radiusPixels: 36,
        color: colors.accent.withValues(alpha: 0.40),
        density: 0.45,
        seed: 5,
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
