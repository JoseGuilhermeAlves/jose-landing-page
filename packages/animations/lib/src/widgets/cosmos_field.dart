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
class CosmosField extends StatefulWidget {
  const CosmosField({
    this.duration = const Duration(seconds: 32),
    this.pixelSize = 4,
    this.planets,
    this.nebulas,
    this.comet,
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

  /// Cometa. `null` desativa.
  final CosmosComet? comet;

  /// Estrelas 8-bit avulsas (1 pixel cada). Default = posicoes
  /// deterministas espalhadas longe das ancoras dos planetas.
  final List<Offset> pixelStars;

  /// Pixel stars default — 18 posicoes deterministas espalhadas longe
  /// dos ancoramentos dos planetas pra nao competir com a silhueta
  /// deles. Constante pra que nao seja re-alocada por build.
  static const List<Offset> defaultPixelStars = [
    Offset(0.05, 0.15),
    Offset(0.12, 0.40),
    Offset(0.22, 0.10),
    Offset(0.28, 0.32),
    Offset(0.31, 0.62),
    Offset(0.38, 0.20),
    Offset(0.42, 0.85),
    Offset(0.50, 0.06),
    Offset(0.55, 0.48),
    Offset(0.60, 0.78),
    Offset(0.66, 0.16),
    Offset(0.70, 0.38),
    Offset(0.74, 0.92),
    Offset(0.82, 0.50),
    Offset(0.88, 0.72),
    Offset(0.92, 0.32),
    Offset(0.96, 0.10),
    Offset(0.08, 0.92),
  ];

  /// Cor das estrelas 8-bit. Default = `colors.onSurface`.
  final Color? starColor;

  /// Conjunto default de planetas — escolhido pra combinar com a paleta
  /// dark da landing. Usa cores da `AppColorScheme` quando avaliado em
  /// contexto; se chamado sem contexto, cai em cores hard-coded.
  static List<CosmosPlanet> defaultPlanets(AppColorScheme colors) {
    return [
      // Gas giant amarelo no canto superior direito — faixas estilo
      // Jupiter, paleta warm com brilho/sombra explicitos pro shading.
      CosmosPlanet(
        id: 'gas-giant',
        canvasAnchor: const Offset(0.86, 0.18),
        radiusPixels: 16,
        pattern: PlanetPattern.bands,
        palette: [
          colors.warning.withValues(alpha: 0.95),
          const Color(0xFFB07A2C),
          const Color(0xFF6B4818),
        ],
      ),
      // Planeta com anel, accent ciano — canto inferior esquerdo,
      // "deitado" no scroll cue. Anel comprimido pra parecer perfil.
      CosmosPlanet(
        id: 'ringed',
        canvasAnchor: const Offset(0.14, 0.76),
        radiusPixels: 12,
        pattern: PlanetPattern.hemispheres,
        palette: [
          colors.accent.withValues(alpha: 0.95),
          const Color(0xFF2C6B85),
        ],
        ring: PlanetRing(
          innerRadiusPixels: 16,
          outerRadiusPixels: 22,
          color: colors.accent.withValues(alpha: 0.65),
          tiltY: 0.32,
        ),
      ),
      // Planeta rochoso pequeno com lua — borda direita meio-baixa.
      CosmosPlanet(
        id: 'rocky',
        canvasAnchor: const Offset(0.94, 0.62),
        radiusPixels: 6,
        pattern: PlanetPattern.speckled,
        palette: [
          colors.error.withValues(alpha: 0.9),
          const Color(0xFF7A1F1F),
        ],
        moon: PlanetMoon(
          orbitRadiusPixels: 12,
          moonRadiusPixels: 2,
          color: colors.onSurface.withValues(alpha: 0.85),
          phaseOffset: 0.25,
        ),
      ),
    ];
  }

  /// Conjunto default de nebulosas. Roxa em torno do gas giant (apoia o
  /// brand color); ciano sutil cobrindo o canto inferior esquerdo, atras
  /// do planeta com anel.
  static List<CosmosNebula> defaultNebulas(AppColorScheme colors) {
    return [
      CosmosNebula(
        canvasAnchor: const Offset(0.78, 0.22),
        radiusPixels: 28,
        color: colors.primary.withValues(alpha: 0.16),
        density: 0.6,
      ),
      CosmosNebula(
        canvasAnchor: const Offset(0.18, 0.78),
        radiusPixels: 22,
        color: colors.accent.withValues(alpha: 0.12),
        seed: 1,
      ),
    ];
  }

  /// Cometa default: diagonal noroeste -> sudeste, com cauda longa.
  /// Tem visibilidade curta no inicio do ciclo (~6s) e some pelo resto.
  static CosmosComet defaultComet(AppColorScheme colors) {
    return CosmosComet(
      startAnchor: const Offset(-0.05, 0.08),
      endAnchor: const Offset(1.05, 0.55),
      tailLengthPixels: 14,
      color: colors.onSurface.withValues(alpha: 0.95),
    );
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
    final comet = widget.comet ?? CosmosField.defaultComet(colors);
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
            pixelStars: widget.pixelStars,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
