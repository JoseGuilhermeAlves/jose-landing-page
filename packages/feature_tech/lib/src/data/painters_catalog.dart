import 'package:feature_tech/src/domain/painter_highlight.dart';

/// Painters destacados do projeto. NAO e a lista exaustiva (mocks tem
/// painters proprios em feature_showcase/<mock>/presentation); aqui
/// ficam os de maior densidade tecnica, com role explicita.
abstract final class PaintersCatalog {
  static const List<PainterHighlight> all = [
    PainterHighlight(
      name: 'ParticleFieldPainter',
      role:
          'Particulas reativas a mouse, throttle por Ticker pra nao '
          'saturar com onHover.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'AnimatedBorderPainter',
      role:
          'Borda que se revela via PathMetrics.extractPath em hover, '
          'sem redesenhar segmento a segmento.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'WaveDividerPainter',
      role:
          'Wave horizontal animada em loop continuo separando as '
          'secoes da home.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'MorphingShapePainter',
      role: 'Interpolacao bezier entre formas. Centro do teaser do /labs.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'RippleHoverPainter',
      role:
          'Ondas em expansao no centro do cursor — feedback de toque '
          'em cards.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'AuroraDeliveryMap',
      role:
          'Mapa cartografico animado com rota Bezier + courier rotacionado '
          'via PathMetrics.getTangentForOffset.',
      location: 'feature_showcase / delivery',
    ),
    PainterHighlight(
      name: 'MiraCandlestickChart',
      role: 'Velas OHLC com crosshair interativo, tooltip e seed-determinismo.',
      location: 'feature_showcase / finance',
    ),
    PainterHighlight(
      name: 'CosmosPainter',
      role:
          'Galaxia espiral + nebulosas + pulsar em milhares de pontos '
          'batched via drawPoints; god-file dividido em extensions.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'ArcadeBackdropPainter',
      role:
          'Starfield em parallax + grid Outrun em perspectiva; geometria '
          'das estrelas cacheada, so a fase deriva do tempo.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'SolarFloorPlan',
      role:
          'Planta baixa esquematica com comodos rotulados que variam por '
          'tipo de imovel (casa/chacara/apartamento).',
      location: 'feature_showcase / realestate',
    ),
  ];
}
